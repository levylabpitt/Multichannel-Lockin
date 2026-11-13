# Change spec: tests out of classes, `Lockin.Types.lvlib`, `Instrument.Lockin.API` (#199)

Goal: a client (Transport, a script, another instrument) can call the lock-in API without loading the acquisition engine, and the VIP and exe stop carrying test code. Single inheritance only, LabVIEW 2019, no change to the Instrument Framework or to other instruments (Krohn-Hite, Oxford, ...).

Everything below was read from the files on `develop` after Release 3.10.4.104 (2026-11-11): class membership from the `.lvclass` XML, dependencies from the link tables inside the `.vi`/`.ctl` files (qualified names `Owner.lvclass:Item.ctl`). Link-table reads cannot see wiring; anything marked "check" needs a look in LabVIEW.

## What exists today

**Hierarchy.** `Instrument` (framework) -> `Instrument.LockinAPI` (framework, `user.lib\LevyLab\Instrument Framework\Instrument Types\Lockin`) -> `Instrument.Lockin` (this repo). `Instrument.LockinAPI` already has its own API VIs and `LockinAPI.*` typedefs.

**Library.** `Instrument.Lockin.lvlib` contains `Instrument.Lockin.lvclass`, `Instrument.DAQ.lvclass`, `Instrument UI.Lockin.lvclass`, `Lockin.Utilities.lvlib` and `Lockin.vi`. As far as we know, loading a library loads the classes in it, so loading any member pulls in all three classes (check: open one API VI alone and look at what is in memory).

**Why the API drags in the engine.** A typedef that is a class member links its class. `Instrument.Lockin`'s private data holds 35 `Instrument.DAQ` typedefs plus two `PublicEvents--DAQ.*` event types. Every member of the class links that set, so every one of the 156 `Instrument.Lockin` VIs (even `Get SMO Port.vi`) loads `Instrument.DAQ`, which loads DAQmx, DSP, Generator and NI-DAQmx.

**The API VIs do not call the engine.** None of the VIs under `API\` (AO, DAQ, Data, Gain, Macros, REF, State, Sweep) calls an `Instrument.Lockin` VI outside `API\`, or any `Instrument.DAQ`/`DAQmx`/`Generator`/`DSP` VI. They only send commands (`Client.vi`, framework). Their engine link is entirely the typedefs plus the class private data.

**Cross-class typedef use (non-test code).**

| Owner | Used by | Count |
| --- | --- | --- |
| `Instrument.DAQ` | `Instrument.Lockin` | 69 typedefs |
| `Instrument.DAQ` | `Instrument UI.Lockin` | 41 typedefs |
| `Instrument.Lockin` | `Instrument UI.Lockin` | 7 typedefs |
| `Instrument.Lockin` | `Instrument.DAQ` | 2 typedefs (cycle) |
| `DAQmx` | `Instrument.Lockin`, `Instrument UI.Lockin`, `Instrument.DAQ` | `Simulation Mode--enum.ctl` |
| `Instrument.DAQ` | `DAQmx` | `DAQ.Sampling.Sampling--Cluster.ctl` |

**Cross-class VI calls into `Instrument.Lockin`.**

| Callee | Caller |
| --- | --- |
| `config not UI to UI (AO and AI).vi` (`DAQ-public`) | `Instrument.DAQ:Process.vi` (cycle) |
| `Parse Results Array (all).vi` (`API\Data`) | `Instrument.DAQ:Calibrate Phase.vi`, several `Instrument UI.Lockin` VIs |
| `Parse Results Array (all) (cluster).vi`, `Parse Results Array (single).vi` | `Instrument UI.Lockin` |
| `Calculate Output Sampling.vi`, `Replace Sweep Waveforms.vi` (`DAQ-public`), `Lockin.getDAQPublicEvents.vi` (`Accessors`) | `Instrument UI.Lockin:Process.vi` |

**Duplicate typedefs.** Several typedefs exist as separate same-named files in more than one class: `AO.Channel--Cluster.ctl` (`Instrument.DAQ`, `Generator`), `REF.Channel--Cluster.ctl` (`Instrument.DAQ`, `Generator`, `DSP`), `AI.Channel--Cluster.ctl` and `Results--Cluster.ctl` (`Instrument.DAQ`, `DSP`), `Sweep.Configuration--Cluster.ctl` (`Instrument.DAQ`, `Generator`), `DAQ.Configuration--Cluster.ctl` (`Instrument.DAQ`, `DAQmx`). `Instrument.DAQ` converts between its copies and the engine copies. This spec moves only the `Instrument.DAQ` copies; the engine copies stay internal.

**Stale links (clean up first).** These are referenced by qualified name but no longer exist as class members or files:

- `Instrument.DAQ:Get State-enum.ctl`: linked from ~50 `API\` VIs.
- `Instrument.DAQ:Simulation Mode--enum.ctl`: linked from ~52 `API\` VIs (the live one is `DAQmx:Simulation Mode--enum.ctl`).
- `Instrument.DAQ:DAQ.TerminalConfiguration--ring.ctl`: linked from `Instrument.Lockin` (the live one is `DAQ.TerminalConfiguration--enum.ctl`).
- `Instrument.Lockin:setSweepTable.vi`: linked from `API\setSweepTable.vim`.

They are probably nested inside a typedef or constant that still carries the old link. Find them by searching the `.vi`/`.ctl` files for the name (the link table is plain text), then open and save each carrier. Stale links like these broke the VIP build before (VIPM error 43, see CLAUDE.md).

**Transport's links into this repo** (`levylabpitt/Transport` at `94bcc11`):

| Item | Linked from |
| --- | --- |
| `Instrument.DAQ:Sweep.Channel--Cluster(--Array).ctl`, `Sweep.Pattern--Enum.ctl` | 72 files, carried by ~10 Transport typedefs: `Sweep Control\Typedefs\Cluster - ScanControl.ctl`, `Cluster - ScanParamters.ctl`, `Cluster - Sweep Control.ctl`, `Lockin Sweep--Cluster.ctl`, `ScanControl.ctl`, `ScanParamters.ctl`, `Sweep Control JSON--Cluster.ctl`, `Continuous B Sweep JSON--Cluster.ctl`, `src\Transport\Typedefs\Lockin_time Configuration--Cluster.ctl`, and the private data of the Sweep Control and `Inst.Transport` classes |
| `Instrument.DAQ:Sweep.Configuration--Cluster.ctl` | `Lockin_sweep.vi`, `Continuous B sweep.vi`, `Open Me.vi` |
| `Instrument.DAQ:AO.Channel*`, `REF.Channel*` | `Continuous B sweep.vi`, `Read Sweep Configuration File.vi`, `Read Continuous B Sweep.json.vi`, `Read Sweep Configuration Example.vi`, `Continuous B Sweep JSON--Cluster.ctl`, `Tests\Sandbox\Cluster Typedef JSON Staging.vi` |
| `Instrument.Lockin:Parse Results (all).vi`, `Results Type--Enum.ctl` | `Lockin_sweep.vi`, `Lockin_time.vi`, `Results (Dictionary) to X and Y Arrays.vi`, `Tree.vi` |
| `Instrument.Lockin:setSweepConfiguration.vi`, `startSweep.vi`, `stopSweep.vi`, `getSweepData.vi`, `Instrument.Lockin.AppLauncher.vi` | `Open Me.vi` |
| `Instrument.Lockin:waitForNewResults.vi` | `Tree.vi` |

So today Transport loads the whole lock-in engine for its sweep typedefs alone.

## Phase 0: tests out of the classes, stale links

Each VI below is deleted, moved to `experiments\`, moved to a test library, or left in its class; the verdicts are in "Evaluation" after the table. Do the moves in the LabVIEW project (drag out of the class), not by editing the `.lvclass` XML.

**The rule: black-box tests move, white-box tests stay.** A black-box test uses only public methods and can live anywhere. A white-box test calls private (or protected) methods or reads the class's private data; it stays in its class. LabVIEW has no "private except for tests" scope: a friend can call community-scope members only, and a child class reaches protected but never private. Moving a white-box test out would mean community scope plus a friend entry, or accessor VIs, for each private thing it touches, which is not worth it for a handful of small VIs. The TestLaunchers stay in their classes too (see below).

**Where moved tests go:** `Tests\<Class>\Tests.<Class>.lvlib`, one library per tested class (e.g. `Tests\DSP\Tests.DSP.lvlib`), added to `Multichannel Lock-In (x64) - Unit Tests.lvproj`. A library rather than a test class: the tests have no private data and no inheritance. Opening a library member does not load its siblings, so Ctrl+L does not show every broken test at once; check with a mass compile of `Tests\` instead (test plan row 1).

**One exception:** `DSP:Test Decimator with State` is white-box (it calls the protected `Decimate DFD (Array).vi`) but is the only VI in `src\` that links Caraya, so leaving it in DSP keeps Caraya in the exe and the package. Move it to `Tests.DSP.lvlib`, change `Decimate DFD (Array).vi` from protected to community, and list `Tests.DSP.lvlib` as a friend of `DSP.lvclass`. DSP has no child classes (no other `.lvclass` references it), so protected bought nothing; its only other caller is `Decimate DFD (Fs).vi` inside DSP.

The second column of the table lists the private methods each VI calls, as found before the evaluation.

| Class member | Calls private |
| --- | --- |
| `DAQmx.lvclass:Test Sync (DAQmx).vi` | `DAQmx.44xx.Fs to FilterDelay.vi` |
| `DAQmx.lvclass:Test Sync SMO.vi` | `Device to String.vi` |
| `DAQmx.lvclass:Test Sync with Queues.vi` | `ObtainPublicQueues.vi`, `ReleaseQueues.vi`, `DAQmx.Write.vi` |
| `DAQmx.lvclass:Test Sync.vi` | `DAQmx.Write.vi` |
| `DAQmx.lvclass:Test Waveforms.vi` | |
| `DAQmx.lvclass:Test Clip.vi` | `DAQmx.Clip AO Waveforms.vi` |
| `DAQmx.lvclass:Test Noise Simulator.vi` | `DAQmx.Simulate AI.vi` |
| `DSP.lvclass:Test Decimator with State.vi` | (links Caraya) |
| `DSP.lvclass:Test Mixer.vi` | |
| `DSP.lvclass:Test Post-filter.vi` | |
| `Generator.lvclass:Generator.TestLauncher.vi` | |
| `Generator.lvclass:Create Test Queues.vi` | (test helper) |
| `Generator.lvclass:Read Test Queues.vi` | (test helper) |
| `Generator.lvclass:Test Queues.vi` | `Generator.GetQueueStatus.vi`, `Generator.AddToQueue.vi` |
| `Generator.lvclass:Test Sweep Generate Waveforms.vi` | |
| `Generator.lvclass:Test Sweep Manager.vi` | |
| `Generator.lvclass:Test Sweep Manager Subsystems.vi` | |
| `Generator.lvclass:Test Generate REF Waveforms.vi` | |
| `Generator.lvclass:Test Generate AO Waveforms.vi` | |
| `Instrument UI.Lockin.lvclass:Instrument UI.Lockin.TestLauncher.vi` | |
| `Instrument UI.Lockin.lvclass:sandbox.vi` | `Spinner.vi`, `Spinner2.vi`, `Spinner3.vi` |
| `Instrument UI.Lockin.lvclass:Test Set Legend.vi` | `Set Legend.vi`, `Set Legend (WFGraph).vi` |
| `Instrument UI.Lockin.lvclass:Test Circular Buffer.vi` | |
| `Instrument.DAQ.lvclass:Instrument.DAQ.TestLauncher.vi` | `Initialize Input Gain.vi` |
| `Instrument.DAQ.lvclass:Test DAQ.vi` | `DAQ.Start.vi`, `DAQ.Stop.vi` |
| `Instrument.DAQ.lvclass:Test PLL.vi` | `Lockin.Engine.vi`, `PLL.vi`, `OLD_Generator.Generate Waveforms.vi` |
| `Instrument.DAQ.lvclass:Test Lockin Engine.vi` | `Lockin.Engine.vi`, `OLD_Generator.Generate Waveforms.vi` |
| `Instrument.DAQ.lvclass:Test Pre-filter.vi` | `Prefilter.vi`, `OLD_Generator.Generate Waveforms.vi` |
| `Instrument.DAQ.lvclass:Test Resampling.vi` | |
| `Instrument.DAQ.lvclass:Test Waveguide Model.vi` | `Waveguide Model.vim` |
| `Instrument.DAQ.lvclass:Test Serialize.vi` | |
| `Instrument.DAQ.lvclass:Test Multitone.vi` | (file in `support\`) |
| `Instrument.DAQ.lvclass:Multitone Eval.vi` | (file in `support\`, test helper) |
| `Instrument.DAQ.lvclass:Slow Step.vi` | (file in `private\`, test helper) |
| `Instrument.Lockin.lvclass:Instrument.Lockin.TestLauncher.vi` | `Format Status String.vi` |
| `Instrument.Lockin.lvclass:Test Handle Command.vi` | |
| `Instrument.Lockin.lvclass:Test Insert sweepTable.vi` | |
| `Instrument.Lockin.lvclass:Benchmark Match Key Regex.vi` | `Match Key Regex.vi` |
| `Instrument.Lockin.lvclass:Measure getStatus Latency.vi` | |

### Evaluation: keep, move or delete

Most of these are sandboxes, not tests: run-until-stop loops with graphs, no Caraya and no pass/fail output. The verdicts below come from each VI's wiring, its callees, whether production uses the same methods, and git history (2026-11-12, not checked by opening each VI). Sandboxes that would need new accessors to work outside their class are deleted rather than given accessors.

**Keep as tests (convert to Caraya where needed).** Black-box ones move to `Tests.<Class>.lvlib`; the white-box one, `Generator:Test Sweep Generate Waveforms` (Generator private data), stays in its class. `DSP:Test Decimator with State` moves as the exception above. The rest (`Test Insert sweepTable`, `Test Mixer`) are black-box and move.

| VI | Why |
| --- | --- |
| `DSP:Test Decimator with State` | Already a Caraya test. |
| `Instrument.Lockin:Test Insert sweepTable` | Five pass/fail booleans for the #185 regression; turn them into asserts. Calls `Replace Sweep Waveforms.vi`, used by `Process.vi`. |
| `DSP:Test Mixer` | DSP lock-in engine on synthetic signals, no hardware; assert X/Y for a known frequency and phase. |
| `Generator:Test Sweep Generate Waveforms` | Drives the top-level `Generate Waveforms.vi` (AO, REF and sweep states). Needs ~5 accessors, or stays in the class. |

**Development harnesses** (run by hand to drive one SMO in isolation; no pass/fail):

- The four TestLaunchers (`Instrument.Lockin`, `Instrument.DAQ`, `Generator`, `Instrument UI.Lockin`) **stay in their classes**, as in the other Instrument Framework repos (Krohn-Hite, Oxford 1820, ...). Each is one VI, so consistency wins over keeping it out of the build. Drop them from the move list above. `Instrument UI.Lockin.TestLauncher` last changed in 2025; check it still runs.
- `DAQmx:Test Sync SMO` (drives the DAQmx SMO on hardware) is white-box (private `Device to String.vi` and DAQmx private data), so it stays in `DAQmx.lvclass`.

**Move to `experiments\` if still wanted:** `DAQmx:Test Sync (DAQmx)` (raw DAQmx AI/AO alignment with `Fs to FilterDelay`; useful for the untested 4461 AO phase delay), `Instrument.DAQ:Test PLL`, `Test Lockin Engine`, `Test Pre-filter` (they exercise `PLL.vi`, `Lockin.Engine.vi` and `Prefilter.vi`, all called from `Process.vi`, but generate signals with `OLD_Generator.Generate Waveforms.vi`).

**Delete:**

| VI | Why |
| --- | --- |
| `Generator:Test Generate AO Waveforms`, `Test Generate REF Waveforms`, `Test Sweep Manager`, `Test Sweep Manager Subsystems` | Subsets of `Test Sweep Generate Waveforms`. |
| `Generator:Create Test Queues`, `Read Test Queues`, `Test Queues` | Scaffolding from the 2026-06 SMO conversion. |
| `DAQmx:Test Sync`, `Test Sync with Queues`, `Test Waveforms` | Exercise `Sync.Config.vi`, which production never calls; `Test Waveforms` is only their helper. |
| `DAQmx:Test Noise Simulator` | One-off visual check from #182. |
| `DSP:Test Post-filter` | Visual filter-response check. |
| `Instrument UI.Lockin:sandbox`, `Test Circular Buffer`, `Test Set Legend` | Spinner experiments; a vi.lib demo; #192 debugging (the lesson is in CLAUDE.md). |
| `Instrument.DAQ:Test DAQ` | Hard-coded `PXI1Slot3` devices, bundles private data; superseded by the TestLauncher. |
| `Instrument.DAQ:Test Resampling` | 2023; `Test Decimator with State` covers decimation. |
| `Instrument.DAQ:Test Serialize` | 2022 JSON vs flatten benchmark. |
| `Instrument.DAQ:Test Multitone`, `Multitone Eval` | Timing comparison; `Multitone Eval` has no other caller. |
| `Instrument.DAQ:Test Waveguide Model` | Its subject is unused (see below). |
| `Instrument.Lockin:Benchmark Match Key Regex` | One-off benchmark. |
| `Instrument.Lockin:Measure getStatus Latency` | Superseded by the latency profile in `Tests\stress\lockin_stress.py`. |
| `DAQmx:Test Clip` | `DAQmx.Clip AO Waveforms.vi` needs a valid DAQmx task, so the test cannot run as is; not worth reworking. |
| `Instrument.Lockin:Test Handle Command` | One-off: sends every `Lockin.Commands` value through `Handle Command.vi` with no data, so every get command returns an error; no clear purpose. |

**Left without callers after the deletes** (from a raw link-table scan; confirm in LabVIEW before deleting): `Instrument.DAQ:OLD_Generator.Generate Waveforms.vi` (if the three engine harnesses go too), `Instrument.DAQ:Slow Step.vi`, `DAQmx:Sync.Config.vi`, `DAQmx:Get Number of Channels.vi`, `DAQmx:Get Sampling.vi`, and `DAQmx:Device to String.vi` (used only by `Test Sync SMO`). `Instrument.DAQ:Simulate Waveguide.vi` already has no caller, so `Waveguide Model.vim` and the waveguide simulation look dead, not just their test.

With these verdicts, no moved VI touches private data and no accessors are needed. The only scope change is `DSP:Decimate DFD (Array).vi` (protected to community), and the only friend entry is `Tests.DSP.lvlib` on `DSP.lvclass`. In-class tests that stay: the four TestLaunchers, `DAQmx:Test Sync SMO` and `Generator:Test Sweep Generate Waveforms`.

Also check whether `Instrument.DAQ.lvclass:OLD_Generator.Generate Waveforms.vi` has any caller besides the three engine harnesses; if not, it goes wherever they go (`experiments\` or deleted).

Then fix the four stale links listed above, Save All, and confirm the VIP still builds.

Expected result: 33 of the 39 listed VIs leave `src\` (the four TestLaunchers, `Test Sync SMO` and `Test Sweep Generate Waveforms` stay), plus any helpers left without callers, about 7% of the VIP's file count; Caraya out of the exe and the package's dependency tree, and smaller member lists to sort through in Phases 1 and 2.

## Phase 1: `Lockin.Types.lvlib`

A new library with no classes in it, at `src\Lockin.Types\Lockin.Types.lvlib`, **not** inside `Instrument.Lockin.lvlib`. It holds only typedefs. A typedef in a class-free library links only itself and whatever it nests, so using one does not load any class.

Move the whole set in one LabVIEW session so no class is left linking a half-moved set. Keep the file names and the labels inside each typedef, which keeps the JSON keys. Suggested folders inside the library mirror the current ones.

### From `Instrument.DAQ.lvclass` (47)

| Folder | Typedefs |
| --- | --- |
| AO and AI (10) | `AI.Channel--Cluster.ctl`, `AI.Channel--Cluster--Array.ctl`, `AO.Channel--Cluster.ctl`, `AO.Channel--Cluster--Array.ctl`, `AO.Channel.Function--Enum.ctl`, `Channel.Gain--Cluster.ctl`, `Channel.Gain--Cluster--Array.ctl`, `Channel.GainsAndOffsets--Cluster.ctl`, `Channel.Offset--Cluster.ctl`, `Channel.Offset--Cluster--Array.ctl` |
| Configuration (8) | `Configuration--Cluster.ctl`, `Configuration.AmplitudeLimit--Cluster.ctl`, `Configuration.Channels--Cluster.ctl`, `Configuration.DAQ--Cluster.ctl`, `Configuration.DCLimit--Cluster.ctl`, `Configuration.DutyCycle--Cluster.ctl`, `Configuration.LinkFrequencies--Cluster.ctl`, `Configuration.Prefilter--Cluster.ctl` |
| DAQ (18) | `DAQ.Calibration--Cluster.ctl`, `DAQ.Calibration--Cluster--Array.ctl`, `DAQ.Config.AI--Cluster.ctl`, `DAQ.Config.AI--Cluster--Array.ctl`, `DAQ.Config.AI.Coupling--enum.ctl`, `DAQ.Config.AI.Range--enum.ctl`, `DAQ.Config.AO--Cluster.ctl`, `DAQ.Config.AO--Cluster--Array.ctl`, `DAQ.Config.AO.Range--enum.ctl`, `DAQ.Configuration--Cluster.ctl`, `DAQ.Configuration--Cluster--Array.ctl`, `DAQ.Sampling--Cluster.ctl`, `DAQ.Sampling.Fs Mode--enum.ctl`, `DAQ.Sampling.Sample Mode--Ring.ctl`, `DAQ.Sampling.Sampling--Cluster.ctl`, `DAQ.TerminalConfiguration--enum.ctl`, `DAQ.Type--enum.ctl`, `DeviceInfo--Cluster.ctl` |
| REF (2) | `REF.Channel--Cluster.ctl`, `REF.Channel--Cluster--Array.ctl` |
| Sweep (4) | `Sweep.Channel--Cluster.ctl`, `Sweep.Channel--Cluster--Array.ctl`, `Sweep.Configuration--Cluster.ctl`, `Sweep.Pattern--Enum.ctl` |
| other (5) | `DAQ.measureInputOffset Config--Cluster.ctl`, `DAQ.measureInputOffset.zero--enum.ctl`, `Results--Cluster.ctl`, `State--enum.ctl`, `Status--enum.ctl` |

### From `Instrument.Lockin.lvclass` (22)

| Folder | Typedefs |
| --- | --- |
| API commands (17) | `Lockin.Commands--Enum.ctl`, `Lockin.Commands.Local--Enum.ctl`, `Lockin.setAO_Amp--cluster.ctl`, `Lockin.setAO_DC--cluster.ctl`, `Lockin.setAO_f--cluster.ctl`, `Lockin.setAO_phi--cluster.ctl`, `Lockin.setAO_function--cluster.ctl`, `Lockin.setREF_f--cluster.ctl`, `Lockin.setREF_phi--cluster.ctl`, `Lockin.setREF_TC--cluster.ctl`, `Lockin.setREF_RollOff--cluster.ctl`, `Lockin.setSamplingMode--cluster.ctl`, `Lockin.setSamplingFsMode--cluster.ctl`, `Lockin.setSweep_Time--cluster.ctl`, `Lockin.setSweep_Table--cluster.ctl`, `Lockin.setState--cluster.ctl`, `Lockin.getAllData--Cluster.ctl` |
| other (5) | `Results Type--Enum.ctl`, `Offset Mode--Enum.ctl`, `REF Parameter--Enum.ctl`, `Lockin.setLogMode--cluster.ctl`, `Lockin.Logging Mode--Enum.ctl` |

### From `DAQmx.lvclass` (1)

`Simulation Mode--enum.ctl` (used by `Instrument.Lockin`, `Instrument UI.Lockin`, `Instrument.DAQ`).

### Stays where it is

- `Instrument.DAQ`: all `PrivateEvents--DAQ.*` and `PublicEvents--DAQ.*` event typedefs, `PublicEvents--Cluster.ctl`, and everything else not listed. These are the private link between the SMO and the engine; after Phase 2 only the server class uses them.
- `Instrument.Lockin`: `PrivateEvents--Cluster.ctl`, `Lockin.Dependencies--Cluster.ctl`, `Lockin.Log*` and `Lockin.LogPaths.*` clusters, `Select All--Boolean.ctl`, `Select None--Boolean.ctl` (server-side logging and UI).
- The engine's own copies in `Generator`, `DSP` and `DAQmx` (see duplicates above). `Instrument.DAQ` keeps depending on those classes, which is fine.

### Checks

- None of the moved typedefs embeds a typedef from `Generator`, `DSP` or `DAQmx` (from the link tables). Confirm after the move: open `Lockin.Types.lvlib` alone in an empty project; nothing else should load.
- Do not merge duplicate copies in this phase. Merging two copies can change labels, which changes JSON keys with no error (`JSON to LVtype.vim` ignores unknown keys). If merging is wanted later, diff the labels first and treat it as a wire-protocol change.
- `Instrument.LockinAPI` (framework) has overlapping `LockinAPI.*` typedefs (`LockinAPI.AO_f--cluster`, `LockinAPI.SweepTable--cluster`, ...). Leave them alone here.

### Result

`Instrument.DAQ`, `Instrument.Lockin` and `Instrument UI.Lockin` all use `Lockin.Types` and no longer load each other's typedefs. The `Instrument.Lockin` -> `Instrument.DAQ` typedef cycle is gone. What remains between them are real calls (the SMO calls `DAQ.set*` VIs; the UI calls server helpers), handled in Phase 2.

## Phase 2: `Instrument.Lockin.API`

```
Instrument                    (framework, unchanged)
  Instrument.LockinAPI        (framework, unchanged)
    Instrument.Lockin.API     NEW: identity overrides + API methods, no engine types
      Instrument.Lockin       existing: the SMO (Process, Handle Command, onStart, private data)
```

`Instrument.Lockin` keeps its name and stays a descendant of `Instrument.LockinAPI`, so Transport's `Instrument.LockinAPI` slot keeps working and nothing that loads `Instrument.Lockin` by name changes. Other instruments are not touched.

**Location:** `src\Instrument.Lockin.API\Instrument.Lockin.API.lvclass`, outside `Instrument.Lockin.lvlib`; otherwise loading it loads the library and the other classes. Its private data must contain no engine types (it may be empty).

**Naming note:** `Instrument.Lockin.API` next to the framework's `Instrument.LockinAPI` is easy to misread. `Instrument.Lockin.Client` is an alternative. This spec uses `Instrument.Lockin.API`.

### Members that move to `Instrument.Lockin.API`

| Group | Members |
| --- | --- |
| Identity overrides (9, dynamic dispatch) | `Get SMO Name.vi`, `Get SMO Port.vi`, `Get SMO Vendor.vi`, `Get SMO Version.vi`, `Get SMO Serial Number.vi`, `Get SMO Public API.vi`, `Get SMO HELP.vi`, `Get SMO HELP getAll.vi`, `Get SMO Database Paths.vi` |
| `API\` (65 VIs + `setSweepTable.vim`) | all of `API`, `API\AO`, `API\DAQ`, `API\Data`, `API\Gain`, `API\Macros`, `API\REF`, `API\State`, `API\Sweep`, including `Parse Results Array (all).vi` and the other `Parse Results*` VIs used by the UI, `Instrument.DAQ` and Transport |

Check before moving: `Get SMO HELP.vi` and `Get SMO HELP getAll.vi` build example request/response clusters; after Phase 1 those use `Lockin.Types` and need nothing else. `Get SMO Public API.vi` may list API VIs by path; check it after the move.

### Stays in `Instrument.Lockin` (the SMO)

`Process.vi`, `Instrument.Lockin.AppLauncher.vi`, `Handle Command.vi`, `Handle getAll.vi`, `onStart.vi`, `CreatePrivateEvents.vi`, `Configuration Window.vi`, `Read Configuration File.vi`, `Write Configuration File.vi`, `enumerateStaticDependencies.vi`, `API (SMO)\Lockin.setLogMode.vi`, `API (SMO)\Lockin.logConfiguration.vi`, `Accessors\*`, all of `Private\` (25 VIs: logging, formatting, `Lockin.GetPrivateEvents.vi`, `Lockin.Remote Client.vi`, `Match Key Regex.vi`, `Update AO/REF Parameter.vi`, ...), the server-side typedefs listed in Phase 1, and the private data.

### Moves out of `Instrument.Lockin` to break the last cycle

- `DAQ-public\config not UI to UI (AO and AI).vi` -> `Instrument.DAQ` (its only outside caller is `Instrument.DAQ:Process.vi`; check that `Instrument.Lockin` can call it there).
- `DAQ-public\config UI to not UI (AO and AI).vi` -> `Instrument.DAQ`, as its pair (check its callers).
- `Calculate Output Sampling.vi`, `Replace Sweep Waveforms.vi`: used by `Instrument UI.Lockin:Process.vi`. They can stay in `Instrument.Lockin` (the UI is server side) or move to `Instrument.DAQ`.

### How to do the move (LabVIEW 2019)

1. Create `Instrument.Lockin.API.lvclass` with parent `Instrument.LockinAPI`. Save it.
2. Change `Instrument.Lockin`'s parent to `Instrument.Lockin.API` (class Properties > Inheritance).
3. Move the identity overrides: in the project, drag each `Get SMO *.vi` from `Instrument.Lockin` to `Instrument.Lockin.API`, then change its dynamic-dispatch input and output from `Instrument.Lockin` to `Instrument.Lockin.API` (replace the class control on the front panel; keep the connector pane). `Instrument.Lockin` inherits them.
4. Move the `API\` VIs the same way and retype their class terminals. The API VIs do not unbundle `Instrument.Lockin` private data (they only call `Client.vi`), so the retype is the whole edit; any VI that turns out broken after the retype is one that touches private data and should stay in the server class. Callers that wire an `Instrument.Lockin` object still work (a child wire fits a parent terminal).
5. Save All. Confirm: open `Get SMO Port.vi` alone; only the framework, `Instrument.Lockin.API` and `Lockin.Types` should be in memory.

The other way round (rename `Instrument.Lockin` to `Instrument.Lockin.API` and pull the server out into a new child) has fewer terminals to retype (~45 vs ~75), but every server VI unbundles the private data, which would have to be rebuilt in the new class. Not recommended.

## Transport migration

Labels do not change, so the JSON wire protocol is unchanged. Qualified names do change (`Instrument.DAQ.lvclass:Sweep.Channel--Cluster.ctl` -> `Lockin.Types.lvlib:Sweep.Channel--Cluster.ctl`, `Instrument.Lockin.lvclass:startSweep.vi` -> `Instrument.Lockin.API.lvclass:startSweep.vi`), so Transport has to be relinked once and released together with this (same rule as #164).

Transport loads the installed copy in `<user.lib>\LevyLab\Lockin-Multichannel`, not this checkout, so moving things here does not relink Transport by itself. Suggested approach:

1. Uninstall the lock-in package and replace `<user.lib>\LevyLab\Lockin-Multichannel` with a directory junction to this repo's `src\` (`mklink /J`). The package installs `src\` to that folder with the same layout, so Transport's recorded paths still resolve.
2. Open Transport's project and this repo's project in the same LabVIEW session, do the Phase 1 and Phase 2 moves, and Save All. LabVIEW relinks Transport's callers in memory, and saving writes the new qualified names under the `user.lib` paths.
3. Remove the junction, build and install the new package, open Transport and check nothing is missing or broken.

Fallback if the junction is not wanted: install the new package, open Transport and replace the disconnected typedefs by hand. Only the ~10 carrier typedefs listed above and the handful of VIs that use lock-in VIs directly (`Open Me.vi`, `Tree.vi`, `Lockin_sweep.vi`, `Lockin_time.vi`, `Results (Dictionary) to X and Y Arrays.vi`) need it; the other ~60 files follow their typedefs.

After this, Transport's sweep typedefs load `Lockin.Types` only, and its `Lockin_*` experiments load `Instrument.Lockin.API` only. `Open Me.vi` still launches the server through `Instrument.Lockin.AppLauncher.vi`, which loads the engine, as intended.

## Phase 3 (optional): package split

Phases 1-2 give Transport the light load but do not shorten the build: VIPM still packages every file under `src\` (~3 s per file). To shorten releases, build two packages: an API package (`Lockin.Types` + `Instrument.Lockin.API`) that Transport depends on, and the server (engine, UI, SMO). The server may not need to be a VIP at all if only the exe uses it. A release would then rebuild only the package that changed. This needs a second `.vipb` and a `build.cfg` per product (`build.bat "<repo root>" release <name>`), and `TAG_PREFIX` so the two products' tags do not collide. Decide after Phase 2.

## Test plan

| # | Check | Expected |
| --- | --- | --- |
| 1 | After Phase 0: build the VIP | builds; no Caraya or `Tests.DSP.lvlib` in the package dependencies (the friend entry points outside `src\` and must not be pulled in); mass compile of `Tests\` reports no broken VIs; `Tests\` VIs run from the Unit Tests project |
| 2 | After Phase 0: search `src\` for `Get State-enum.ctl`, `TerminalConfiguration--ring.ctl`, `Instrument.DAQ.lvclass` + `Simulation Mode` | no hits |
| 3 | After Phase 1: open `Lockin.Types.lvlib` alone | nothing else loads |
| 4 | After Phase 2: open `Instrument.Lockin.API\...\Get SMO Port.vi` alone | only framework + `Instrument.Lockin.API` + `Lockin.Types` in memory; no `Instrument.DAQ`, DAQmx, `nidaqmx` |
| 5 | Run the exe; JSON-RPC `HELP`, `getAll`, `setAO`, `setSweepTable`, `startSweep`, `getSweepData` | same replies as 3.10.4.104 (labels unchanged) |
| 6 | Unit Tests project: run all | same results as before |
| 7 | Transport: open project after relink | no missing or broken VIs; `Lockin_sweep` and `Lockin_time` run against the exe |
| 8 | Transport: open `Lockin_sweep.vi` alone | lock-in engine not in memory |
| 9 | Build the VIP and the exe | both build; release lock-in and Transport together |
