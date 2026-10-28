# Issue #189 - measureInputOffset: average several buffers with the outputs at zero (change spec)

Read with lvkit on `develop` at e5f38c4b (2026-10-27), and baselined on the simulated lock-in (port 29170). Units are settled: InputOffset stays in card volts (before the input gain); OutputOffset is in amplified units (#188).

## What the code does today

- **Entry.** The JSON-RPC command is the local (undocumented) `setOffsetMode` with params `["Measure"]` or `["Remove"]` (`Offset Mode--Enum`). `Handle Command.vi` calls `DAQ.measureInputOffset.vi` or `DAQ.zeroOffset.vi`. The UI's "Measure Offset" button goes the same way. HELP does not list `setOffsetMode`.
- **DAQ event [17]** (`measureOffset : TF`) sets the state flag `measureInputOffset` and queues `Macro: Measure InputOffset`.
- **`Macro: Measure InputOffset`** queues, in one go: `DSP: Zero DAQ Offset`, `Data: Zero Amplitude`, `DSP: Measure DAQ Offset`, `Data: Restore Amplitude`. All four run before the next buffer arrives.
- **`DSP: Measure DAQ Offset`** reads the AI stored in the class, multiplies by the input gain (card volts), takes `Basic Averaged DC-RMS for N Chan`, writes it with `Set DAQ InputOffset`, publishes `getInputOffset`, and clears the flag.
- **Per buffer:** event [35] stores AO (times OutputGain, plus OutputOffset: user units) and AI (divided by InputGain) into the class and queues `Macro: DSP`, which queues `DSP: Simulate` (empty now), `DSP: Phase` (AO/REF only), `DSP: Filter`, `DSP: Lockin`. `DSP: Filter` runs `Subtract InputOffset from Waveform.vi` and writes the corrected AI back into the class.

### Baseline (simulated, AO1 = 0.05 V DC + 0.01 V sine, looped back to AI1)

| Run | InputOffset AI1 stored | AI1 mean afterwards |
| --- | --- | --- |
| `setOffsetMode ["Measure"]` #1 | 0.0499 | 0.0015 |
| #2 | 0.0002 | 0.0512 |
| #3 | 0.0506 | 0.0009 |

This confirms three faults:

1. **The outputs are never at zero for the measured buffer.** `Data: Zero Amplitude` changes the class but queues no `Data: Process AO Channels`, `Data: Restore Amplitude` runs straight after, and only amplitudes are zeroed (DC is left on). AI1 measured the full 0.05 V.
2. **It measures the corrected AI.** The stored AI has already had the old offset subtracted by `DSP: Filter`, so each run stores the residual, and the offset alternates between about 0.05 and about 0.
3. **One buffer.** No averaging, and on the simulated AI10 to AI12 (a large slow signal) the stored offsets jump between -18 and +15 V from run to run.

## Design

A counted measurement that runs across buffers. Only the DAQ engine (`Instrument.DAQ`) holds the state; the lock-in only forwards the request.

### API

- **New public command `measureInputOffset`** in `Lockin.Commands--Enum`, params (all optional, defaults shown):
  `{"buffers": 10, "settle": 2, "timeout": 5, "channels": []}`
  - `buffers`: buffers averaged once the outputs are at zero.
  - `settle`: extra buffers skipped after the outputs first read zero (analog and filter settling, and the 1 to 2 buffer AO lag).
  - `timeout` (s): longest wait for the outputs to reach zero; converted to buffers at start as `ceil(timeout * Fs / #s)`.
  - `channels`: AI channel numbers (1-based) to measure; empty means all. Unlisted channels keep their offset. Useful when some AI are wired to something that is not zero when the outputs are (the simulated AI10 to AI12 are an example).
  - Reply: returns at once (the measurement is asynchronous); the client waits on `getState` (below), then reads `getInputOffset`.
- **`setOffsetMode ["Measure"]`** stays, and runs `measureInputOffset` with the defaults. `["Remove"]` (`zeroOffset`) is unchanged.
- **`getState`** returns a new value, `measuring offset`, while the measurement runs, then the previous state. This adds one value to `Status--enum` (append it last so existing values keep their numbers). Clients that compare against `idle`, `started`, `sweeping` are unaffected.
- **HELP** entry for `measureInputOffset` (Get SMO HELP.vi): "Measures the AI offsets in DAQ card units. Sets every AO amplitude and DC to 0 (the card receives -OutputOffset/OutputGain, so the device sees 0 V), waits for the outputs to settle, averages `buffers` buffers of raw AI, stores the means as InputOffset, then restores the AO settings. Asynchronous: getState is `measuring offset` until it finishes."

### Wire path

1. `Handle Command.vi`: new frame for `measureInputOffset` parses the cluster above (`JSON to LVtype` ignores missing keys, so give the typedef constant the defaults, not zeros) and calls `DAQ.measureInputOffset.vi` with it. The `setOffsetMode` "Measure" frame passes the default constant.
2. `DAQ.measureInputOffset.vi`: add a `Measure InputOffset Config` cluster input (`buffers`, `settle`, `timeout`, `channels`); the private event's data type changes from `TF` to that cluster. New typedef: `PrivateEvents--DAQ.measureInputOffset`.

### DAQ engine state

Replace the state-cluster field `measureInputOffset : TF` with an `Offset Measurement` cluster (new typedef):

| Field | Type | Meaning |
| --- | --- | --- |
| `phase` | enum {idle, zeroing, settling, averaging} | |
| `config` | `Measure InputOffset Config` | as received |
| `settle remaining` | I32 | |
| `buffers remaining` | I32 | |
| `timeout remaining` | I32 | in buffers |
| `sum` | [DBL] | one per AI, card volts |
| `count` | I32 | buffers summed |
| `saved AO` | AO config array (`Cfg_AO` type) | the full AO configuration to restore |
| `previous status` | `Status--enum` | to restore `DAQ Status` |

`Saved Amplitudes` and `Zero AO Amplitudes.vi` / `Restore AO Amplitudes.vi` are no longer needed once the whole AO config is saved and restored (delete them, and remove them from disk: VIPM error 43 otherwise).

### Frames

1. **Event [17]** (measureInputOffset event): if `phase` is not idle, `DAQ Status` is `sweeping`, or acquisition is not started, log an error and do nothing. Otherwise store `config` and queue `Macro: Measure InputOffset`.
2. **`Macro: Measure InputOffset`** (replaces today's four-state list):
   - `saved AO` = current AO config; `previous status` = `DAQ Status`; `DAQ Status` = `measuring offset`.
   - Set every AO channel's `Amplitude` and `Offset` (DC) to 0 in the class (new support VI `Zero AO Outputs.vi`: in class, out class and the saved config).
   - Counters from `config`; `sum` = zeros sized to the AI count; `count` = 0; `phase` = `zeroing`.
   - Queue `Data: Process AO Channels` (this applies the OutputOffset and gain, so the card gets `-OutputOffset/OutputGain`).
   - Do not touch InputOffset here (today's `DSP: Zero DAQ Offset` call goes away), so the lock-in keeps its correction until the new value is ready, and an aborted measurement leaves the old one.
3. **`Macro: DSP`**: when `phase` is not idle, insert `DSP: Measure InputOffset Step` before `DSP: Filter` (after `DSP: Phase`). That frame then sees the AI exactly as event [35] stored it: divided by the input gain, with no offset subtracted.
4. **`DSP: Measure InputOffset Step`** (rename of `DSP: Measure DAQ Offset`), one call per buffer:
   - Decrement `timeout remaining`; at 0 while `zeroing` or `settling`: restore (step 5 without writing the offset), log "measureInputOffset: outputs did not reach 0 V", stop.
   - `zeroing`: if every enabled AO waveform in the class (user units) has max |Y| below 1 mV, go to `settling`. Else stay.
   - `settling`: decrement `settle remaining`; at 0 go to `averaging`.
   - `averaging`: `Multiply Waveform by InputGain` (card volts), `Basic Averaged DC-RMS` (as today), add the DC array to `sum`, `count`++, decrement `buffers remaining`; at 0 go to step 5.
5. **Finish**: new offsets = `sum / count` for the listed channels, the old offsets for the rest; `Set DAQ InputOffset`; publish `getInputOffset` (as `DSP: Measure DAQ Offset` does today); restore `saved AO` into the class; queue `Data: Process AO Channels`; `DAQ Status` = `previous status`; `phase` = idle.
6. **AO commands while measuring** (events [4] DAQ AO, [6] setAOconfig, [33] AOconfig, the setAO_* events, sweep start): abort. Set `phase` = idle and `DAQ Status` = `previous status`, keep the new command (do not restore `saved AO`), leave InputOffset unchanged, log "measureInputOffset aborted by an AO command". Rejecting the command instead would need a synchronous error path to the client, which the DAQ events do not have; aborting never fights the user.

### Notes for HELP or the README

- **What zero means.** With #188, an AO at 0 sends `-OutputOffset/OutputGain` to the card, so the device sees a true 0 V; the InputOffset is the AI chain's offset plus whatever the setup produces at true zero bias.
- **Order.** Measure InputOffset first (inputs terminated if possible), then OutputOffset, or the output error folds into the input offset.
- **Range dependence.** A 446x input offset depends on the AI range; measure again after changing it.
- **Step on the sample.** The measurement steps every AO to 0 V and back. Ramp or zero the outputs first if a sample cannot take the step.
- **AC-coupled AI** (4431) read about 0; measuring them is harmless. Exclude them with `channels` if wanted.
- `zeroOffset` / `setOffsetMode ["Remove"]` stays as is.

## Edit list

| # | File | Change |
| --- | --- | --- |
| 1 | `Lockin.Commands--Enum.ctl` | append `measureInputOffset` |
| 2 | new `Measure InputOffset Config--Cluster.ctl` | `buffers` I32 = 10, `settle` I32 = 2, `timeout` DBL = 5, `channels` [I32] |
| 3 | `Instrument.Lockin/Overrides/Handle Command.vi` | new frame; `setOffsetMode` Measure passes the default config |
| 4 | `Instrument.Lockin/Overrides/Get SMO HELP.vi` | HELP entry above |
| 5 | `DAQ.measureInputOffset.vi` + new `PrivateEvents--DAQ.measureInputOffset` | config input, event data = config cluster |
| 6 | `Status--enum.ctl` | append `measuring offset` |
| 7 | new `Offset Measurement--Cluster.ctl` | fields above; replaces `measureInputOffset : TF` in the DAQ state cluster (update `Data: Initialize`) |
| 8 | new `support/Zero AO Outputs.vi` | zero Amplitude and Offset of every AO, return the saved config |
| 9 | `Instrument.DAQ/Process.vi` | event [17]; `Macro: Measure InputOffset`; `Macro: DSP` insertion; `DSP: Measure InputOffset Step`; finish; abort in the AO events |
| 10 | delete `Zero AO Amplitudes.vi`, `Restore AO Amplitudes.vi`, `Data: Zero Amplitude`, `Data: Restore Amplitude`, `Saved Amplitudes` | once unused; remove from disk |
| 11 | UI "Measure Offset" button | unchanged path (`setOffsetMode` Measure, defaults) |

## Test plan (simulated lock-in, AO1 looped back to AI1)

Start with acquisition started, InputOffset 0, OutputOffset 0, output gain 1, AO1 = 0.05 V DC + 0.01 V sine (stay inside the simulated ±0.1 V AO range).

| # | Request | Expected |
| --- | --- | --- |
| 1 | `measureInputOffset {"buffers": 5}`; poll `getState` | `measuring offset` for about (2 + 2 + 5) buffers (~1.2 s at 12000 samples / 96 kHz), then `started` |
| 2 | after 1: `getInputOffset`, `getAOconfig`, AI1 mean | AI1 offset within ±0.0005 (not 0.05); AO1 back at 0.05 / 0.01; AI1 mean 0.05 |
| 3 | repeat 1 twice | each AI1 offset within ±0.0005 of run 1 (no alternation) |
| 4 | `channels: [1, 2]` with AI3's offset first set to 0.007 | AI1, AI2 updated; AI3 still 0.007 |
| 5 | OutputOffset AO1 = 0.02, then measure | AI1 offset about -0.02 (the card got -0.02 for a true 0 V, and the simulation's loopback has no external offset): confirms OutputOffset is applied while zeroing |
| 6 | `setAO_DC` during the measurement | state back to `started`; the new DC kept; InputOffset unchanged; error logged |
| 7 | `measureInputOffset` while sweeping | refused, error logged, nothing changes |
| 8 | `setOffsetMode ["Measure"]` | same as 1 with the defaults (10 buffers) |
| 9 | `setOffsetMode ["Remove"]` | all InputOffsets 0 |
| 10 | `HELP ["measureInputOffset"]` | the description above |
