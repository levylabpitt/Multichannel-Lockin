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

## As built (deviations from the design above)

- **Small states instead of one step frame.** `Macro: Measure InputOffset` only queues `Data: Zero AO Outputs`, `Data: Begin Offset Measurement`, `Data: Process AO Channels`. Per buffer, `Macro: DSP` inserts `DSP: Offset Measurement Phase`, `DSP: Accumulate InputOffset` and `Macro: Offset Measurement` before `DSP: Filter`. `Macro: Offset Measurement` cases on `phase` and queues the finish: `done` stores the offset (`DSP: Store InputOffset`), restores the AO and the status; `timed out` restores without storing; `aborted` (status changed, for example a sweep started) restores the AO only; `cancelled` (an AO command) restores the status only, keeping the new AO. All end in `Data: End Offset Measurement`.
- **Support VIs.** `Offset Measurement Next Phase.vi` (abort/cancel/timeout checks and the zeroing/settling transitions), `Offset Measurement Accumulate.vi`, `Offset Measurement Result.vi` (sum/count into the listed channels), `Zero AO Outputs.vi`, `Restore AO Outputs.vi`.
- **Abort detection in one place.** Instead of touching every AO event, `Offset Measurement Next Phase.vi` cancels when any AO `Amplitude` or `Offset` in the class is no longer 0, and aborts when `DAQ Status` is no longer `measuring offset`.
- **Only Amplitude and Offset are saved and restored**, not the whole AO config, so a frequency or phase change made during the measurement is kept.
- **`timeout` is a Tick Count deadline** (ms) rather than a buffer count, so no Fs or #s lookup.
- **`phase`** gained `done`, `aborted`, `cancelled`, `timed out`; the cluster holds `deadline` instead of `timeout remaining`.
- **Warnings, not errors.** Refusals (`-89766`, not started or sweeping) and aborts (`-89765`) are raised as warnings. An error in the DAQ engine goes through `Error Handler` and `Macro: Post Error Handling`, which drops the queued states and queues `DAQ: STOP`, so an error would stop acquisition.
- **`getState` returns the DAQ `Status--enum` directly.** The Instrument Framework's `LockinAPI.getState.states--enum` has no `measuring offset`, so coercing to it reported `sweeping`. `Handle Command.vi` frame "21, 22" now sends `Status--enum` to To Variant.
- **`DAQ Status` tracks sweeps.** Event [36] now stores `sweeping` and `Data: Save Sweep Data` "final" stores `started` in the state cluster, not only in the published `getDAQState`. Before that, the engine's own status stayed `started` during a sweep, so a request during a sweep was accepted and ended the sweep.
- **Event [26] `setState start`** treats `measuring offset` like `created, started` (no restart). Event [18]'s stray bundle into the old `measureInputOffset` flag is gone.
- **Stale Generator echoes are filtered.** The Generator publishes its AO channels on every `Generator: Generate` (event [37]), and echoes generated before it received a new `setAOChannels` still carry the old values. Event [37] now drops every echo while `phase` is not `idle`, and otherwise checks it against a countdown `stale echo left` (I32) in the state cluster: `Data: Process AO Channels` sets it to 3; while it is above 0, `AO Echo Matches.vi` converts the echo to user units and compares every channel's `Amplitude` and `Offset` with the class (`MGI Approximately Equal`); a match merges and resets the count to 0, a mismatch is dropped and decrements it. At 0 every echo merges, so a Generator that changes values itself (a sweep) catches up within three buffers. `Merge AO Settings from Generator.vi` now includes the user-unit conversion (`Multiply Amplitude and Offset by OutputGain`, `Add OutputOffset to Offset`). This also fixes the general race where any `setAO_*` was briefly overwritten by an older echo.

## Test results (simulated lock-in, 2026-10-30)

Run with a Python JSON-RPC client against port 29170. The client snapshots gains, offsets, AO config and state first and restores them afterwards (all restored, state `idle`). Tests 6b, 7 and 7b are additions to the plan. No entries were written to the error log.

| # | Result | Observed |
| --- | --- | --- |
| 1 | PASS | `measuring offset` then `started`, 1.25 s |
| 2 | PASS | AI1 offset 0.00010; AO1 back at 0.05 DC / 0.01 amplitude on the first read; AI1 mean 0.0500 (0.0500 before) |
| 3 | PASS | AI1 offsets 0.00010, 0.00014, 0.00014 |
| 4 | PASS | AI1 0.00015, AI2 0.00015 (was 0.003), AI3 kept at 0.007, the rest unchanged |
| 5 | PASS | AI1 offset -0.01987 with OutputOffset AO1 = 0.02 |
| 6 | PASS | `setAO_DC 0.03` during the measurement: back to `started`, DC 0.03 kept, offsets unchanged |
| 6b | PASS | `setState start` during the measurement: no restart, finished in 1.78 s, AI1 offset 0.00013 |
| 7 | PASS | refused while stopped; state `idle`, offsets unchanged |
| 7b | PASS | refused while sweeping; state stayed `sweeping`, offsets unchanged |
| 8 | PASS | `setOffsetMode ["Measure"]`: finished in 1.77 s (10 buffers), AI1 offset 0.00015 |
| 9 | PASS | all InputOffsets 0 |
| 10 | PASS | HELP text as above |

Stress runs: 40 measurements alternating `setOffsetMode ["Measure"]` and `measureInputOffset {}` with 1.7 s between them, and 20 `measureInputOffset {}` calls each started as soon as the previous one ended. All completed, stored an offset and restored AO1 to 0.01 / 0.05; `getAOconfig` showed the restored values on the first read after `getState` returned `started`. Durations range from 1.2 to 1.8 s for 10 buffers.

The `buffers` default of 10 had to be set in three places: the typedef, the `measureInputOffset` control default of `DAQ.measureInputOffset.vi` (used by `setOffsetMode`, which leaves that input unwired) and the config constant in the `measureInputOffset` frame of `Handle Command.vi` (used for keys missing from the JSON). LabVIEW does not carry a typedef's new default into existing instances.

Fixed during testing: measurements that ended about 0.1 s after starting with the InputOffset unchanged. Event [37] merged a Generator echo generated before the zeroing reached the Generator, so the class showed non-zero AO and `Offset Measurement Next Phase.vi` cancelled; the AO was then left at 0. The same race just after a measurement ended let a stale all-zero echo into the class, so a measurement started at once saved zeros, and `getAOconfig` showed zeros for up to 0.1 s after `started`. Both are fixed by the echo filter above. The `-89765` warning message now reports the DAQ status, previous status, buffers averaged and the saved amplitudes and offsets.
