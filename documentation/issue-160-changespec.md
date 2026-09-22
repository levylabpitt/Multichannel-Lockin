# Issue #160 - change spec (A5, A1, B)

Instructions only. The reasoning behind each item is in [issue-160-random-pauses.md](issue-160-random-pauses.md).

## Status

| Item | What | Status |
|---|---|---|
| A2 | Teardown errors no longer replace the state queue | **done** |
| A4 | `Macro: Recover` ends with `DAQ: ACQUIRE`, routed through `Add State(s) to Queue` | **done** |
| A5 | Bounded retry, recovery log markers | **done** (fixes 2-5 applied, verified) |
| A1 | Parent and API see no status change during a recovery | **done** (fix 1 applied, verified) |
| B1' | Delete the parent's broken auto-restart | **done**, verified |
| B3 | Delete unreachable sweep code in the parent | **done**, verified |
| Test harness | Fake faults on the dev machine | skipped for now |
| A3, B1, B2 | | rejected - no action |

Do steps 1-4 and 6 in one sitting, run the step 6 tests on the dev machine with simulated devices, then take it to the hardware PC once.

No change here touches a JSON payload or public API, so this does not need a Transport release.

## Review of the implementation (2026-09-21)

Checked with `lvkit diff` against HEAD and, for the three small VIs, LabVIEW's own block-diagram export.

### Fixes (second review, 2026-09-21)

| # | VI | Status |
|---|---|---|
| 1 | `setStatus.vi` publishes in `False`, passes through in `True` | **done**, verified in LabVIEW's export |
| 2 | `DAQ: CREATE` / `DAQ: START` now queue `Macro: Recover` | **done**, verified |
| 3 | `DAQmx.Acquire Recovery.vi` sets `Recovering?` = F in its `True` frame | **done**, verified |
| 4 | `DAQmx.Recovery Error Handler.vi` computes the new count before the retry-or-give-up check | **done**, verified: first fault, tight loop (gives up on the 4th, i.e. after 3 attempts) and the five-hour case all behave |
| 5 | Both subVIs call `Handle Error.vi` with `Stop on Unhandled Error` = F | **done**, verified |
| 5b | Markers kept off the loop error wire: `error out` now comes from `Handle Error.vi`'s `handling error` output | **done**, verified |


**Markers are errors, not warnings:** `is warning?` = F in both subVIs (2026-09-21), so 5160 / 5161 take the same logging path as every other entry. This is safe only because 5b keeps them off the loop error wire; do not wire `Unhandled error` back to `error out`.

Side effect of 5b, no action needed: both subVIs now drop whatever arrives on their `error in` (`handling error` is clean unless publishing itself fails). Their callers only ever pass a clean wire or a warning there, so nothing is lost.

#### Fix 4 - `DAQmx.Recovery Error Handler.vi` (done; kept for reference)

**What "the window" is.** The 10-second rule: an attempt adds to the count only if the previous attempt was less than `Window (s)` ago; otherwise the count restarts at 1. In your diagram that rule is the `now` - `Last Attempt (s)` <= `Window (s)` comparison and the Select with the constant `1`, inside the `True` frame.

**The problem.** The retry-or-give-up case is selected from the count **left over from the last recovery**, before that restart-at-1 rule runs, because the rule sits inside the `True` frame. Nothing resets the count when a recovery succeeds, so:

| Time | Event | Count read | Decision | Count after |
|---|---|---|---|---|
| 09:00:00 | fault | 0 | retry | 1 |
| 09:00:02 | fault | 1 | retry | 2 |
| 09:00:04 | fault | 2 | retry | 3 |
| 09:00:06 | fault | 3 | retry (4th attempt), succeeds | 4 |
| 14:00:00 | one ordinary underflow | **4** | **give up** | 0 |

At 14:00 the five hours since the last attempt are never considered, because the rule that would restart the count at 1 is in the frame that did not run.

**The fix is a rewire; no new logic.**

1. Move these out of the `True` frame to the left of the case structure: the Unbundle (`Attempts`, `Last Attempt (s)`), the `+1`, the stopwatch (`now`), the Subtract, the `<=` against `Window (s)`, and the Select with the constant `1`.
2. Delete the outer Unbundle of `Recovery.Attempts`. Wire the **Select's output** (the new count) into the `<=` against `Max Attempts` instead.
3. `True` frame: wire the new count into the Bundle's `Attempts` and `now` into `Last Attempt (s)`, through tunnels. `retry?` stays T.
4. `False` frame: unchanged. Optionally feed the new count into the 5161 message's `%d attempts` instead of the unbundled old one.

Afterwards, the 14:00 fault computes a new count of 1 (last attempt five hours ago) and retries, and a tight loop gives up after exactly 3 attempts instead of 4.

#### 5b - keep the markers off the loop error wire (done; kept for reference)

In both subVIs `error out` is wired from `Handle Error.vi`'s **`Unhandled error`** output, which is its `error in` unchanged, i.e. the 5160 / 5161 cluster itself. That goes onto the loop error wire in `Process.vi`. **It is harmless today only because the cluster is a warning** (`is warning?` = T): JKI diverts only on status TRUE, and in `DAQ: ACQUIRE` the next iteration's `Is Value Changed` case drops the warning, so it is logged once.

- **Do not change `is warning?` to F without also doing the next step.** A 5160 error on the loop wire sends the state machine to `Error Handler` -> `Macro: Stop`, which would stop acquisition immediately after every successful recovery.
- Recommended: wire each subVI's `error out` from its own **`error in`** terminal, branched before the case structure, and leave `Unhandled error` unwired. Then the marker only goes to the log, and `is warning?` can be either value.
- Why you might want F: whether the logger records warnings is untested (SMO `Handle Error.vi` publishes them, since it fires on status OR non-zero code). If a 5160 does not show up in the log on the first hardware run, this is the first thing to check.

### Verified correct

- `DAQ: ACQUIRE` `"Error"`: `Recovering?` <- `DAQmx Error?` and `Fault` <- `setWaveforms.vi` error, bundled **before** `setStatus.vi`.
- `DAQmx.Error Handler.vi`: `DAQmx Error?` unchanged; new `retry?` output; bundles `Recovering?` := `Recovering? AND DAQmx Error?`.
- `Macro: Recover` queues the five states on `retry?`, else `Macro: Stop`, through `Add State(s) to Queue`.
- `Recovering?` = F in `Macro: Stop` and `Error Handler`.
- `Data: Process State`: reset branch gone; `DAQ.getDAQState.vi` class and error correctly rewired.
- Timeout case reads `"idle, stopped, sweeping"`; `Macro: Sweep`, `Sweep: Wait`, `Sweep: Status` gone and nothing references them; `Data: Process Sampling` cleaned.

### Notes, no action needed

- Because `DAQmx.Error Handler.vi` is shared by all five `DAQ: *` frames, an **unrecognised** error in `DAQ: STOP` or `DAQ: CLEAR` mid-recovery now clears `Recovering?`. The recovery still completes (A2); it just stops being suppressed and logs no 5160. Acceptable.
- lvkit reads a changed execution flag (shared clone -> non-reentrant) in **both** edited `Process.vi` files. You have confirmed shared clone in LabVIEW, so this is probably an lvkit misread; the only reason to glance at VI Properties > Execution again is that both flipped together.
- B3 also removed five parent front-panel indicators (`waiting (s)`, `Sweep Wait`, `sweeping (s)`, `Sweep Time`, `sweep remain (s)`). The deleted sweep states were writing them, which lvkit had not shown, so the reasoning doc's "compute and discard" description of those frames was wrong on that point. Since the states were unreachable, the indicators never updated anyway.

## Before you start

- Reentrancy: see the note under Review.

## Step 1 - recovery state (new typedef, one private-data field)

1. Create `src/DAQmx/typedefs/DAQmx.Recovery--Cluster.ctl` (strict typedef), add it to `DAQmx.lvclass` under typedefs:

   | Label | Type | Default |
   |---|---|---|
   | `Recovering?` | Boolean | F |
   | `Attempts` | I32 | 0 |
   | `Last Attempt (s)` | DBL | 0 |
   | `Fault` | error cluster | no error |

2. Add a field `Recovery` of that type to the `DAQmx.lvclass` private data.

`Process.vi` and `setStatus.vi` are both class members, so they read and write this with plain Bundle / Unbundle By Name. The existing class shift register already carries it through every state; no new shift register is needed.

## Step 2 - A5, bounded retry (all in `src/DAQmx/Process.vi`)

Two new constants, placed in `Macro: Recover` and labelled: **`Max Attempts` = 3** (I32) and **`Window (s)` = 10** (DBL). An attempt counts toward the limit only if it comes within `Window (s)` of the previous attempt, so sporadic faults recover forever and only a tight loop gives up.

Logging below always means: build the cluster with `Error Cluster From Error Code.vi`, pass it to **`DAQmx.lvclass:Handle Error.vi` with `Stop on Unhandled Error (T)` wired to FALSE**, and do **not** wire its error outputs anywhere. Leaving that input at its default of TRUE self-terminates the DAQmx process.

### 2a. `DAQ: ACQUIRE` -> inner case -> `"Error"` frame

On the class wire between `DAQmx.Error Handler.vi` and `setStatus.vi` (the one with the `error` constant), insert a Bundle By Name:

- `Recovery.Recovering?` <- `DAQmx.Error Handler.vi` output `DAQmx Error?` (the same boolean your `Macro: Stop` / `Macro: Recover` Select already uses)
- `Recovery.Fault` <- the error **going into** `DAQmx.Error Handler.vi` (i.e. `setWaveforms.vi` error out, before it is cleared)

It must sit before `setStatus.vi` on the class wire; step 3 relies on that ordering.

### 2b. `Macro: Recover`

Replace the frame body with:

1. `now` = `High Resolution Relative Seconds.vi`.
2. Unbundle `Recovery`.
3. `Attempts` = (`now - Last Attempt (s)` <= `Window (s)`) ? `Attempts + 1` : `1`. `Last Attempt (s)` = `now`.
4. Case on `Attempts <= Max Attempts`:
   - **True (retry):** queue as today - your `Add State(s) to Queue` with the five states in `State(s) in Front` and Remaining States in `State(s) in`. Bundle `Attempts` and `Last Attempt (s)` back.
   - **False (give up):** log code **5161**, `is warning?` = F, message `Gave up recovering from DAQmx error %d after %d attempts within %g s; acquisition stopped` (from `Fault.code`, `Attempts`, `Window (s)`). Bundle `Recovering?` = F, `Attempts` = 0. Queue `Macro: Stop` via `Add State(s) to Queue` (`State(s) in Front`), Remaining States in `State(s) in`.

### 2c. `DAQ: CREATE` and `DAQ: START` -> inner case -> `"Error"` frame

Same edit in both frames:

1. Unbundle `Recovery.Recovering?` from the class coming out of `DAQmx.Error Handler.vi`.
2. `retry?` = `Recovering?` AND `DAQmx Error?`.
3. Replace the `DAQ: CLEAR` string constant on the state-queue tunnel with a Select: `retry?` ? `Macro: Recover` : `DAQ: CLEAR`. Keep it **replacing** the queue (do not route through `Add State(s) to Queue`), so the stale `DAQ: START` / `DAQ: ACQUIRE` are discarded.
4. Bundle `Recovery.Recovering?` <- `retry?` onto the class wire before it leaves the inner case.

Leave the `error` status constant alone. Effect: a bring-up failure during a recovery retries within the budget; a bring-up failure on a user-initiated Acquire aborts exactly as today.

### 2d. `DAQ: ACQUIRE` -> inner case -> `"No Error"` frame (success marker)

After the existing `Is Value Changed` case, on the class wire, add a case on `Recovery.Recovering?`:

- **True:** log code **5160**, `is warning?` = **T**, message `Recovered from DAQmx error %d after %d attempt(s)` (from `Fault.code`, `Attempts`). Bundle `Recovering?` = F.
- **False:** pass the class through.

Do **not** call `setStatus.vi` here. With step 3 the parent's last-seen status is already `started`, and publishing it again would overwrite the `sweeping` state the API shows during a sweep.

### 2e. Clear the flag on every teardown

Add a Bundle By Name `Recovery.Recovering?` = F on the class wire in:

- `Macro: Stop`
- `Error Handler`

This is the safety net: anything that ends in a teardown publishes normally. (Give-up and the non-recoverable `DAQ: ACQUIRE` branch both go through `Macro: Stop`.)

## Step 3 - A1, suppress status publication while recovering (`src/DAQmx/private/setStatus.vi`)

In the `"No Error"` frame, Unbundle By Name `Recovery.Recovering?` from `DAQmx in` and wrap the existing `Generate User Event` in a case on it:

- **False:** as today.
- **True:** skip the event; wire `error in` to `error out`.

`Process.vi` is the only caller of `setStatus.vi`, so nothing else is affected. Result: during a recovery the parent keeps its `started`, `Data: Process State` never runs, and the API never sees idle or a transition. On give-up, `Recovering?` is already F, so the teardown statuses publish and the parent ends at idle.

## Step 4 - B1', delete the parent's auto-restart (`src/Instrument.DAQ/Process.vi`, state `Data: Process State`)

The frame has two case structures on `DAQmx Status`. **Keep the first** (11 frames, feeds the 0/1/2/3 constants into `DAQ.getDAQState.vi`).

1. Delete the **second** one entirely - it comes after `DAQ.getDAQState.vi`, has frames `"error"` and `Default`, and contains a case on `DAQ Status` whose `"started"` frame calls `DAQ.setstate.vi` with `reset`. Delete the structure and its contents; do not use "Remove Case Structure".
2. Wire `DAQ.getDAQState.vi` class out -> the `SelfRef` input of the Bundle By Name that also writes `DAQ Status`.
3. Wire `DAQ.getDAQState.vi` error out -> the frame's error output tunnel.
4. Remove the now-unused `DAQ Status` element from the frame's first Unbundle By Name (the one that also outputs `DAQmx Status`), and delete the free label "send signal to restart".

## Step 5 - B3, delete unreachable sweep code (`src/Instrument.DAQ/Process.vi`) - optional

None of this can run today (`DAQ Status` is never set to `sweeping` in the Core Data cluster), so deleting it changes nothing at runtime. Skip it if you would rather not touch the parent twice.

1. `""` state -> event `[0] Timeout` -> case on `DAQ Status`: delete the `"sweeping"` frame and add `sweeping` to the `"idle, stopped"` frame's selector, so it reads `"idle, stopped, sweeping"`.
2. Delete the state frames `Macro: Sweep`, `Sweep: Wait` and `Sweep: Status`. **Keep `Sweep: Initialize`** - `setState` `start sweep` still queues it.
3. `Data: Process Sampling`: delete the `Equal?` (`DAQ Status` = `started`), the `And` with its FALSE constant, the `Select` and its two string constants. Its output is not wired to anything. Remove `DAQ Status` from that frame's Unbundle By Name. If deleting the Select leaves a broken wire, stop and tell me - it would mean lvkit missed a connection.
4. Do **not** remove `sweeping` from `Status--enum`; the Generator sweep-status event publishes it to the API.

If anything still queued a deleted state, the parent's `Default` frame raises error 42 "Unhandled State", so a missed reference fails loudly.

## Step 6 - fault-injection harness (dev machine) - recommended

Default-off, so it is harmless if left in, but remove it before a release.

1. `src/DAQmx/Tests/Issue160 Faults--Global.vi` (global variable): booleans `@ACQUIRE`, `@STOP`, `@CREATE`, `@START`, `Sticky?`; I32 `Code` = -200621.
2. `src/DAQmx/Tests/Inject Fault.vi`: inputs `Site` (enum ACQUIRE / STOP / CREATE / START) and `error in`; output `error out`. If `error in` is clean and the global's flag for `Site` is set: return `Error Cluster From Error Code.vi` with `Code` and message `Injected fault at <Site> (#160 test)`, and clear the flag unless `Sticky?`. Otherwise pass `error in` through.
3. In `src/DAQmx/Process.vi`, insert `Inject Fault.vi` on the error wire that feeds each inner error-case selector:

   | State | Between | `Site` |
   |---|---|---|
   | `DAQ: ACQUIRE` | `setWaveforms.vi` error out and the selector | ACQUIRE |
   | `DAQ: STOP` | `Sync.Stop.vi` error out and the selector | STOP |
   | `DAQ: CREATE` | `Sync.Create.vi` error out and the selector | CREATE |
   | `DAQ: START` | `Sync.Start.vi` error out and the selector | START |

Run with simulated devices, open the global's front panel, and click flags while the lock-in runs. Each injected fault is published and logged like a real one.

### Tests

| # | Set | Expect in the log | Expect on screen |
|---|---|---|---|
| T1 recover | `@STOP` first, then `@ACQUIRE`, while acquiring | injected ACQUIRE, injected STOP, then **5160** "after 1 attempt(s)" | acquisition continues; parent status stays `started` throughout |
| T2 give up | `Sticky?` + `@CREATE` first, then `@ACQUIRE`, while acquiring | injected ACQUIRE, 3 x injected CREATE, then **5161** | statuses go stopping / stopped / idle; Acquire works again after clearing the flags |
| T3 user start fails | idle, `@START`, then press Acquire | one injected START; no 5160 / 5161 | ends idle, as today |
| T4 not recoverable | `Code` = 1, `@ACQUIRE` while acquiring | error 1; no 5160 / 5161 | stops, as today. Set `Code` back to -200621 |
| T5 storm | `Sticky?` + `@ACQUIRE` while acquiring | 3 recoveries within 10 s, then **5161** | stops after about three cycles |

Every log entry appears three times (once per SMO level); that is normal.

## Hardware PC

Run overnight unattended. Pass: every -200621 is followed by a **5160**, there is no **5161**, and nobody had to press Acquire. If a 5161 appears, the attempt count and window in its message say whether the budget needs tuning or the hardware is genuinely stuck.

After you make the edits, I can run `lvkit diff` against HEAD on each changed VI to confirm nothing extra moved.
