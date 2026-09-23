# Issue #165 - amplified AO channel (non-unity output gain)

**Fixed 2026-09-22** (verified in LabVIEW's render): the two conversion VIs were renamed to `Divide / Multiply Amplitude and Offset by Output Gain.vi` and now scale `Offset` as well as `Amplitude`, and event 36 calls the multiply on the class wire between `Merge AO Settings from Generator.vi` and `Data: Update AO Channels`. The sweep path was converted too, and its placement fixed so the state still stores and publishes user units; see the last section.

Diagnosed 2026-09-22. Every claim below was read from the VIs; the two decisive ones were confirmed against LabVIEW's own block-diagram render, because lvkit cannot show class private-data field names.

## Cause

`Configuration.Channels.Cfg_AO` is the parent's AO configuration in **user units** (what the amplifier puts out). The Generator holds the same cluster in **card units** (user units divided by the output gain). The outbound conversion exists; the inbound one is missing, so every round trip divides by the gain again.

| Step | Where | Cfg_AO.Amplitude | Sent to Generator |
|---|---|---|---|
| user sets amplitude A | `setAO` event | A | |
| `Data: Process AO Channels` | `Divide Amplitude by Output Gain.vi` | A (not written back) | **A / G** |
| Generator generates a block | `Generator: Generate` -> `getAOchannels.vi` publishes its AO channels | | echoes **A / G** |
| parent receives the echo | event 36 -> `Merge AO Settings from Generator.vi` | **A / G** | |
| any later AO change | `Divide Amplitude by Output Gain.vi` again | A / G | **A / G²** |

- `Merge AO Settings from Generator.vi` copies **all 11 fields**, `Amplitude` included, straight into `Configuration.Channels.Cfg_AO` (confirmed in LabVIEW's render).
- `Divide Amplitude by Output Gain.vi` reads `Configuration.Channels.Cfg_AO` and `Configuration.Offset and Gain.Gain_AO`, divides **`Amplitude` only**, and writes `Cfg_AO` back (confirmed in LabVIEW's render). Within a single pass it is correct: the divided copy goes to the Generator and is not stored.
- The Generator publishes its AO channels from `Generator: Generate`, i.e. **once per block**, so the echo lands within about one block time of any change.

### What the user sees, with gain G

1. Set amplitude A. The output is briefly correct, then the echo overwrites the stored value, so the UI and the API report **A / G**.
2. Any of these re-runs the divide on the already-divided value, so the output drops by another factor of G each time: `setAO`, `setAOconfig`, `setAmplitudeLimit`, `setDCLimit`, `setDutyCycle`, `setLinkFrequencies`, `autoConfigureDAQ`, a sampling change, or a "DAQ AO" value change in the UI.

With G = 10: report 0.1 A immediately, output 0.1 A after the next change, 0.01 A after the one after that. With G < 1 it grows instead.

Unity gain is unaffected, which is why this survived to a user with an amplifier.

## Fix

**Recommended: convert back on the way in.** `src/Instrument.DAQ/support/Multiply Amplitude by Output Gain.vi` already exists, is the exact mirror of the divide VI, and **has no callers** - it looks like the return-path conversion that never got wired in during the Generator refactor. Call it on the class wire in event 36 (the Generator AO-channels event) right after `Merge AO Settings from Generator.vi`, before the state queues `Data: Update AO Channels`. One node and two wires.

That keeps the invariant explicit: Instrument.DAQ stores user units, the Generator stores card units, and the boundary converts in both directions.

Not recommended: dropping `Amplitude` from the merge. The Generator owns the amplitude during an AC sweep, so the parent does need it back; it just needs converting.

## Check without hardware

With simulated devices, set a channel's output gain to 10 and its amplitude to 1. The reported amplitude should stay 1. Before the fix it becomes 0.1 within a block, then 0.01 after any further AO change.

## Resolved: Offset

`Offset` was originally scaled by neither VI, so DC was not gain-compensated at all. Both conversions now cover it.

## Follow-on: sweep tables - converted and placed 2026-09-22

`Divide Sweep Config by Output Gain.vi` was added to `Data: Process Sweep`, so the Generator receives card units and the physical sweep is correct. The placement fix is now in as well, so the state stores and publishes user units.

Verified 2026-09-22 by reading Process.vi's wiring (`lvkit describe --format lvnet`). `Data: Process Sweep` now runs:

1. unbundle `SMO` from the state cluster -> `Initialize Sweep Channels.vi`
2. `DAQ.getSweepChannels.vi` - class input **and** sweep-config input both taken from `Initialize Sweep Channels.vi`'s output, i.e. the **undivided** class, so the publish to UI and API is in user units
3. `Divide Sweep Config by Output Gain.vi` - fed from `DAQ.getSweepChannels.vi`'s class output; its own class output feeds **only** the unbundle that produces the `Sweep.Configuration--Cluster` for `Generator.lvclass:setSweepChannels.vi`
4. the state cluster's `SMO` output is bundled from `DAQ.getSweepChannels.vi`'s class output - the undivided class - so `Configuration...Sweep` stays in user units
5. the frame's error out comes from `setSweepChannels.vi`

The Generator refnum is unbundled from the undivided class and `setSweepChannels.vi`'s `Generator out` is not bundled back, which matches `Data: Process AO Channels` (the Generator is by-reference, so the wire is a refnum pass-through).

This mirrors `Data: Process AO Channels` exactly: Instrument.DAQ stores and publishes user units, the Generator gets card units, and only the wire into the Generator is converted.

`Divide Sweep Config by Output Gain.vi` scales three fields per `Sweep.Channel--Cluster` - `Start`, `End` and `Table` - looking the gain up by `Channel - 1` in the output-gain array, and falls back to a gain of 1 when the stored gain is 0. `error out` is wired straight from `error in`.

Note when re-reading these VIs: lvkit's **class private-data field labels are scrambled**. The two mirror VIs `Divide ...` and `Multiply Amplitude and Offset by Output Gain.vi` render the same two fields under different names (`Gain_AI`/`returnToStart` vs `Cfg_AO`/`Gain_AI`/`returnToStart`), and `Divide Sweep Config by Output Gain.vi` renders them as `AO`/`Limit (V)`. The *types* are reliable, the names are not; identify a field by its type (a `[Sweep.Channel--Cluster]`, a `[Channel.Gain--Cluster]`) or render the VI with the lv-vi-index skill.

## Status

All three parts of #165 are implemented: the AO return path (event 36), `Offset` scaling in both directions, and the sweep tables. None of it has been on hardware yet - see "Check without hardware" above for the simulated-device check.
