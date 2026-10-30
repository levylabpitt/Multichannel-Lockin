# Issue drafts - measuring InputOffset and OutputOffset

Drafts for two new issues, written 2026-10-27 after #186 / #188. Based on `Instrument.DAQ/Process.vi` as read with lvkit before your latest macro edits, so frame contents may have moved.

---

## Issue A: measureInputOffset - average several buffers with the outputs at zero

**Problem.** `measureInputOffset` (formerly `measureOffset`) averages one buffer of AI (`DSP: Measure DAQ Offset`: `Multiply Waveform by Input Gain` -> `Basic Averaged DC-RMS` -> `Set DAQ InputOffset`). The Generator's waveforms are 1 to 2 buffers behind the AI, so that buffer can still contain the old AO signal. One buffer is also noisy.

**Units.** InputOffset is in card volts (before the input gain): `Subtract Input Offset from Waveform.vi` multiplies by the input gain, subtracts, then divides again, and the measurement multiplies by the input gain before averaging. That matches OutputOffset in DAC volts (#188).

**Proposal: a counted macro.**

`measureInputOffset` gets an optional parameter: `{"buffers": 10, "settle": 2, "timeout": 20}` (all optional; defaults shown).

State to add to the DAQ class (or the SMO state cluster):

- `Offset Measurement` cluster: `phase` enum {idle, settling, averaging}, `settle remaining` (I32), `buffers remaining` (I32), `sum` ([DBL], one per AI), `sum of squares` ([DBL]), `count` (I32), `timeout remaining` (I32 buffers).
- Saved outputs: the existing `Saved Amplitudes` plus the saved DC offsets (today only amplitudes are zeroed).

Flow:

1. **`Macro: Measure InputOffset`** (from the event): refuse with an error if a sweep is running or acquisition is stopped. Save each AO channel's `Amplitude` and `Offset` (DC), set both to 0, queue `Data: Process AO Channels`. Initialize the cluster: phase `settling`, counters from the parameters, sums zeroed. Leave REF alone.
2. **Per buffer** (`Macro: DSP` queues `DSP: Measure DAQ Offset` while phase is not idle):
   - **settling**: do not count buffers blindly. The waveforms event carries the AO waveforms of the same buffer, so wait until every AO waveform in the buffer is within a small threshold of 0 (or of `-OutputOffset[i]`, see below), then count down `settle` more buffers for analog and filter settling. Decrement `timeout remaining` on every buffer; at 0, restore, set phase idle, raise an error.
   - **averaging**: add each AI channel's mean (card volts) to `sum`, its square to `sum of squares`, decrement `buffers remaining`.
   - At 0: offset = `sum / count`, write it with `Set DAQ InputOffset`, publish `getInputOffset`, restore the saved amplitudes and DC values, queue `Data: Process AO Channels`, phase idle. The spread (`sqrt(sum of squares / count - mean^2) / sqrt(count)`) can be published too, as a quality figure.
3. **Measure the raw AI, not the corrected AI.** `DSP: Filter` writes the offset-subtracted AI back into the class. If `DSP: Measure DAQ Offset` reads that, it measures the residual, and storing the residual as the offset alternates between the offset and about 0 on successive runs. Either read the AI before `Subtract Input Offset from Waveform.vi` (queue the measurement before `DSP: Filter`, or keep a raw copy), or store `old offset + residual`. The first is simpler.

Details to settle:

- **What "zero" means.** With #188, an AO set to 0 sends `-OutputOffset[i]` to the card, so the device sees a true 0. The InputOffset then measures the AI chain's offset plus whatever the setup produces at true zero bias. That is usually what you want; note it in HELP.
- **Commands during the measurement.** A `setAO` during the macro would be overwritten by the restore. Simplest: reject AO commands with an error while the phase is not idle. The DAQ state enum already has `calibrating`, which could be reused.
- **AC-coupled channels** (4431 coupling setting) have no DC to measure: skip them and keep their offset at 0.
- **Range dependence.** A 446x's input offset depends on the AI range. Either clear the InputOffset on a range change or ask for a new measurement (log a warning).
- **Stepping the sample to 0 V.** Zeroing the outputs is a step on every AO. If samples can be sensitive to that, ramp, or document that the user must bring the outputs to 0 first.
- `zeroOffset` (`DSP: Zero DAQ Offset`) stays as is.

**Test (simulated).** Set AO1 to 1 V DC with an AC amplitude, `measureInputOffset {"buffers": 5}`, then `getInputOffset` returns 12 values near 0, and `getAO` shows the original AO again. Run it twice; the second result matches the first, which checks point 3.

---

## Issue B: measuring OutputOffset - what is possible

Your instinct is right that a plain AO -> AI loopback is circular. With output error `e_out` and input error `e_in`, a loopback at 0 reads `e_out + e_in` (scaled by the gains). Zeroing the outputs and measuring the input (issue A) gives the same sum if the AI is wired to that AO. You cannot separate the two terms without a **second, independent zero reference**. The superconducting gap is one such reference; ground is the cheapest one. Options, from least to most physics:

1. **DAQ self-calibration.** The card's own AI and AO offsets are the business of the DAQmx self-cal, which the lock-in already runs (`DAQ: CALIBRATE`). I am not certain that 446x self-cal adjusts the AO offset as well as the AI; worth checking in the device manual. If it does, OutputOffset is mainly for offsets outside the card (amplifiers, sample wiring), which no loopback at the card can see.
2. **Two-step loopback with ground as the reference (semi-automatic).**
   1. Measure each AI's offset with its input **terminated or shorted** (not connected to an AO): issue A's macro, run once on that wiring. This pins `e_in` to ground.
   2. Loop AO k to AI j. `measureOutputOffset {"AO": k, "AI": j}` reuses issue A's machinery: all outputs to 0, average AI j after the InputOffset correction, and the residual is `e_out` in card volts at AI j, which becomes `old OutputOffset[k] + residual / (input gain chain)`. Writing old plus residual makes repeated runs converge.

   It needs one wiring change per AO, but it is not circular because step 1's reference is ground, not the AO.
3. **Two-point or symmetry fit on the sample (in the client).** For an ohmic sample read through a current preamp whose own offset is already in the InputOffset: apply `+v` and `-v` around the current DC and measure `I+` and `I-`. For `I = (V - V0) / R`, the offset is `V0 = -v (I+ + I-) / (I+ - I-)`. For a superconducting gap, use the centre of symmetry of `dI/dV(V)` from a sweep (the mean of the two coherence-peak positions). This is the "physical system" method automated. It depends on the device, so it belongs in the client (the Transport experiments or the Python configurator), which then calls `setOutputOffset`. The lock-in only needs to provide the API it now has.

Recommendation: do issue A now. For issue B, check what 446x self-cal covers, then decide between adding `measureOutputOffset` (option 2) and leaving it to client-side fits (option 3). Option 3 needs nothing more in the lock-in.

Order to document: InputOffset first (with terminated inputs if possible), then OutputOffset. Measuring the input through an untrimmed output folds the output's error into the InputOffset.
