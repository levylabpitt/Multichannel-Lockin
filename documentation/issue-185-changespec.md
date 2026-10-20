# Issue #185 - setSweepTable applies only the last table (change spec)

**Problem.** When sweep tables (`{Channel, Table}` pairs) are merged into the sweep channels, only the **last** table is applied. For each channel the code loops over all the new tables, but it carries the match result and the table out of that loop through **last-value** tunnels, so only the final entry is ever compared. With tables for channels 1 and 2, channel 1 keeps its old table and only channel 2 is updated.

**Where.** The same buggy loop exists in two VIs:

| VI | Used by |
| --- | --- |
| `src/Instrument.Lockin/DAQ-public/Replace Sweep Waveforms.vi` | **production**: `Instrument.Lockin/Overrides/Handle Command.vi` (the `setSweep` / `setSweepTable` commands) and `Instrument UI.Lockin/Process.vi` (the sweep panel) |
| `src/Generator/Sweep/Insert Sweep Tables.vi` | Generator tests only (an older copy kept for testing) |

The fix must go into `Replace Sweep Waveforms.vi`. It uses the `Instrument.DAQ` typedefs that are on the wire (`Sweep.Configuration--Cluster` with `sweepChannels`, and `Lockin.setSweep_Table--cluster`).

**Scope.** No connector-pane or wire change. Read with lvkit on `develop` on 2026-10-20. Channel 0 is not used by the lock-in, so the existing skip for channel 0 stays.

## Edit: `Replace Sweep Waveforms.vi`

Use the algorithm already implemented and tested in `Insert Sweep Tables.vi` on 2026-10-20:

1. Build the array of configured channel numbers from `sweepChannels`, and the array of channel numbers from `Channels New`.
2. Lookup loop over `Channels New`: `Search 1D Array` for each table's channel in the configured channels. Through conditional tunnels (index >= 0), collect both the **channel index** and the **table index** (`i`).
3. Replace loop over the collected pairs: take the table at its table index and write it into the channel at its channel index (In Place Element on the channel array).
4. If the same channel appears twice in `Channels New`, both are applied in order, so the **last** one wins. Say so in the VI description.

The final loop that unbundles and re-bundles every channel field by field does nothing and can be removed.

## `Insert Sweep Tables.vi`

Nothing in production calls it. Either delete it and point the Generator tests (`Test Sweep Generate Waveforms.vi`, `Test Sweep Manager.vi`, `Test Sweep Manager Subsystems.vi`) at `Replace Sweep Waveforms.vi`, or keep it only as a test helper. Do not keep two independent implementations.

## Test

Point `Test Insert sweepTable.vi` at `Replace Sweep Waveforms.vi` (the same cases, with the `Instrument.DAQ` types), and keep it outside `src` so it is not packaged:

| Input | Expect |
| --- | --- |
| channels 3, 4; tables for 3 and 4 | both applied |
| tables differ from the configuration before the call | the "not equal before" check |
| a table for channel 5 only | configuration unchanged |
| `[{5, ...}, {3, [7, 7]}]` on channels 3, 4 | channel 3 = `[7, 7]`, channel 4 unchanged |
| channels 1, 2, 3; tables for 1 and 3 | channels 1 and 3 updated, channel 2 keeps its table |

## Related

- levylabpitt/Transport#181: Transport stops calling `setSweepTable` and sends tables only in `sweepChannels[].Table`. The `setSweepTable` command and the UI's separate sweep-pattern control still go through `Replace Sweep Waveforms.vi`, which is why it must be fixed.
- The Generator's own `Sweep.Configuration--Cluster.ctl` still has the pre-#164 labels (`Sweep Time (s)`, `Initial Wait (s)`, `Return to Start`, `Channels`). It is internal, but worth aligning separately.
