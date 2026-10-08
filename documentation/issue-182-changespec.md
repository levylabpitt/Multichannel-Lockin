# Issue #182 - simulated AI has only as many channels as AO (change spec)

Instructions first; the evidence is at the bottom. Scope is deliberately small: move the existing simulation from Instrument.DAQ into the DAQmx process and fix its shape, without changing what the three simulation modes do. The waveguide model stays, with its math unchanged.

## Changes

| # | What | Why | Priority |
|---|---|---|---|
| 1 | Channel map built in Create, stored in the class | AO/AI pairing must use the same per-device split as `DAQmx.Write.vi` | **done** 2026-10-08 |
| 2 | `DAQmx.Simulate AI.vi` inside `Sync.Acquire.vi`, before AI is stored | simulated AI keeps the acquired shape (12 waveforms), only Y changes | **open**, the fix |
| 3 | Forward `Simulation mode` (and waveguide inputs) to DAQmx | DAQmx needs the mode; today it only lives in Instrument.DAQ | **open**, needed by 2 |
| 4 | Remove the simulation from Instrument.DAQ | one place simulates, and it is at the hardware boundary | **open**, after 2 and 3 |
| 5 | Guards: Mixer range check, empty-Y pass-through in `DFD Filter Array.vi` | one empty channel must not stop every result | **open**, independent |
| 6 | `Create Low Pass Filter (FGV).vi`: change detection fixed, bad-input guard | filter was designed once and never redesigned | **done** 2026-10-07 |

### Change 1 - channel-map helper

`src/DAQmx/private/DAQmx.Write.vi`, first for-loop: per AO task it reads `DAQmx Task` > `NumChans` and `Devices`, and takes `Array Subset(AO, offset, NumChans)` with the offset in a shift register (init 0, += `NumChans`). The AO array is therefore the concatenation of every task's channels in task order, and the AI read is laid out the same way over the AI tasks.

**As built (2026-10-08).**

- `src/DAQmx/private/DAQmx.Get Channel Map.vi`: task array in, array of `DAQmx.Channel Map--Cluster.ctl` out, one element per task in task order: `{Task, Device, Offset, Count}`. `Device` is `Devices[0]`; `Count` is the task's `NumChans` (channels in the task, not channels on the card); `Offset` is the running sum of the earlier tasks' counts, i.e. the index of the task's first waveform in the joined array.
- Built for the AO and the AI tasks in Create and stored in the class (`AO Map`, `AI Map`). Tasks are only created or replaced inside Create (`DAQmx Replace Existing Task.vi` is called only from `DAQmx.Create AI Tasks.vi` / `DAQmx.Create AO Tasks.vi`), and recovery re-runs Create, so the maps always match the tasks. After `DAQ: CLEAR` they hold dead refnums until the next Create, which is harmless because only `DAQ: ACQUIRE` uses them.
- `src/DAQmx/private/Get Device Waveforms.vi`: map entry + waveform array -> `Array Subset(waveforms, Offset, Count)`.
- Should a task ever report more than one device, `Devices[0]` is wrong; the map builder should return an error rather than silently use the first.
- Optional: make `DAQmx.Write.vi`'s first loop iterate over `AO Map` instead of reading `NumChans`/`Devices` on every write. That also removes per-write property reads (issue-160 underflow spec, Change 3).

### Change 2 - simulate in DAQmx, starting from the acquired AI

**Where.** `src/DAQmx/Sync.Acquire.vi`. It runs `DAQmx.Read.vi` and `DAQmx.Write.vi` in parallel on the incoming class. The write's No Error frame clears the `Recovery.Pending` fields; its class output (`case_1394::out1`) already carries the `Waveforms.AO` that `DAQmx.Write.vi` stored through its delay-2 feedback node. The read's No Error frame bundles `AIwfm` into `Waveforms.AI` on that class wire (lvkit prints the field as `REF_Y`; labels are scrambled, it is the field `AIwfm` goes into).

Insert `DAQmx.Simulate AI.vi` in the read's No Error frame, between `AIwfm` and that Bundle: class in = `case_1394::out1` (maps, simulation settings, paired `Waveforms.AO`), AI in = `AIwfm`, AI out -> the Bundle into `Waveforms.AI`. Consequences:

- A failed read never simulates.
- `setWaveforms.vi` (and anything else downstream) only ever sees the simulated AI.
- `Test Sync*.vi` exercise the simulation too; with the mode left at "AI = HW simulated" it passes through and the tests behave as before.
- If the write fails and the read succeeds, `Waveforms.AO` still holds the previous block, so one stale block is looped back; the write error sends the process into recovery anyway.

`Waveforms.AO` is the AO block that pairs with the AI block just read (issue-160 change spec, Change 2 as built), so the loopback has the same AO-to-AI pairing as real hardware.

**Output.** The AI array with the same number of waveforms, the same t0, dt and attributes, and only Y replaced.

**Body.**

1. Skip everything (pass the class through) unless at least one device has `DevIsSimulated` = T. Use the DeviceInfo array DAQmx already holds (`DAQ: Query Hardware`). Only replace Y on AI channels whose device is simulated, so a mixed real + simulated setup also works.
2. Read `AO Map` and `AI Map` from the class (Change 1).
3. `Simulation mode` (Change 3):
   - **"AI = HW simulated"**: pass `Waveforms.AI` through unchanged. (Today this mode returns a copy of AO; that was the bug, not a feature.)
   - **"AI = noise*AO"**: for each AI map entry, find the AO map entry with the same `Device` (match by name, not by index). For `k` in `0 .. Count_AI - 1`: if `k < Count_AO`, set `AI[Offset_AI + k].Y = AO[Offset_AO + k].Y`; otherwise keep the acquired Y. Then run `Add Noise.vi` over the whole AI array (it only needs the waveforms and the sampling cluster, no Instrument.DAQ data).
   - **"AI = waveguide"**: first do the noise*AO loopback above (that is what the non-model channels got before: a copy of AO by index). Then run the waveguide model, unchanged, and write its outputs into the AI channels at the `Waveguide Model--Cluster` indices (I+, I-, V+, V-, Vsg) instead of into a copy of AO. Then `Add Noise.vi`.
4. If AO and AI Y lengths differ (they should not; both are #s), truncate or pad AO Y to the AI length so the AI waveform keeps its sample count.

For this rig: 4461 (x4) ao0->ai0, ao1->ai1; 4431 ao0->ai0, ai1-ai3 keep the simulated hardware signal. If all four 4431 inputs should carry ao0, change the rule to "if `k >= Count_AO`, use `AO[Offset_AO + Count_AO - 1]`".

**Waveguide port.** `src/Instrument.DAQ/support/Simulate/Simulate Waveguide.vi` reads two things from Instrument.DAQ:
- the AI input gain array (`[Channel.Gain--Cluster]`, lvkit prints the label as `returnToStart`; identify it by type), indexed at I+, I-, V+, V-, used to scale the model outputs;
- a side effect: if the I+ or I- gain is 1, it sets both to 50000, writes them back and calls `DAQ.getInputGain.vi` to publish.

To keep the math without dragging Instrument.DAQ into DAQmx:
1. Copy the VI to `src/DAQmx/Simulate/Simulate Waveguide.vi`. Replace the `Instrument.DAQ in/out` terminals with an `Input Gain` input (`[Channel.Gain--Cluster]`) and an `AI` input; output the AI array with the five channels replaced (not a copy of `AO`).
2. Delete the 50000 side effect from the copy. Move it to Instrument.DAQ, run once when the waveguide mode is selected (see Change 3), not on every block.
3. Move `Add Noise.vi`, `Waveguide Model.vim`, `Waveguide Model--Cluster.ctl` and `Simulation Mode--enum.ctl` with it (into `src/DAQmx/Simulate/`, members of `DAQmx.lvclass` or a small library). Leave `Simulation Mode--enum.ctl` as the single typedef; Instrument.DAQ and the UI link to the new path.
4. Drop the block-pacing wait from `DAQ.Simulate Noisy AI.vi`. It is multiplied by 0.0 today, so it never waits; the simulated tasks already pace the loop.

### Change 3 - give DAQmx the simulation settings

`Simulation mode` reaches Instrument.DAQ with `setAIconfig` (`PrivateEvents--DAQ.setAIconfig = {AI Configuration, Simulation mode}`, handled in `src/Instrument.DAQ/Process.vi`). Forward it to DAQmx the same way the AI configuration is forwarded (check the path in that handler; DAQmx has `private/setAIconfig(private).vi`), and store it in a DAQmx class field.

The waveguide additionally needs the `Waveguide Model--Cluster` (today a constant `{I+ 0, I- 1, V+ 2, V- 3, Vsg 4}` wired in the `DSP: Simulate` frame) and the AI input gain array. Send both to DAQmx with the mode, and send the gains again whenever `setInputGain` changes them while the mode is waveguide. When the mode is set to waveguide, Instrument.DAQ applies the I+/I- = 50000 default (if they are 1) and publishes it, as `Simulate Waveguide.vi` does today.

### Change 4 - remove the simulation from Instrument.DAQ

Only after Changes 2 and 3 work:
1. `src/Instrument.DAQ/Process.vi`: remove `DSP: Simulate` from the queued string `'DSP: Simulate\nDSP: Phase\nDSP: Filter\nDSP: Lockin'` and delete the `DSP: Simulate` frame.
2. Delete `src/Instrument.DAQ/support/DAQ/DAQ.Simulate Noisy AI.vi` and the old copies in `src/Instrument.DAQ/support/Simulate/` (update `Tests/Test Resampling.vi`, which links `Add Noise.vi`).
3. Save All, then check that the `.lvclass`/`.lvproj` no longer list the deleted files.

### Change 5 - guards

Independent of the move; protects against any future channel-config mismatch.

1. `src/DSP/Lockin.Mixer.vi`: inside the per-reference loop, skip the pair (same as the existing `References = 0` frame: conditional tunnel False) when `Channel - 1 >= size(AI)`, `r - 1 >= size(Ref_X)`, or the indexed AI or reference waveform has an empty Y. Today the out-of-range `Index Array` returns a default (empty) waveform and the product is empty.
2. `src/DSP/DFD Filter Array.vi`: in the inner per-waveform loop, if the waveform's Y is empty, skip `IIR Cascade Filter with I.C.` and pass the waveform and that channel's filter state through unchanged. Note that `Lockin.Low Pass Filter (subVI).vi` only checks for an empty array of waveforms, not for a waveform with an empty Y.

### Change 6 - FGV change detection (done 2026-10-07)

`src/DSP/Create Low Pass Filter (FGV).vi`: the three feedback nodes that remember cutoff, fs and order had their initializers wired to the current values. The while loop runs once per call, so they re-initialized every call, every `Not Equal?` was False, and the filter was designed only on `First Call?`. Fixed by unwiring the initializers. Added an outer case on `NaN?(coerced cutoff) OR NaN?(fs) OR fs <= 0`; the feedback nodes and the design sit in its False frame, so a bad input leaves the stored filter and remembered values alone. To confirm: the True frame must return an error and `init out` = F, otherwise a first call with bad fs stores an empty filter array and DFD Filter Array passes data through unfiltered with no error. `Create Low Pass RC Filter (FGV).vi` (the one the lock-in filter bank uses) already had constant-0 initializers and an `fs <= 0` guard.

## Checks

- Simulated rig (4x 4461 + 4431), each mode: AI has 12 waveforms with their own channel names and #s samples; no -20003; lock-in results publish for references on AI 10-12.
- "AI = HW simulated": AI equals what the simulated tasks returned.
- "AI = noise*AO": on each 4461, ai0/ai1 follow ao0/ao1 of the same card; on the 4431, ai0 follows its ao0.
- Waveguide: the five model channels match the old output for the same AO (compare against the old VI on one block).
- Real hardware: unchanged (the simulation is skipped unless a device is simulated).
- Unit tests: `Tests\` (Caraya) and `src/DAQmx/Tests/Test Sync*.vi` still pass.

## Evidence

Read with lvkit on `develop` at 2abf1abd plus the uncommitted FGV fix.

- `DAQ.Simulate Noisy AI.vi`, True frame (any device simulated): unbundles one `[MeasureData]` field, cases on `Simulation Mode--enum`, writes the result into another `[MeasureData]` field. "AI = noise*AO" -> `Add Noise.vi(array)`; "AI = HW simulated" -> the array unchanged; "AI = waveguide" -> `Add Noise(Simulate Waveguide(AO = array))`. The input is AO: `Simulate Waveguide.vi` takes it on its `AO` terminal. The output is AI. So every mode sets AI to something shaped like AO.
- Device counts: PCI-4461 = 2 AI / 2 AO, USB-4431 = 4 AI / 1 AO; 4x 4461 + 1x 4431 = 12 AI / 9 AO. Probe of `Lockin.Low Pass Filter.vi`: X/Y waveforms 0-8 have data, the ones after 8 have empty Y.
- `Lockin.Mixer.vi`: X = `AI[Channel-1]` x `Ref_X[r-1]` via plain `Index Array` (no range check); out of range gives a default waveform with empty Y, and the product is empty.
- -20003 is "Analysis: The number of samples must be > 0" (`resource\errors\English\Analysis-errors.txt`), returned by `IIR Cascade Filter with I.C.` for an empty `X`. `DFD Filter Array.vi` runs its inner loop over every waveform in `signal in` and feeds each Y to it.
- `Simulate Waveguide.vi` output is `Replace Array Subset(AO, ...)` at the I+, I-, V+, V-, Vsg indices, so the waveguide mode is AO-shaped too.
- `DAQ: ACQUIRE` in `src/DAQmx/Process.vi`: `getWFMQueue.vi` -> `Sync.Acquire.vi` (`DAQmx.Write.vi` + `DAQmx.Read.vi`) -> `setWaveforms.vi`.
