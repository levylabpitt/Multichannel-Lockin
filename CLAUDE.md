# Multichannel Lockin

Multichannel lock-in amplifier for NI Dynamic Signal Acquisition cards (4431/4461/4462): synchronized multi-card AO generation (sine, square, sawtooth, triangle, DC, sweeps) and multi-frequency demodulation of every AI. LabVIEW 2019 64-bit. Git-flow: day-to-day work happens on `develop`; `main` only receives release merges.

## What ships

Two products come out of this repo:

1. **LabVIEW API package** (VIPM) - built from `build support\Multichannel Lockin.vipb` (package `LevyLab_lib_Lockin_Multichannel`, source folder `src\`, output `builds\Package`). It installs to `<user.lib>\LevyLab\Lockin-Multichannel`. Other repos (notably levylabpitt/Transport) link against this installed copy, not against this checkout.
2. **Multichannel Lockin.exe** - build spec "Multichannel Lock-In (x64) Application" (and "... Installer") in `Multichannel Lock-In (x64).lvproj`, output `builds\Application (x64)`. The installer is published on the GitHub releases page (`gh release ...`); `builds\Inno.iss` / `builds\inno_build.bat` wrap the LabVIEW installer with Inno Setup.

Release versions live in the build spec (`Bld_version.*`) and in the `.vipb` (`Library_Version`); they are bumped separately.

## Building and releasing

- Releases go through the shared `build.bat` from levylabpitt/build-support, normally run by "Patrick Builder" via `%LOCALAPPDATA%\LevyLab\build-support\scripts\build_all.bat`. It reads `build support\build.cfg`: builds the VIP, clears the compiled cache, builds the app spec (`APP_SPEC`) then the installer spec (`INST_SPEC`), and with `DO_RELEASE=true` commits "Release x" on `develop`, merges to `main` with `--no-ff`, tags on `main`, pushes both branches and the tag, and runs `gh release create`. A full run takes about 45 minutes (VIP ~27 min, app ~14 min).
- `APP_SPEC` and `INST_SPEC` must match the build-spec names in the `.lvproj` exactly (`Multichannel Lock-In (x64) Application`, `Multichannel Lock-In (x64) Installer`). A mismatch fails only in the scripted build, as lvBuild error 1 "The build specification ... was not found" (LabVIEW's "GPIB Controller-In-Charge" explanation for error 1 is irrelevant); building from the project UI works because the spec is picked by clicking.
- A failed `build_all.bat` run still leaves side effects: the VIP build bumps the version in the `.vipb`, `.lvproj` and `src\Lockin.Utilities\Application Version.vi` (left uncommitted), and Patrick Builder's publish step afterwards pushes the staged `.vip` to the VIPM repository even though no tag or GitHub release was made.
- `builds\build_vip.bat` is an older per-release script (version hard-coded) from before `build.cfg`. Treat it as a record, not a script to rerun.
- Release tags sit on the merge commits on `main`, so `git describe` on `develop` reports an older release. Get the newest release with `gh release view --json tagName -q .tagName`.

## Layout

- `Multichannel Lock-In (x64).lvproj` - the main project: `Instrument.Lockin.lvlib`, `Waveform.Attributes.lvlib`, the `DAQ`, `DAQmx`, `Generator`, `DSP` classes, `src\Examples`, `build support`, and the build specs.
- `Multichannel Lock-In (x64) - Unit Tests.lvproj` - tests under `Tests\` (Caraya).
- `Multichannel Lock-In (x64) - Experiments.lvproj` - scratch work under `experiments\` (filters, PLL, performance). Not shipped.
- `src\Instrument.Lockin.lvlib` - the instrument itself:
  - `Instrument.Lockin` - public API class (`API\`, `API (Class)\`, overrides of the Instrument Framework). Parent class is the Instrument Framework's `Instrument.LockinAPI`.
  - `Instrument.DAQ` - acquisition/sweep engine (SMO) driving `DAQmx`, `Generator`, `DSP`.
  - `Instrument UI.Lockin` - the front-panel UI.
- `src\Generator` (AO/REF waveform generation SMO), `src\DAQmx` (hardware tasks, sync, clipping), `src\DSP` (demodulation, filters, PLL pieces), `src\Waveform.Attributes` (waveform attribute get/set VIs).
- `reference\` holds NI examples kept for reference; `documentation\` holds README images and notes.

## Contracts with levylabpitt/Transport

- Transport's `Lockin_time` and `Lockin_sweep` experiments drive this lock-in through its API. `Lockin_sweep.vi` calls this repo's `Instrument.Lockin\API\setSweep.vi` and builds `Sweep.Configuration--Cluster` constants with Bundle By Name.
- #164 renamed the sweep configuration fields here to match the Transport Server (`Sweep Time (s)` -> `sweepTime`, `Initial Wait (s)` -> `initialWaitTime`, `Return to Start` -> `returnToStart`, `Channels` -> `sweepChannels`). These labels are the JSON keys on the wire. Rename them in both repos or neither, and release the API package, the exe and Transport together.
- Transport's Control Experiment loads `Instrument.Lockin` into a slot typed as the Instrument Framework's `Instrument.LockinAPI`. `Instrument.Lockin` must stay a descendant of `Instrument.LockinAPI`.

## JSON command payloads

The Instrument Framework parses command payloads with `JSON to LVtype.vim`, which silently ignores unknown keys and returns defaults. A wrong or stale key therefore looks like "received, no error, no effect". Any rename of a cluster label that is part of a command payload is a wire-protocol change; check both sender and receiver.

## Reading the LabVIEW code

- Use lvkit first (`index`, `query`, `read_vi`, `diff`, or the `lvkit` CLI). As of lvkit 0.8.4, `lvkit index` on this repo hangs (30+ min with no output), so index-backed MCP calls (`index`, `query`) time out. Per-VI `lvkit describe <file.vi>` works (about 25 s each); run several in parallel. `describe` does not accept `.ctl` files; read a typedef's fields from the signature of a VI that uses it.
- lvkit is wrong in known ways: multi-value case frames report only their first value, local variable names and class private-data field labels are unreliable, and event-structure timeouts are not modelled. Never conclude something is missing or unused from lvkit alone; render it with the `lv-vi-index` skill first (`--version 2019`). Rendering a whole folder under `Instrument.Lockin.lvlib` is very slow (minutes per VI); call the skill's `export_one` on the specific VIs instead (pass Windows-style output paths, or LabVIEW reports "folder path does not exist"). LabVIEW's print does not emit every case frame: `Instrument.DAQ\Process.vi` renders 163 pages but has no page for "Data: Process AO Channels".
- `.lvproj`, `.lvlib`, `.lvclass` and `.vipb` are XML and can be read as text. Item URLs in them are relative to the file itself (`../X.vi` is a sibling of the `.lvclass`). A class's `<Class>.ctl` entry is its private data stored inside the `.lvclass`, not a missing file.
