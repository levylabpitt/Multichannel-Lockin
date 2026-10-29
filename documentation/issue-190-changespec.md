# Change spec: remote `setLinkFrequencies` / `getLinkFrequencies` (#190)

Scope: expose the DAQ engine's frequency link as a remote command, plus a getter. `zeroPhase` is tabled (findings kept at the end for when it comes back).

## What exists today

Read with lvkit on `develop` plus the working tree (2026-10-29).

**Engine (`Instrument.DAQ`).** `DAQ.setLinkFrequencies.vi` fires the private user event `setLinkFrequencies` with `Configuration.LinkFrequencies--Cluster{Link? (TF), Frequency (Hz) (DBL)}`. The handler in `Instrument.DAQ/Process.vi` (event frame 24) does two things: it bundles the whole cluster into a field of the `Instrument.DAQ` object (identified by type; lvkit's label for it is scrambled), and it queues `Data: Process AO Channels` + `Data: Process REF Channels` in one go.

**What "link" means.** Both `Data: Process AO Channels` and `Data: Process REF Channels` call `support/Set all f same.vi` every time they run. When the stored `Link?` is True, that VI overwrites the `Frequency` of **every** AO channel and **every** REF channel (enabled or not) with the stored `Frequency (Hz)`. So `Link?` is a **persistent mode**, not a one-shot set-all:

- While linked, every later `setAO`, `setAO_Frequency`, `setREF`, `setREF_Frequency`, `setAOconfig`/`setREFconfig` still runs, but its frequency is replaced by the link frequency before it reaches the generator. A client that changes a frequency while linked gets no error and no effect.
- `Link? = False` stops the overwrite but does not restore the old frequencies; channels keep the link frequency until set again.
- Phases are not touched. AO and REF are reprocessed in the same state-machine pass, so their new frequencies reach the generator and the demodulator at the same point in time, which is the part of the use case that matters for drift.
- The link state lives only in memory: the DAQ object's field starts unlinked at launch. There is no getter in the engine.

**Lock-in (`Instrument.Lockin`).** More is already there than the issue says:

- `Overrides/Handle Command.vi` already has a frame (lvkit frame 33, present at HEAD too) that parses the payload as `Configuration.LinkFrequencies--Cluster` (default `{Link?: False, Frequency (Hz): 0}`), stores it in an `Instrument.Lockin` private field of that type, and calls `DAQ.setLinkFrequencies`. It returns no data.
- `Lockin.Commands--Enum` in the working tree already ends with `setLinkFrequencies` (item 40, after `getInputDAQ`, `getOutputDAQ`). At HEAD the enum has 38 items and no `setLinkFrequencies`.
- `Get SMO HELP.vi` has no `setLinkFrequencies` frame, so `HELP` has nothing to show for it.
- Open point: lvkit numbers the frames by their position in the sorted label list, and position 33 falls between `setDutyCycle` (32) and `setInputGain` (34). That suggests the frame's label is **not** literally `setLinkFrequencies` (which would sort after `setInputOffset`). The label decides what string a remote client must send. Check the label in LabVIEW, or probe the running lock-in (test plan row 1).

**Callers.** The lock-in UI (`Instrument UI.Lockin/Process.vi`, state `Action: Link Frequencies`) sends its `Link Frequencies` control out as a command message (command value 5 of an enum lvkit does not name; it is not `Lockin.Commands--Enum`, where 5 is `setAO_Function`). If that message reaches `Handle Command.vi`, the cached field in `Instrument.Lockin` tracks UI changes as well as remote ones; if the UI calls the engine directly, `getLinkFrequencies` would miss UI changes. Test plan row 10 settles it.

## Edits (for the user, LabVIEW 2019)

| # | Where | Edit |
| --- | --- | --- |
| 1 | `Typedefs/API/Lockin.Commands--Enum.ctl` | `setLinkFrequencies` is already appended (item 40). Append `getLinkFrequencies` after it (item 41). Do not insert in the middle: `Client.vi` callers carry the numeric value. |
| 2 | `Overrides/Handle Command.vi`, existing link frame | Make sure the frame's case label includes `setLinkFrequencies` exactly (add it as a second label if the existing one is something else, so old callers keep working). No change to the body. |
| 3 | `Overrides/Handle Command.vi`, new frame `getLinkFrequencies` | Case label `getLinkFrequencies` (no `_`, matched whole). Body: unbundle the `Instrument.Lockin` field of type `Configuration.LinkFrequencies--Cluster` (the one the set frame writes; find it by type), `To Variant` -> `Processed Data`. Pass the instrument through, error from the data-parse error wire, as `getOutputOffset` does. |
| 4 | `Overrides/Get SMO HELP.vi`, new frame `setLinkFrequencies` | Request cluster: a `Configuration.LinkFrequencies--Cluster` constant, e.g. `{Link?: True, Frequency (Hz): 17.777}`. Description: "Link the frequencies of all AO and REF channels to one value. While Link? is true, every AO and REF frequency is set to Frequency (Hz), and frequencies sent with setAO or setREF are overridden. Link? false stops linking; channels keep their current frequency. Phases are not changed." |
| 5 | `Overrides/Get SMO HELP.vi`, new frame `getLinkFrequencies` | Response cluster: the same typedef constant. Description: "Return the frequency link state {Link?, Frequency (Hz)} last set with setLinkFrequencies (from the lock-in UI or remotely)." |
| 6 | `API/setLinkFrequencies.vi` (new) | Copy of `API/setOutputOffset.vi`: input `Link Frequencies` (`Configuration.LinkFrequencies--Cluster`), `Client.vi` with the `Lockin.Commands--Enum` constant set to `setLinkFrequencies`. Add to `Instrument.Lockin.lvclass`, public scope. |
| 7 | `API/getLinkFrequencies.vi` (new) | Copy of `API/getOutputOffset.vi`: enum constant `getLinkFrequencies`, `Variant to Data` with the typedef as type, output `Link Frequencies`. Public scope. |
| 8 | `Instrument.Lockin.TestLauncher.vi` (optional) | If it lists commands, add both. |

The payload keys are the typedef labels, `Link?` and `Frequency (Hz)`. They become wire keys: `JSON to LVtype.vim` silently ignores unknown keys, so `{"link": true}` would be received as `Link? = False` with no error. Leave the labels as they are.

## Decisions

**Should `setLinkFrequencies` also zero the phases?** Decided (2026-10-29): no explicit zeroing. The user expects the generator to reset the phase when the frequency changes, which would re-align AO and REF on every linked change by itself. Not yet confirmed from the code (`Generator` is driven by user events into `Generator/Process.vi`, not read here); test plan row 6 checks it: after each linked change, theta for AI1 at REF1 should come back to the same value. Reasons it should not be bundled anyway:

- The engine already changes AO and REF frequencies in the same pass, so a linked change does not introduce a new AO/REF offset the way two separate `setAO` / `setREF` calls do.
- It makes `setLinkFrequencies` with an unchanged frequency (or with `Link? = false`) a silent phase reset, which a client would not expect.
- Re-alignment is a separate operation; when `zeroPhase` comes back it is the right home for it. A client that wants both sends two calls.
- If one call is wanted anyway, add an optional third field `Zero Phase?` (default False) to the typedef rather than changing the meaning of the existing two; old payloads stay valid because missing keys take defaults.

**Should the link state be persisted with the configuration?** Decided (2026-10-29): no. Keep today's behaviour (unlinked at every launch), and document it in the HELP text. A link that survives a restart silently overrides every frequency a client sets, with no error, which is the hardest failure to diagnose remotely. `getLinkFrequencies` lets a client check the state after connecting.

## JSON-RPC test plan

Lock-in simulated, AI1 looped back to AO1, `tcp://localhost:29170`. Client: `Transport/python/src/expconfig/rpc.py` via `uv run`. Always send `params` (`{}` for getters). Snapshot `getAOconfig` and `getREFconfig` first and restore both at the end with `setAO` / `setREF` (also send `setLinkFrequencies {"Link?": false, ...}` before restoring, or the restore is overridden).

| # | Request | Expected |
| --- | --- | --- |
| 1 | `setLinkFrequencies {"Link?": false, "Frequency (Hz)": 0}` (before any edits, on the current build) | Tells whether the existing frame answers to this name: a reply without error means it is already reachable; error 4001 means the label is different (edit 2). |
| 2 | `HELP ["setLinkFrequencies"]`, `HELP ["getLinkFrequencies"]` | Description and request/response cluster from edits 4-5. |
| 3 | `getLinkFrequencies {}` after a fresh launch | `{"Link?": false, "Frequency (Hz)": 0}`. |
| 4 | `setLinkFrequencies {"Link?": true, "Frequency (Hz)": 17.777}`, then `getAOconfig`, `getREFconfig`, `getLinkFrequencies` | Every AO and REF channel (enabled or not) has `Frequency` 17.777; getter echoes the payload. |
| 5 | While linked: `setAO_Frequency` / `setREF_Frequency` on channel 1 to 23 Hz, then `getAOconfig` / `getREFconfig` | Still 17.777 on both (documents the override). |
| 6 | While linked: `setLinkFrequencies {"Link?": true, "Frequency (Hz)": 31}` | All frequencies 31. `getResults` for AI1 at REF1: R near the AO1 amplitude and stable over several reads; record theta. Repeat with 17.777 and 31 again: if the generator resets phase on a frequency change, theta returns to the same value each time at the same frequency; if it drifts, the phase-zero decision needs revisiting. |
| 7 | `setLinkFrequencies {"Link?": false, "Frequency (Hz)": 31}`, then `setAO_Frequency` channel 1 to 23 Hz | Link off: channels stay at 31, then AO1 goes to 23 and REF stays at 31. |
| 8 | `setLinkFrequencies {"link": true}` (wrong key) | No error, `getLinkFrequencies` shows `Link? = false` (documents silent key ignore). |
| 9 | `setLinkFrequencies {}` | Same as `{Link?: false, Frequency (Hz): 0}`: unlinks, frequencies unchanged. |
| 10 | Change the link in the lock-in UI, then `getLinkFrequencies` | Reflects the UI state (UI goes through `Handle Command.vi`). |
| 11 | Restore snapshot | `getAOconfig` / `getREFconfig` match the snapshot. |

## `zeroPhase` (tabled)

- `Handle Command.vi` already has a frame that calls `DAQ.zeroPhase` (lvkit frame 51, the last in sort order, so probably labelled `zeroPhase`); it is not in `Lockin.Commands--Enum` or `Get SMO HELP.vi`. The `setREF` frame also contains a `DAQ.zeroPhase` call inside a Disabled diagram-disable frame.
- In the engine it ends in `support/Set REF Phase to Zero.vi` (called from state `DSP: Phase`), which sets `Phase = 0` on every **REF** channel only. AO phases are not touched. So today's `zeroPhase` does not re-align AO against REF in the sense the issue asks for; that needs engine work on the generator side and is a separate design question.
