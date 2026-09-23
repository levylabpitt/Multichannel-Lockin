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
- **`build_all.bat` does not list this repo.** Its `BUILD_LIST` currently holds only `levylabpitt\Oxford-1820`, so running it builds something else. Invoke the shared script directly: `"%LOCALAPPDATA%\LevyLab\build-support\scripts\build.bat" "<repo root>"`.
- The version and the git tag come from the `.vipb`'s `<Library_Version>`, read **before** the build; the VIP build then bumps it, so the file is left one build number ahead of the tag it just released. The `.lvproj`'s `Bld_version` and `INST_productVersion` do not matter to the scripted build - `lvBuild` is called with `-versionNumber "<that version>"` for both specs - so they go stale and only affect a build started from the project UI.
- The GitHub release body is the `.vipb`'s `<Release_Notes>`, which `build.bat` extracts with PowerShell (`SelectSingleNode('//Release_Notes').InnerText`) and passes to `gh release create -F`. Edit the release notes there, not in the `gh` command. The `.vipb` is XML, so a script can rewrite that element - remember to XML-escape.
- `build.bat` has **no pre-release option**; `gh release create` is called without `--prerelease`. Mark a pre-release afterwards with `gh release edit <tag> --prerelease`.
- `DO_RELEASE=true` makes the build run `git add -A` and commit everything in the working tree as "Release x". Commit real work with its own message first, or it disappears under that one line.
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

- Use lvkit first. As of lvkit 0.8.4, `lvkit index` on this repo hangs (30+ min with no output), so index-backed calls (`index`, `query`, `callers`, `blast-radius`) time out. Everything below works without the index.
- **`lvkit describe --format lvnet <file.vi>` is the workhorse.** It prints the connector pane plus the **full wiring** - every node with each input's source net - not just a list of the VIs called, which is what plain `describe` gives. It is how to read a state machine frame by frame: dump it to a file and grep for the frame name. About 25 s for a small VI, ~50 s for `Instrument.DAQ\Process.vi`; run several in parallel. `-v` adds a `types :` appendix with the field names of typedefs that appear on the pane.
- `describe` does not accept `.ctl` files, and a typedef's field labels are not recoverable from the file with `strings`. Read them from the `types :` appendix of a VI that carries the typedef on its connector pane.
- **`read_vi` (JSON) is the decisive read for case structures.** Each frame carries its own `"value"` (`"True"` / `"False"` / the selector string) next to its body, and every structure output lists its per-frame source. Use it whenever the polarity of a case matters - an inverted `Empty Array?` gate is invisible in a summary and catastrophic in the code. It also reports `health.is_broken`.
- **`lvkit render --format svg -o out.svg` writes a text file**, so every label on the diagram can be pulled out with a regex over the `<text>` elements rather than looking at an image. Useful for reading bundle/unbundle field labels and comment text quickly.
- lvkit is wrong in known ways:
  - **Class private-data field labels are scrambled, not merely unreliable** - in the lvnet *and* in the SVG render. `Divide` and `Multiply Amplitude and Offset by Output Gain.vi` are mirror VIs and render the same two fields under different names. **Identify a class field by its type** (a `[Sweep.Channel--Cluster]`, a `[Channel.Gain--Cluster]`), never by the name lvkit prints. Typedef field labels reached through a connector pane *are* reliable.
  - Multi-value case frames report only their first value; local variable names are unreliable; event-structure timeouts are not modelled.
- When the above is still not enough, render with the `lv-vi-index` skill (`--version 2019`) for LabVIEW's own image. Rendering a whole folder under `Instrument.Lockin.lvlib` is very slow (minutes per VI); call the skill's `export_one` on the specific VIs instead (pass Windows-style output paths, or LabVIEW reports "folder path does not exist"). LabVIEW's print does not emit every case frame: `Instrument.DAQ\Process.vi` renders 163 pages but has no page for "Data: Process AO Channels".
- To tell whether a **connector pane** changed, check whether the owning `.lvclass` is dirty in git: LabVIEW caches each member's pane in the class file as `NI.ClassItem.ConnectorPane`, so an unmodified `.lvclass` means no member's pane changed. Method scope lives there too (`NI.ClassItem.MethodScope`, 2 = private) - useful for checking whether a test VI may call a private member.
- After removing a terminal from a VI, its **callers on disk are stale** until they are saved: LabVIEW relinks them in memory but the files keep a call record for the removed slot, which shows up in the lvnet as an output named by bare index. Save All before reading anything back.
- `.lvproj`, `.lvlib`, `.lvclass` and `.vipb` are XML and can be read as text. Item URLs in them are relative to the file itself (`../X.vi` is a sibling of the `.lvclass`). A class's `<Class>.ctl` entry is its private data stored inside the `.lvclass`, not a missing file.
