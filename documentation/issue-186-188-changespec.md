# Issues #186 and #188 - gain tracking and OutputOffset (change spec)

Reviewed 2026-10-27 against `develop` at `80b31441` plus the uncommitted `measureOffset` -> `measureInputOffset` rename in the working tree. Everything below was read with `lvkit describe --format lvnet`. lvkit scrambles class private-data field labels, so fields are identified by type (`[Channel.Gain--Cluster]`, `[Channel.Offset--Cluster]`, `[AO.Channel--Cluster]`, AI vs AO config cluster) and by which frames of the same VI touch the same label. Items marked **(confirm)** should be checked at runtime (test plan below) or in LabVIEW's render before editing.

## Where things stand

| Piece | State |
| --- | --- |
| #186: lock-in handles DAQ `getInputGain` / `getOutputGain` / `getInputOffset` / `getOutputOffset` events | Done. `Instrument.Lockin/Process.vi` events 11 to 14 store the array and send `setData_InputOffset` / `setData_InputGain` / `setData_OutputOffset` / `setData_OutputGain` (Local enum 26, 19, 27, 20) |
| #186: `getOutputGain` returns the engine's array | Broken by B1 and probably B2 below |
| #188: `setOutputOffset` / `getOutputOffset` in `Lockin.Commands--Enum` | Done (36, 37; also `setInputOffset` 34, `getInputOffset` 35) |
| #188: `Handle Command.vi` set/get frames | Done for all four offsets and gains; `setOutputGain` frame has bug B1 |
| #188: HELP entries in `Get SMO HELP.vi` | Done, with a typo (B5) |
| #188: API wrappers `API/getOutputOffset.vi`, `setOutputOffset.vi`, `getInputOffset.vi`, `setInputOffset.vi` | Done, enum values correct |
| #188: DAQ engine stores the offset, resizes it, publishes `getOutputOffset` | Done, but sized from the AI config (B3) |
| #188: offset applied to the AO output | Wired into `Data: Process AO Channels`, but the VI divides instead of subtracting (B4) |
| #188: offset on the return paths (Generator echo, AO waveforms) and in sweeps | Missing (M1 to M3) |
| #188: persisted | Yes, through the UI's INI: `UI.Configuration--Cluster` -> `Amplifers : Channel.GainsAndOffsets--Cluster {InputOffset, InputGain, OutputOffset, OutputGain}` (confirm the UI re-sends it at startup) |
| #188: logged | No. `Lockin.LogConfiguration.Channels--Cluster` has neither gains nor offsets (D3) |

## Bugs

### B1 - lock-in `setOutputGain` stores the gains in the OutputOffset cache (high confidence)

`Instrument.Lockin/Overrides/Handle Command.vi`, the `setOutputGain` frame (the one that calls `DAQ.setOutputGain.vi`): it builds a `[Channel.Gain--Cluster]` from the JSON, bundles it into the class, then unbundles a field whose element type lvkit reports as `Channel.Offset--Cluster` and sends those values to `DAQ.setOutputGain`. Within this VI that label is the one the `setOutputOffset` frame writes and the `getOutputOffset` frame reads. The `getOutputGain` frame reads a different field. The two cluster typedefs are structurally identical (`{String, DBL}`), so LabVIEW coerces silently and the VI is not broken. It looks like the frame was duplicated from `setOutputOffset` and only the constant was changed.

Effect: `setOutputGain` overwrites the lock-in's OutputOffset cache with the gains (`getOutputOffset` echoes them), and leaves its OutputGain cache untouched until the engine's `getOutputGain` event arrives.

Fix: in the `setOutputGain` frame, point both the Bundle By Name and the following Unbundle By Name at the OutputGain field (the one the `getOutputGain` frame reads). Compare with the `setInputGain` frame, which is correct.

### B2 - DAQ engine `setOutputGain` event writes the OutputOffset field (confirm)

`Instrument.DAQ/Process.vi`, event 14 (the private `setOutputGain` event, which queues `Data: Process Output Gain`): it bundles the incoming gains into the same field that event 13 (`setOutputOffset`) writes. `Data: Process Output Gain` then re-initializes and publishes the unchanged OutputGain field, so the new gains are never applied and `getOutputGain` reports the old ones. lvkit also shows event 14's event-data type as `PrivateEvents--DAQ.setInputGain`; check that the event is registered on the `setOutputGain` refnum, not `setInputGain`.

Fix: bundle into the OutputGain field (the one `Initialize Ouput Gain.vi` reads). Note that B4 currently divides the AO values by the "offset" field, which after B2 holds the gains, so B2 and B4 partly hide each other: fix them together.

### B3 - `Initialize OutputOffset.vi` sizes the array from the AI configuration

It counts channels from the config array whose element is `{Channels, Coupling, Range : DAQ.Config.AI.Range--enum, terminal configuration, Type}`, i.e. `Cfg_AI` (`Initialize Input Gain.vi` reads the same one). `Initialize Ouput Gain.vi` correctly reads the AO config (`Range : DAQ.Config.AO.Range--enum`, no Coupling). On the simulated rig `getOutputOffset` would return 12 values for 9 AO.

Fix: in `Initialize OutputOffset.vi`, unbundle the AO config field instead of the AI config field, as in `Initialize Ouput Gain.vi`. The `'AO'` name prefix is already right.

### B4 - `Subtract Output Offset from Amplitude and Offset.vi` divides by the offset

It is a copy of `Divide Amplitude and Offset by Output Gain.vi` with the typedef swapped: for each AO channel it replaces an offset of 0 by 1, then **divides both `Amplitude` and `Offset`** by it. A trim of 0.01 V would multiply the output by 100.

Fix (rewrite the loop body):

1. Keep the For Loop over the AO channels array and the Index Array of the OutputOffset array by `i`.
2. Delete `Equal To 0?`, `Select` and the constant 1.
3. In the In Place Element structure, unbundle only `Offset` and replace both Divides with one **Subtract**: `Offset - OutputOffset[i]`. `Amplitude` is not touched.
4. If the OutputOffset array is shorter than the AO array, Index Array returns 0 for the missing elements, which is the correct default.

Its call in `Data: Process AO Channels` moves in front of `Divide Amplitude and Offset by Output Gain.vi`, so the offset is subtracted in amplified units (D1).

### B5 - HELP frame named `getInputOffsets`

`Instrument.Lockin/Overrides/Get SMO HELP.vi` has a frame `"getInputOffsets"` (plural), so `HELP(["getInputOffset"])` falls to the default frame (confirm). Rename the frame to `getInputOffset`.

## Missing for #188

These follow the rule #165 set for the output gain: Instrument.DAQ stores and publishes user values, only the copy sent to the Generator is converted, and anything coming back from the Generator is converted back.

### M1 - Generator echo (event 37) does not add the offset back

`Data: Process AO Channels` sends trimmed values to the Generator. The Generator echoes its AO channels once per block, and event 37 runs `Merge AO Settings from Generator.vi` -> `Multiply Amplitude and Offset by Output Gain.vi` and stores the result. Without the inverse of the trim, the stored DC becomes the trimmed DC, and every later AO change trims again: the same drift #165 fixed for the gain (DC, DC - d, DC - 2d, ...).

Fix: create `Add Output Offset to Amplitude and Offset.vi` (mirror of the fixed B4 VI, `Offset + OutputOffset[i]`) and call it in event 37 on the class wire, right **after** `Multiply Amplitude and Offset by Output Gain.vi`: the inverse of the outbound order (D1), so the value is scaled back to amplified units first and the offset is added in those units.

### M2 - Sweeps are not trimmed

`Generate AO Waveforms.vi` generates AC only (offset input wired to 0). The DC comes from the sweep state machine: `Sweep States.vi` "idle" -> `Create DC Waveforms.vi` (from the AO channels' `Offset`, so B4 covers it), but while sweeping, `Continuous Sweep Waveform.vi` generates from the sweep `Start`, `End` and `Table`, which `Data: Process Sweep` converts with `Divide Sweep Config by Output Gain.vi` only. A swept channel therefore loses its trim during the sweep and jumps by `d` at the start and end.

Fix: create `Subtract Output Offset from Sweep Config.vi` (mirror of `Divide Sweep Config by Output Gain.vi`: for each `Sweep.Channel--Cluster`, look up `OutputOffset[Channel - 1]` and subtract it from `Start`, `End` and every `Table` element). Call it in `Data: Process Sweep` right **before** `Divide Sweep Config by Output Gain.vi`, on the same Generator-bound copy (the class output of `DAQ.getSweepChannels.vi`), so the offset is subtracted in amplified units and the state still stores user values (see the #165 notes in `issue-165-amplified-ao.md`).

### M3 - AO waveforms reported without the offset

Event 35 (waveforms from the Generator) runs `Multiply Waveform by Output Gain.vi` on the AO waveforms before they are stored, displayed and logged. Add `Add Output Offset to Waveform.vi` (adds `OutputOffset[i]` to the Y array of AO waveform `i`) **after** `Multiply Waveform by Output Gain.vi` (D1), so the reported AO is what was requested.

## Decisions

### D1 - Units and order (decided 2026-10-27)

The two offsets use different units, each the one it is measured in:

- **InputOffset: card volts** (before the input gain). Unchanged; it is what `Subtract Input Offset from Waveform.vi` and the measurement (#189) already use. The card's AI offset is millivolt-sized on the large ranges (446x verification limit ±7 mV at -20 dB, ±0.7 mV at 0 dB) and depends on the AI range, so it is fixed in card volts.
- **OutputOffset: amplified (user) units**, the same units as `setAO` DC, amplitude, limits and sweeps. The card's own AO offset is at most ±1 mV after calibration (446x verification limit), so a trim worth setting comes from outside the card (amplifier, sample) and is found against a physical reference at the device, in device volts.

With output gain `G`, offset `d` and requested DC `V`, the card is sent `(V - d) / G`. The output gain is 1 almost always, where both choices give the same numbers.

- Outbound (`Data: Process AO Channels`): `Limit AO Amplitude` -> `Limit AO DC` -> `Set all f same` -> **Subtract Output Offset** -> `Divide Amplitude and Offset by Output Gain` -> `Merge AO Settings to Generator`. Move the existing Subtract call in front of the Divide (B4).
- Inbound (event 37 and event 35, M1 and M3): `Multiply ... by Output Gain` -> **Add Output Offset**.
- Sweep (M2): **Subtract Output Offset from Sweep Config** -> `Divide Sweep Config by Output Gain`.

HELP descriptions, to state the units:

- `setOutputOffset` / `getOutputOffset`: "Output offsets in output (amplified) units, the same units as setAO. Values are subtracted from the requested AO values before the output gain is applied."
- `setInputOffset` / `getInputOffset`: "Input offsets in card volts (before the input gain). Values are subtracted from the acquired waveforms."

Sign: the offset is **subtracted**, so enter the error you measure at the device (the device sees +5 mV at DC 0 -> `setOutputOffset` 0.005).

### D2 - Limits (#95)

The limits clip the requested values in amplified units, before the trim and the gain division. The trim cancels the error outside the request, so the device sees the requested (clipped) value and no change is needed. The card value can differ from `V / G` by `d / G`; with millivolt trims that stays far inside the card's AO range, and DAQmx reports it otherwise. No extra clip recommended.

### D3 - Logging (your call)

Today the configuration log has no gains either. Recommended: add `Gain` and `Offset` to `Lockin.LogConfiguration.Channels--Cluster` (AO rows: OutputGain/OutputOffset; AI rows: InputGain/InputOffset) and fill them in `Format Channel Configuration Log.vi`, because a trim or a gain changes the physical signal and the log should reproduce it. This changes what is written to the database, so check the table schema first; it can also go in its own issue.

### D4 - Reporting in `getAO`

Recommended: `getAO` keeps reporting requested (user) values, and the trim is reported only by `getOutputOffset`. That is what M1 and M3 produce.

### D5 - Persistence

Already in the UI INI through `Channel.GainsAndOffsets--Cluster`. Keep it; the trim belongs to the rig, like the gain.

## Cleanups (no behaviour change)

- `Instrument.DAQ/private/DAQ.getOutputOffset.vi` bundles with a `PublicEvents--DAQ.getInputOffset` constant before generating the `getOutputOffset` event; replace it with the `getOutputOffset` typedef constant.
- `Set DAQ InputOffset.vi` (uncommitted) still uses `Gain Add or Remove.vi` and a `Channel.Gain--Cluster`; it works only because the two clusters coerce. Use `Offset Add or Remove.vi` and `Channel.Offset--Cluster`.
- The working tree deletes `DAQ.measureOffset.vi` and `Set DAQ Offset.vi`, but `Handle Command.vi` (offset-mode frame) still calls `DAQ.measureOffset.vi` and `Instrument.DAQ.lvclass` is not yet re-saved. Relink to `DAQ.measureInputOffset.vi` and save the class before committing.
- `Instrument.Lockin/Process.vi` events 11 to 14 both bundle the array into the class and send `setData_*` to itself, which writes it again. Either one is enough; keeping only `setData_*` matches the other events.
- `setInputOffset` and `setOutputOffset` exist in both `Lockin.Commands--Enum` (34, 36) and `Lockin.Commands.Local--Enum` (23, 24); the UI sends 23 and 24. Once the remote commands exist, the Local entries can go.
- `Divide Waveform by Output Gain.vi` has no callers.

## Test plan (JSON-RPC, simulated lock-in on tcp://localhost:29170)

Restart the app first. Only send valid JSON-RPC 2.0. Simulated rig: 12 AI, 9 AO. Run each "before" row now to confirm B1 to B3, then again after the edits.

| # | Request | Before the fix (expected if the bug is real) | After |
| --- | --- | --- | --- |
| 1 | `getInputGain`, `getOutputGain`, `getInputOffset`, `getOutputOffset` | 12, 9, 12, **12** values | 12, 9, 12, 9 |
| 2 | `setInputGain` with 16 values, then `getInputGain` | 12 values (#186 input side) | 12 |
| 3 | `setOutputGain [2,2,2,2,2,2,2,2,2]`, then `getOutputOffset` | **2s** (B1) | unchanged offsets |
| 4 | after 3, wait 1 s, `getOutputGain` | **old gains** (B2) | 2s |
| 5 | `setOutputGain` 9 ones; `setAO_DC` 1 V on AO1; `setOutputOffset [0.1,0,...]`; wait 1 s; `getAO` | DC about 10 (B4 divides by 0.1, and the echo is stored) | DC 1 (D4); the AO waveform also at 1 (M3); a looped-back AI, if the simulation has one, at 0.9 |
| 6 | after 5, change an unrelated AO setting twice, `getAO` | | DC still 1 (M1) |
| 7 | `setOutputGain` 2 on AO1, offset 0.1, DC 1, looped-back AI (simulation has no card error) | | card value 0.45 (`(1 - 0.1) / 2`), so 0.9 after the gain; `getAO` still 1 |
| 8 | output gain 1, sweep AO1 from 0 to 1 V with offset 0.1 | | swept card value 0.1 below the requested ramp, no step at start or end (M2) |
| 9 | `HELP ["getInputOffset"]`, `HELP ["setOutputOffset"]` | first one falls to the default text (B5) | descriptions |
| 10 | restart the app, `getOutputOffset` | | the values set before restart (D5) |
