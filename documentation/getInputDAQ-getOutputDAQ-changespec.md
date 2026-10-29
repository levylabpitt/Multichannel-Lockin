# getInputDAQ / getOutputDAQ commands (change spec)

**Status.** Proposal; edits to be made by the user in LabVIEW 2019. Read with lvkit on `develop` at `2e4e01b0` (Release 3.8.6.97) on 2026-10-26, plus read-only JSON-RPC calls to the simulated lock-in (29170) and KH7008 (29160).

**Why.** The Python Configure Experiment (Transport `feature/python-config`) needs a cheap way to learn how many AI and AO channels the lock-in has, their physical names and which card each one is on. Today the only sources are `getAll`/`getAI` (full waveforms, 12000 samples per channel) and `getInputGain`/`getOutputGain`, which give the wrong count (16 AI instead of 12, see part 2).

**Design.** Two methods, one per direction, each returning a bare array with one element per channel, shaped like the lock-in's internal AI Config and AO Config arrays. The combined Device / Lockin.AO / Lockin.AI table that `setDAQ` takes exists only for the lock-in's UI, and grouping channels on one device into one DAQmx task is internal, so neither belongs in the outward API. The names avoid `getAOconfig`, which already exists in the public API and returns the AO generator settings (`[AO.Channel--Cluster]`: amplitude, frequency, function, ...), and the `getAIconfig` frame in `Handle Command.vi`, which is not in the public enum.

## How to read `Handle Command.vi`

`src/Instrument.Lockin/Overrides/Handle Command.vi` dispatches on a **string** case: `Match Pattern` splits the command at the first `_`, and the case selector is the part before it (`setAO_Amplitude` -> `setAO`, then a nested case on `Amplitude`). Commands with no `_` (`getInputDAQ`, `thisIsNotACommand`) pass through whole. lvkit prints the case frames as numbers 0-46. Those numbers are the positions of the frame labels in LabVIEW's sorted label list, which starts with four separator labels (`GET METHODS`, `LOCAL API`, `PUBLIC API`, `SET METHODS`). The mapping checks out against the frame bodies: 15 = `getSampling`, 16/17 = `getState`/`getStatus`, 18/19 = `getSweepResults`/`getSweepWaveforms`, 20 = `logConfiguration`, 23 = `setAO` (nested suffix case), 25 = `setDAQ`, 26 = `setData` (nested suffix case), 30 = `setInputGain`, 33 = `setOutputGain`, 39 = `setState`, 44/45 = `startLogging`/`stopLogging`. The `Default` frame calls the parent `Handle Command.vi` (Call Parent Method).

## Part 1: `getInputDAQ` and `getOutputDAQ`

### Where the data already is

The lock-in already caches the DAQ channel configuration in its class private data, as two arrays:

- AI Config, `Instrument.DAQ/Typedefs/DAQ.Config.AI--Cluster--Array.ctl`: `[Cluster{Channels: Tag, Coupling: U16, Range: DAQ.Config.AI.Range--enum, terminal configuration: I32, Type: DAQ.Type--enum}]`
- AO Config, `Instrument.DAQ/Typedefs/DAQ.Config.AO--Cluster--Array.ctl`: `[Cluster{Channels: Tag, Range: DAQ.Config.AO.Range--enum, terminal configuration: I32, Type: DAQ.Type--enum}]`

with `DAQ.Config.AI.Range--enum` = {±0.316, ±1.00, ±3.16, ±10.0, ±31.6, ±42.4}, `DAQ.Config.AO.Range--enum` = {±0.1, ±1.0, ±3.5, ±10.0}, `DAQ.Type--enum` = {None, USB-4431, PXI-446x}, Coupling AC/DC/GND = 10045/10050/10066, terminal configuration differential/pseudodifferential = 10106/12529. lvkit calls the two class fields `Cfg_AI` and `Cfg_AO`, but class field labels are scrambled in lvkit output, so find them by type. Three places write the cache:

| Writer | What it does |
| --- | --- |
| `Instrument.Lockin/Process.vi`, event `DAQ Public Events.getDAQconfig` | The DAQ engine (`Instrument.DAQ/Process.vi`, state `Data: Process DAQ`) fires this event through `DAQ.getDAQconfig.vi` on init, autoconfigure and every config change. The handler runs `config UI to not UI (AO and AI).vi` and writes both arrays. |
| `Handle Command.vi`, frame `setDAQ` | Parses the `[DAQ.Configuration--Cluster]` payload, splits it with the same converter, writes both arrays, then calls `DAQ.setAIconfig` / `DAQ.setAOconfig`. |
| `Handle Command.vi`, frame `setData`, suffix `DAQ` | The local `setData_DAQ` command. Same write. |

`DAQ.getDAQconfig.vi` (`src/Instrument.DAQ/private/`) is not a request/reply method: it only generates the `getDAQconfig` public event. The replies are therefore built from the cache in `Handle Command.vi`, which is cheap: no DAQ engine round trip and no waveforms.

### Element shape: reuse the internal typedefs

The replies are the cached arrays themselves, typed `DAQ.Config.AI--Cluster--Array` and `DAQ.Config.AO--Cluster--Array`. No new typedef and no conversion.

- `Channels` is the full physical channel name (`PXI1Slot2/ai0`), the form the lock-in stores and DAQmx takes. The reply reports exactly what the engine applied: no splitting, renumbering or range coercion.
- The Python configurator gets the count (array length), the physical name (`Channels`) and the card grouping (the text before the first `/`). `Lockin.AI` / `Lockin.AO` numbering is the array index + 1, so it is implicit in the order.
- A later `setInputDAQ` / `setOutputDAQ` can take the same type back.
- `Type` (None, USB-4431, PXI-446x) tells the client the card family for free.

`Channels` is a DAQmx physical-channel Tag. JSONtext handles DAQmx tags on purpose (`vi.lib/JDP Science/JSONtext/support/Test DAQmx tags.vi` round-trips every DAQmx tag type), so the arrays serialize as they are. The exact text of a serialized tag is still to confirm with the first call; it is expected to be the bare name.

**The labels become public.** The field labels of `DAQ.Config.AI--Cluster.ctl` / `DAQ.Config.AO--Cluster.ctl` are now JSON keys, so renaming or adding a field is a wire-protocol change (see "JSON command payloads" in CLAUDE.md). You plan to:

- **Rename labels if needed, before the first release of these commands.** These typedefs probably also sit in the lock-in's saved configuration file: `Read Configuration File.vi` / `Write Configuration File.vi` store `Configuration--Cluster`, whose `DAQ` section is `{Sampling, Simulation mode, AI: [...], AO: [...], Calibration, Devices}` (lvkit does not show the element type of `AI`/`AO`). A rename changes the INI keys, so a config file saved before it loads defaults for the renamed fields, silently. That is harmless if autoconfigure rebuilds the channel config at startup; check a saved config file first. Rename with the project open so every Bundle/Unbundle By Name follows the label, then Save All.
- **Change `Channels` from Tag to String, optionally.** Low risk: the INI file stores a tag as text either way, a string wires into DAQmx channel inputs with a coercion dot, and `config not UI to UI (AO and AI).vi` already treats `Channels` as text. Any front-panel control of the typedef becomes a plain string (no DAQmx browse button). It also removes the one unverified point above.

### Wire types (recommended cleanup of `DAQ.Config.AI/AO--Cluster`)

Once these typedefs are public, their field types are part of the API too. Recommendations, to do in the same pass as the label renames:

- **No blank items in the internal/wire typedefs.** The empty items (`"" = 0` in the AI.Coupling ring, a blank in the terminal-config ring, a blank last item in both Range enums) exist only because the UI table mixes AO and AI rows in one grid. Keep them in the UI typedef (`DAQ.Configuration--Cluster`) only, and convert in `config UI to not UI` / `config not UI to UI`. If a typedef has to stay shared:
  - in a **ring**, position does not matter (each item carries an explicit value);
  - in an **enum**, position is the value, so a blank goes **last**. A blank inserted first shifts every item and changes saved config files and existing wires. The defaults `AO.Range = 4` / `AI.Range = 6` in `config not UI to UI` are these blank last items.
- **Coupling: enum `{AC, DC, GND}`** instead of the DAQmx ring. Convert to the DAQmx constant (10045 / 10050 / 10066) in the DAQmx class, where the channel is created. The JSON then reads `"Coupling": "DC"`, the enum restricts the values (a plain string would accept typos and pass them on silently), and DAQmx constants stay inside DAQmx code.
- **Terminal configuration: enum `{Default, Differential, Pseudodifferential}`**, mapped to -1 / 10106 / 12529 in the DAQmx class. Name the device-default item `Default` instead of leaving it blank: it is a real setting (today the `< 0` value that `config not UI to UI` replaces). The 4431 and 446x support only differential and pseudodifferential.
- **Range: a number in volts (DBL), not the `±` enum.** `±` is byte 0xB1 in LabVIEW's Windows-1252 strings, which is not valid UTF-8 (lvkit already prints it as `�0.316`). A JSON reply carrying it can fail to decode in Python or arrive garbled. DAQmx takes min/max as numbers and picks the smallest hardware range that covers them, so `"Range": 10.0` (meaning ±10 V) is what DAQmx needs and what a client can compare. The UI can keep its dropdown and convert. If you would rather keep a fixed list, use an enum with ASCII names (`"10 V"`, `"3.16 V"`). Either way, keep every wire string ASCII.
- **JSONtext behavior to confirm:** enums are written as the item name. Whether an unknown name on input raises an error or silently falls back to the default is unverified; check it before relying on enums for validation.

Knock-on edits:

- `config not UI to UI (AO and AI).vi` and `config UI to not UI (AO and AI).vi`: the per-`Type` range coercions (USB-4431: AO -> ±3.5, AI -> ±10.0; otherwise AO ±3.5 -> ±10.0) compare enum values, and the conversions now have to map the UI rings/enums to the new types.
- The DAQmx class code that creates AI/AO channels: map the Coupling and terminal-configuration enums to DAQmx constants, and pass Range as min = -Range, max = +Range.
- The saved configuration file: changing enum items or a field's type changes what the INI stores, as label renames do. Load a config file saved before the change and check the DAQ section.

With these changes the replies would look like:

```json
[
  {"Channels": "PXI1Slot2/ai0", "Coupling": "DC", "Range": 10.0, "terminal configuration": "Differential", "Type": "PXI-446x"}
]
```

Example replies with the current labels and types (enums assumed to serialize as the item name; confirm with `HELP(["getInputDAQ"])` after the edits):

```json
[
  {"Channels": "PXI1Slot2/ai0", "Coupling": 10050, "Range": "±10.0", "terminal configuration": 10106, "Type": "PXI-446x"},
  {"Channels": "PXI1Slot2/ai1", "Coupling": 10050, "Range": "±10.0", "terminal configuration": 10106, "Type": "PXI-446x"}
]
```

```json
[
  {"Channels": "PXI1Slot2/ao0", "Range": "±10.0", "terminal configuration": 10106, "Type": "PXI-446x"}
]
```

### Edits for you to make

New files go under `src/Instrument.Lockin/` and are added to `Instrument.Lockin.lvclass`. Save in LabVIEW 2019.

| # | File | What to do |
| --- | --- | --- |
| 1 | `Typedefs/API/Lockin.Commands--Enum.ctl` | Append `getInputDAQ` and then `getOutputDAQ` as the **last** two items (after `stopLogging`, values 36 and 37). Appending keeps every existing value. `Get SMO Public API.vi` turns this enum into the command list that `HELP` returns, so this alone advertises both commands. |
| 2 | `Instrument.DAQ/Typedefs/DAQ.Config.AI--Cluster.ctl`, `DAQ.Config.AO--Cluster.ctl` (optional) | Label renames, Tag -> String, and the wire-type changes in "Wire types" with their knock-on edits. Do this first, with the project open. |
| 3 | `Overrides/Handle Command.vi`, new frame `getInputDAQ` | Add a case label `getInputDAQ` (no `_`, so the top-level case matches it directly). Body: unbundle the AI Config array from `Instrument.Lockin` (find it by type, `DAQ.Config.AI--Cluster--Array`), `To Variant` -> `Processed Data`. Pass the instrument through unchanged and the error from the data-parse error wire, as `getAOconfig` and the other cache readers do. |
| 4 | `Overrides/Handle Command.vi`, new frame `getOutputDAQ` | Same with the AO Config array (`DAQ.Config.AO--Cluster--Array`). |
| 5 | `Overrides/Get SMO HELP.vi` | Add frames `getInputDAQ` and `getOutputDAQ` next to `setDAQ` (text below). |
| 6 | `API/getInputDAQ.vi` (new, public, in the `API` virtual folder of the class) | The LabVIEW API wrapper, like `setDAQ.vi`: `Lockin.Remote Client.vi` with `Command` = enum `getInputDAQ`, then `Variant To Data` on `Data out` into `DAQ.Config.AI--Cluster--Array`. Output `AI Config`. Without this the command works over JSON-RPC but LabVIEW clients cannot call it. |
| 7 | `API/getOutputDAQ.vi` (new, public, `API` folder) | Same with enum `getOutputDAQ` and `DAQ.Config.AO--Cluster--Array`, output `AO Config`. |

No existing VI's connector pane changes (`Instrument.Lockin.lvclass` changes only because members are added).

### HELP entries

In `Get SMO HELP.vi`, two new frames, wired like `getAOconfig`:

**`getInputDAQ`**
- `command description`: `Returns the analog input channel configuration without waveforms: one element per AI channel, in lock-in AI order. Channels is the full DAQmx physical channel (Device/aiN); channels with the same Device are on the same card.`
- `request cluster`: none (default variant).
- `response cluster`: a `DAQ.Config.AI--Cluster--Array` constant with one element `{Channels: PXI1Slot2/ai0, Coupling: DC (10050), Range: ±10.0, terminal configuration: differential (10106), Type: PXI-446x}`.

**`getOutputDAQ`**
- `command description`: `Returns the analog output channel configuration without waveforms: one element per AO channel, in lock-in AO order. Channels is the full DAQmx physical channel (Device/aoN); channels with the same Device are on the same card.`
- `request cluster`: none.
- `response cluster`: a `DAQ.Config.AO--Cluster--Array` constant with one element `{Channels: PXI1Slot2/ao0, Range: ±10.0, terminal configuration: differential (10106), Type: PXI-446x}`.

### Caveats

- One element per configured channel string. If a client ever sent `setDAQ` with a range such as `AI.Ch: "ai0:3"`, that is one element covering four channels, and the array index no longer matches the AI waveform order. The autoconfigured case (the normal one) has one physical channel per entry. The DAQ engine counts channels per entry with `DAQ.Get Number of Channels from Channel String.vi`, so a later version could expand ranges if needed.
- The `setDAQ` frame writes the cache before the DAQ engine validates it; the next `getDAQconfig` event then replaces it with what the engine applied. A `getInputDAQ` sent right after a `setDAQ` can briefly echo the request.

## Part 2 (proposal): why `getInputGain` returns 16 values

Observed on the simulated lock-in: `getInputGain` -> `[5000, 5000, 1, 1, ... 1]` (16 values), while `getAI` returns 12 waveforms.

**Probably not intended: the reply looks like a stale echo of the last `setInputGain`, not the instrument's channel count.** Worth checking in the code:

- `getInputGain` (frame `getInputGain`) returns the lock-in's own cached `[Channel.Gain--Cluster]` array (the `Gain` of each element).
- The only writer of that cache appears to be frame `setInputGain`, which stores **whatever array the client sent**, of any length, then forwards it to `DAQ.setInputGain`. (The `setData_InputGain` suffix frame also writes it, but `Instrument.Lockin/Process.vi` never sends that local command.)
- The DAQ engine does resize: its `setInputGain` event queues `Data: Process Input Gain`, which runs `Instrument.DAQ/support/Initialize Input Gain.vi` (target size = number of AI channels in the AI config, summed per entry with `DAQ.Get Number of Channels from Channel String.vi`), pads or truncates with `Gain Add or Remove.vi`, and publishes the result as the `getInputGain` public event.
- But `Instrument.Lockin/Process.vi` registers no handler for the DAQ engine's `getInputGain` or `getOutputGain` events. It handles `getDAQState`, `getDAQconfig`, `getSampling`, `getAIChannels`, `getAOChannels`, `getREFChannels`, `getWaveforms`, `getResults`, `getSweepWaveforms`, `getDeviceIDN` and `getCalibration` only. So the resized array never reaches the cache, and some client (probably the LabVIEW Configure Experiment, given the 5000s) last sent 16 values.
- `getOutputGain` has the same flaw. It agrees with the 9 AO only because the last `setOutputGain` happened to send 9 values.

**Proposed fix:** in `Instrument.Lockin/Process.vi`, add event cases for `DAQ Public Events.getInputGain` and `DAQ Public Events.getOutputGain` that write the cached `[Channel.Gain--Cluster]` arrays, following the `getAIChannels` case. After that, `getInputGain` / `getOutputGain` return one value per AI / AO channel, however many values the client sent. Until then, the Python configurator should take its channel counts from `getInputDAQ` / `getOutputDAQ`, not from the gain arrays.

## Part 3: unknown commands and errors reply `null`

Every instrument error outside the reserved JSON-RPC codes (including the framework's 4001 `command "<name>" not supported` for unknown commands) reaches the client as a bare `null` with no envelope. The lock-in raises 4001 correctly; the error is dropped by `Create Error Object.vi` in the JSON-RPC library. That fix is handled in its own session in `C:\Users\patrick\Documents\GitHub\ciozi137\JSON-RPC`, and needs no change in this repo.

**Lock-in only:** the nested suffix cases in `Handle Command.vi` (`setData_*`, and probably `setAO_*`, `setREF_*`, `setSweep_*`) return no error for an unknown suffix. That is why `setData_Bogus` gets an envelope with neither `result` nor `error`. Give each nested case's default frame an error 4001 `command "<full command>" not supported`, matching the parent `Handle Command.vi`. The `setData_*` commands are local (the lock-in sends them to itself) but are reachable remotely; whether to block them remotely is a separate question.

## Test plan (after the edits)

Restart the app first. Never send a non-JSON request: the server gets no reply out and its REP socket stays stuck until restart.

| Request | Expect |
| --- | --- |
| `HELP` | command list ends with `getInputDAQ`, `getOutputDAQ` |
| `HELP ["getInputDAQ"]`, `HELP ["getOutputDAQ"]` | the descriptions and response examples above; note how the enums serialize |
| `getInputDAQ` on the simulated instrument | 12 elements, `Channels` of the form `Device/aiN`, grouped by device as on the hardware; reply is a few hundred bytes |
| `getOutputDAQ` | 9 elements, `Device/aoN` |
| `setDAQ` with one changed AI range, then `getInputDAQ` | the change shows; after the next `getDAQconfig` event it still shows (engine accepted it) |
| `API/getInputDAQ.vi`, `API/getOutputDAQ.vi` from LabVIEW | same arrays, no error |
| raw reply bytes of `getInputDAQ` | valid UTF-8, no `±` (or any non-ASCII) anywhere |
| (after a label rename or type change) load a config file saved before it | check whether the DAQ channel config survives or is rebuilt by autoconfigure |
| `setData_Bogus` | `error.code` 4001 (with the JSON-RPC fix; without it, a bare `null`) |
| `setInputGain` with 16 values, then `getInputGain` (with the part 2 fix) | 12 values |
