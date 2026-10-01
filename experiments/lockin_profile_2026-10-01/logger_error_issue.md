# Events: ReRegister appends duplicate SMOs every 30 s, so List Dependencies Recursive cost grows without bound

## Summary

`Process.vi` re-runs `Events: ReRegister` every 30 s. Each time, it appends the full dependency set to the stored SMO list without removing duplicates, so the list grows by about one copy of the dependency set (about 8 SMOs in Multichannel Lockin) every 30 s for the life of the process. `List Dependencies Recursive.vi` walks the whole list on every ReRegister, so its cost grows linearly with uptime. In a Multichannel Lockin session, one walk took 9 ms at startup and 895 ms after about an hour.

Found while profiling levylabpitt/Multichannel-Lockin (LabVIEW 2019 64-bit) against the installed Logger.Error package. The installed copy matches `develop` at `012a32d` (Release 1.2.3.10).

## Where

`src/Logger.Error/Process.vi`:

- **Timeout frame** of the event structure: `Periodic Trigger__ogtk` set to 30000 ms queues `Events: ReRegister` each time it fires. `Macro: Initialize` also queues one after `UI: Wait >> 1000`.
- **`Events: ReRegister` frame**:
  1. Unbundles the stored `[SMO.lvclass]` list from the state cluster.
  2. Calls `List Dependencies Recursive.vi` with it.
  3. Uses **Build Array** to join `SMOs out` (which is the input list passed straight through) with `[Dependencies]` (the distinct SMOs visited).
  4. Calls `Is Value Changed.vim` on the result. If it changed, it bundles the result back into the state as the new list and re-registers for the `Error` user event of every element.

`[Dependencies]` already contains every distinct SMO, including the ones in the input list (each popped SMO that has not been seen is added to the visited array). So step 3 adds about one duplicate of every SMO each time. The list always grows, so `Is Value Changed` is always true, and the event registration is rebuilt every 30 s with an ever larger array of duplicate `Error` event refnums.

`src/Logger.Error/List Dependencies Recursive.vi` puts every list entry, duplicates included, through its worklist. Each pass calls `GetGUID` on the popped SMO and again on every SMO visited so far (to rebuild the GUID array for `Search 1D Array`). So cost per walk is about (list length) x (number of distinct SMOs + 1).

## Evidence

LabVIEW Profile Performance and Memory, 8-10 s windows, one running Multichannel Lockin instance, plus one fresh launch. `GetName.vi` was called 8 times in every walk and `isStateMachineObject.vi` 7 times, so the dependency graph itself did not change; only the list length did.

| Window (2026-10-01) | Time since previous | `GetGUID` calls in one walk | Walk total time | Implied list length (calls / ~9) |
| --- | --- | --- | --- | --- |
| Fresh launch, 10:57 | - | 54 | 9.3 ms | ~6 |
| 09:49 (app already up) | - | 479 | 49 ms | ~53 |
| 09:50 | ~1 min (2 ReRegisters) | 623 | 51 ms | 69 (+16) |
| 09:51 | ~1.5 min (3 ReRegisters) | 839 | 71 ms | 93 (+24) |
| 10:49 | ~58 min (~116 ReRegisters) | 9047 | 895 ms | ~1005 (+912; +928 predicted at 8 per ReRegister) |

The walk appeared in 4 of the 15 windows taken while the app had been up for a while. That is what you'd expect from a 30 s timer and 8 s windows (about 27%).

## Impact

The walk's cost grows linearly with uptime and repeats every 30 s:

| Uptime | One walk | Share of one core |
| --- | --- | --- |
| 1 h | ~0.9 s | ~3% |
| 1 day | ~20 s | ~70% |
| ~30 h | > 30 s | the logger loop never idles |

On top of that, the event registration array and the stored list grow without bound, which costs memory and makes each re-registration slower. The logger runs in its own loop, so it does not block other SMOs directly. But instruments are routinely left running for days, so this will eventually take a core and delay error logging. It's possible that registering the same user event many times also changes how often `Error` events are delivered; I haven't checked that.

## Proposed fix

In `Events: ReRegister`, store `[Dependencies]` alone: delete the Build Array and wire `List Dependencies Recursive.vi`'s `[Dependencies]` output to `Is Value Changed.vim` and to the state bundle. `[Dependencies]` is already the distinct set and includes the input SMOs, so nothing is lost. The list then stays constant, `Is Value Changed` fires only when an SMO is really added or removed, and the 30 s re-registration becomes a no-op in steady state.

Optional and minor: `List Dependencies Recursive.vi` could build the visited GUID array incrementally (append one GUID when an SMO is added) instead of calling `GetGUID` on every visited SMO on every pass.

## How to verify

Profile a running instance for a couple of minutes, or log the length of the stored SMO list in `Events: ReRegister`. After the fix, the length should stay constant (about 8 for Multichannel Lockin) and `GetGUID` calls per walk should stay near the fresh-launch value (about 54).
