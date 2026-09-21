# Issue #160 - "Lockin pauses randomly" - fix strategy (working document)

Status: **root cause confirmed and the exact derailment located. Strategy settled (2026-09-20): recovery lives entirely in `DAQmx.lvclass:Process.vi`; `Instrument.DAQ` only loses code, never gains any.** Nothing changed in committed code yet. There is uncommitted work in the tree (see "Uncommitted work in progress").

A second verification pass on 2026-09-20 re-checked every load-bearing claim by an independent route. The code findings held; two readings of the **error log** were refuted or corrected and are marked in place. See "Verification pass".

Issue: https://github.com/levylabpitt/Multichannel-Lockin/issues/160 (open, "Status: In Progress" since 2026-05-26)

Keep this file updated as decisions are made. Each candidate change carries a status: **proposed / accepted / rejected / done**.

## Symptom

The lock-in stops acquiring, transitions to `idle`, and sits there until a user notices and clicks Acquire again. Happens mid-sweep as well. Previously believed to be time-based ("every few hours"); it is not - see below.

## Confirmed root cause

**AO onboard buffer underflow, DAQmx error -200621**, at `DAQmx.lvclass:DAQmx.Write.vi`:

> Onboard device memory underflow. Because of system and/or bus-bandwidth limitations, the driver could not write data to the device fast enough to keep up with the device output rate.

Evidence: production error log `2026-09-16 124426 Errors.txt` (one app run, 09-16 12:44 through 09-19 17:52). That file is on the lock-in machine's account and is **not** on the dev machine, so the counts below are as originally recorded and could not be re-read during the 2026-09-20 verification pass.

- 126 x -200621, in **18 bursts**.
- Every burst has the same signature: **3 x `DAQmx.Write.vi`** then, ~300 ms later, **3 x `DAQmx Stop Task.vi`** with the same code.
- **The 3 is not three tasks.** Every error in this logger appears exactly three times, once per SMO level, in the fixed order `DAQmx.lvclass:DAQmx` -> `Instrument.DAQ.lvclass:Instrument-DAQ` -> `Instrument.Lockin.lvclass:Multichannel-Lockin`, tens of ms apart, with identical Task Name and identical Call Chain. See "Reading the error log" below. **Divide every count by three.** So a burst is **one** Write underflow and, ~300 ms later, **one** Stop Task error, and the whole log holds 42 error events, not 126.
- Consequently there is **no evidence that all three AO cards stall at once**; the Task Name in each triplet is a single task. An earlier reading of this log concluded "system-wide stall, not one bad card". That conclusion is withdrawn. Worse, the question is **not answerable from the log at all**: `DAQmx.Write.vi` merges its per-task errors before reporting, so one underflow and three look identical. See "Key facts".
- 126 / 6 = 21, not 18, so the burst tally and the per-burst composition should be recounted against the real file. Some bursts evidently contain more than one Write or one Stop.
- Burst spacing (13 min ... 1476 min) is **how long it took someone to notice and restart**, not a natural period. -200621 only occurs while acquisition is running, and acquisition only runs after a manual start.
- Also present: 6 x 402844 (`JSONtext.lvlib:Scalar JSON text to Variant`) on 09-16 only. Believed knock-on / unrelated. Not investigated. (6 = 2 events.)

### Local corroboration (dev machine, available)

`%LOCALAPPDATA%\LevyLab\Error Logs\Multichannel-Lockin` on the dev account holds 8 logs from 2026-09-19, 33 entries = 11 triplets, four codes, five app runs, **no exceptions to the triplet rule**. Two of them exercise the paths in this issue:

- `2026-09-19 224252`: -200279 at `DAQmx.lvclass:DAQmx.Read.vi` ("the application is not able to keep up with the hardware acquisition" - the AI-side twin of the AO underflow). -200279 is inside the child's filter range, so it takes the **identical** `DAQ: ACQUIRE` error path and the identical derailment. One event at 22:43:39; that log then ends and the next app launch is at 22:44:24, 45 s later. That is the predicted signature: fault, machine parks, human restarts.
- `2026-09-19 194825` and three others: -200488 / -200486 with Call Chain `DAQmx.Clip AO Waveforms.vi -> DAQmx.Write.vi -> DAQmx.Start AO.vi -> Sync.Start.vi -> Process.vi`, i.e. the `DAQ: START` error path. These are the property-node bug under "Adjacent work", now fixed.

The underflow itself is environmental and is not the thing to fix. The thing to fix is that a recognised, cleared, recoverable error ends in a dead state machine.

## Mechanism - verified, state by state

This is the sequence for the **committed** code (what production ran). Every step below was read out of the VIs, not inferred.

1. `DAQ: ACQUIRE` calls `Sync.Acquire.vi`, which does both the AI read and the AO write. `DAQmx.Write.vi` returns -200621.
2. The `"Error"` frame of that state runs `DAQmx.Error Handler.vi`. That VI calls `Handle Error.vi` **first**, which fires the DAQmx SMO's public `Error` user event (this is what puts the entry in the error log, and why filtered codes still appear there), and only then does `Filter Error Codes__ogtk.vi` run. -200621 is in the list, so `DAQmx Error? = True` and `error out = (default Error)`: **the error is cleared on the local wire, after it has already been published.**
3. The frame then sets DAQmx status to `error` (10) and sets the state queue to the string constant `Macro: Stop\nDAQ: CREATE\nDAQ: START  `. This is a **constant wired straight to the state-queue tunnel**, so it replaces whatever was queued. At `DAQ: ACQUIRE` time nothing else is queued, so no harm yet.
4. `Macro: Stop` uses `Add State(s) to Queue` properly (Front = `DAQ: STOP\nDAQ: CLEAR`, In = Remaining States), so the queue becomes `DAQ: STOP / DAQ: CLEAR / DAQ: CREATE / DAQ: START`.
5. `DAQ: STOP` sets status `stopping` (7) and calls `Sync.Stop.vi`. Stopping a task that is holding a latched error re-raises -200621 (this is the `DAQmx Stop Task.vi` entry in every burst).
6. **Here is the bug.** The `"Error"` frame of `DAQ: STOP` sets status back to `error` (10) and drives the state-queue tunnel from a bare string constant `MACRO: STOP`. That constant **replaces the queue**, destroying `DAQ: CLEAR / DAQ: CREATE / DAQ: START`. The recovery tail is gone.
7. `MACRO: STOP` matches the `Macro: Stop` frame (the main case structure has **Case Insensitive Match** enabled), so the machine queues `DAQ: STOP / DAQ: CLEAR` again.
8. The second `DAQ: STOP` succeeds (DAQmx hands back a latched error only once), status `stopped` (8); `DAQ: CLEAR` destroys the tasks, status `idle` (0). **This step is inference, not observation.** The reasoning: if the second Stop had errored too, the machine would cycle `MACRO: STOP -> Macro: Stop -> DAQ: STOP` forever, burning CPU and filling the log; the log instead shows one Stop Task error per burst and then silence. The falsifier is easy - if a fixed build still parks, check whether the Stop Task entries repeat.
9. The queue is now empty. The empty state dequeues from the private command queue, times out, and falls into its `idle` command frame. That frame only re-queues `DAQ: ACQUIRE` when DAQmx status is `started`; status is `idle`, so it queues nothing. **The DAQmx process parks with its tasks torn down and no pending states.**

So the DAQmx side actually tears itself down cleanly. What is lost is the intent to come back, and it is lost at exactly one wire: the `MACRO: STOP` constant in step 6.

### What the parent does, and why it does not save the day

`Instrument.DAQ`'s **state machine** never acts on the -200621 error. Its `Process.vi` event structure registers 37 events and **none of them carries an `Error` cluster**; `Macro: Post Error Handling` works off the Core Data `Last Error` field, i.e. errors on the parent's own loop error wire, not the child's. (The error does reach the upper SMOs' *logging* - that is what the triplet in the log is - but nothing in the parent's state machine reacts to it.)

What the parent does react to is `<DAQmx Public Events.Status>` (event 28), which stores the new DAQmx status in the Core Data cluster and queues `Data: Process State >> -DAQmx`.

`Data: Process State` does two things:

- Maps DAQmx status to the parent's `DAQ Status` and publishes it with `DAQ.getDAQState.vi` (a pure event publisher; it stores nothing).
- In the `error` case only, if the **old** `DAQ Status` was `started`, calls `DAQ.setstate.vi` with `reset` - the wire labelled "send signal to restart".

`DAQ.setstate.vi` is also a pure event publisher: it fires the private `setState` user event, handled by event 25 on a **later** iteration of the outer loop. By then the same `Data: Process State` frame has already written `DAQ Status = idle` into the Core Data cluster. Event 25's `reset` frame branches on `DAQ Status`: if it is `idle` it queues `Data: Clear Sweep Data`, otherwise it queues the real restart `Macro: Stop DAQmx / Generator: Stop / Generator: Start / Macro: Start DAQmx`.

**The restart therefore always degenerates into `Data: Clear Sweep Data`.** It is not "never fires"; it fires and does the wrong thing, and on a sweep it actively throws away accumulated sweep data. A diagram note next to the API documentation says `reset (if not idle)`, so the author's intent was exactly the branch that the ordering defeats.

### DAQmx status -> parent DAQ Status map (`Data: Process State`)

| DAQmx status | parent DAQ Status |
|---|---|
| idle *(0)* | idle (0) |
| calibrating / configuring / creating | idle (0) |
| created / starting | created (1) |
| **started** | **started (2)** |
| stopping | started (2) |
| stopped | stopped (3) |
| clearing | idle (0) |
| **error** | **idle (0)** |

`Status--enum` is `{idle 0, created 1, started 2, stopped 3, sweeping 4}`. Note that this map can never produce `sweeping`. That matters - see the next section.

## Key facts worth not rediscovering

- **`Add State(s) to Queue` (JKI) always concatenates.** Signature: `State(s) in Front` (term 0), `State(s) in` (term 5), `State(s) at Back` (term 7), `States Out` (term 6); output = `Front \n In \n Back`, trimmed, with empty parts skipped. It cannot replace anything. **Replacement happens when a frame bypasses it and wires a string constant straight to the state-queue tunnel**, which is what `DAQ: STOP`, `DAQ: CLEAR`, `DAQ: CREATE` and `DAQ: START` all do in their error frames.
- `Parse State Queue` (JKI) trims whitespace, strips `//` / `#` / `/*` comment lines, and splits `state >> arguments`. **It does not normalise case.**
- The main state case structure in `DAQmx/Process.vi` has **Case Insensitive Match** enabled, so `MACRO: STOP` really does reach the `Macro: Stop` frame. This was nearly recorded as a typo bug; it is not one. Confirmed three ways: the `A=a` glyph is drawn at exactly that structure's bottom-left corner (border rect 711.6,191.6 - 1218.4,443.4; glyph at 715.0,440.5, emitted between the border rect and the `data-lv-struct="3444"` selector bar); the only other `A=a` in the VI sits on struct 6862, the `Calibrate;Default` string case in `DAQ: CALIBRATE`, so both glyphs are on string selectors; and the LabVIEW Wiki documents `A=a` at bottom-left as the Case Insensitive Match indicator from LabVIEW 2015 on.
- **Per-task errors collapse to one before they are ever reported.** `DAQmx.Write.vi` writes each AO task in its own for-loop iteration, each starting from the same clean error state, auto-indexes the per-task errors into an array, and runs it through **Merge Errors** - which returns the first one. `Sync.Stop.vi` and `Sync.Destroy.vi` call `DAQmx Stop Task` / `DAQmx Control Task` + `DAQmx Clear Task` per task with an **unwired** `error in` and collect through a **pass-through** tunnel, so only the last iteration's error survives. Consequence: **the error log cannot tell you how many tasks or cards were involved.** One underflow and three simultaneous underflows produce the same single entry. This is the second, independent reason the "3 = three AO tasks" reading fails. It also means the teardown is already resilient: one task failing to stop never prevents the others from being stopped or cleared.
- **`SMO.lvclass:Handle Error.vi` (JKI SMO, `vi.lib/JKI/JKI SMO/SMO/Protected/`) does three things**: on a non-zero error it fires the SMO's **public `Error` user event** (this is what produces the log entry); it returns `Unhandled error` = `error in` **unchanged**, always; and it calls `SelfTerminate.vi` if `Stop on Unhandled Error (T)` is True. `DAQmx.Error Handler.vi` calls it with **False**, so no self-termination. This is the mechanism behind "logged before filtered".
- `DAQmx.Error Handler.vi`: `Handle Error.vi` publishes, then `Filter Error Codes__ogtk.vi` tests the code against a **literal array constant** holding -200000 ... -200298, -50103, -200621. Match -> `DAQmx Error? = True` and `error out = (default Error)`. No match -> the error passes through untouched. The for-loop that used to generate that range is parked in the **Disabled** frame of a Diagram Disable Structure and the expanded constant is in the **Enabled** frame: lvkit's renderer stacks all frames of a structure at the same canvas coordinates, and the constant column (x 393.6-477.4, y 476.6 down) sits exactly on top of the generator's constants and Build Array, which is the signature of two frames of one structure. lvkit's netlist shows the generator under `Disabled` and an empty `Enabled`; it drops the large array constant entirely.
- The two error-code filter lists have **drifted apart**:
  - `src/DAQmx/private/DAQmx.Error Handler.vi` (child): includes -50103 and -200621.
  - `src/Instrument.DAQ/support/DAQ/DAQ.ErrorHandler.vi` (parent): generated range only, ending -200299. No -50103, no -200621.
- `DAQmx.Create AO Tasks.vi` sets **RegenMode = Do Not Allow Regeneration**, which is why a late write errors instead of silently repeating samples. Keep it that way - regeneration would silently repeat a stale sweep point.
- `getWFMQueue.vi` already implements "reuse the previous waveform if a new one doesn't arrive in time": timeout = `#samples / Fs x 0.75 x 1000` ms, with a `timed out?` output. **No error is raised on that path.**
- `getWFMQueue.vi` *does* raise **error 123** ("A timeout occurred"), but only from the separate branch where the **min-buffer wait exceeded 5 s**, which only runs when `wait for min buffer? = True` - i.e. `DAQ: START`, not `DAQ: ACQUIRE`. **No 123 appears anywhere in three days of production log.**
- Min buffer is **1** in current develop (1 = configured samples per update). Production version (916ea27) may differ. Configured in `ObtainPublicQueues.vi` / `onStart.vi` override.
- Onboard FIFO size on these DSA cards is probably not settable; driver-side `Output.BufSize` (DAQmx Configure Output Buffer) may be - untested.
- The May 2026 fix (a8793aa3, in 3.4.1.75 -> 3.5.1.77) added the previous-waveform fallback and buffer 5 -> 10. It addressed queue starvation, not buffer underflow, which is why the issue survived it.

## Leftovers found in Instrument.DAQ (Patrick's hypothesis, confirmed but not where expected)

The hypothesis was that `Data: Process State`'s reaction to DAQmx status is left over from before DAQmx had its own `Process.vi`. That is right in spirit, and the audit turned up the following. High confidence from static reading; each is worth one minute of confirmation in LabVIEW before deleting.

- **The Core Data field `DAQ Status` has exactly one writer**: the bundle in `Data: Process State` (node uid 18420), fed by the DAQmx-status map above. Confirmed on two independent surfaces: lvkit's netlist shows one `in DAQ Status` and four `out DAQ Status`; the rendered diagram's node interfaces show exactly five nodes mentioning the field, one Bundle By Name (18420) and four Unbundle By Name (25863 Timeout, 13670 setState handler, 25415 `Data: Process State`, 18323 `Data: Process Sampling`). The cluster's shift register initialises from a default constant, and `Initialize Core Data` sets only `Current VI Reference` and `Close Panel on Exit?`.
- Therefore `DAQ Status` **can never hold `sweeping` (4)**. The value reaches the outside world only through `DAQ.getDAQState.vi` in event 35 (Generator sweep status), which publishes it without storing it.
- Consequently the Timeout frame's `"sweeping"` branch, which is the only place that queues `Macro: Sweep`, is **unreachable**, and with it `Macro: Sweep`, `Sweep: Wait` and `Sweep: Status`. Those three frames already look half-dismantled (they compute values and discard them) and `Macro: Sweep`'s payload has `//Data: Save Sweep Data` commented out. Sweeps are in fact driven by the Generator SMO plus `Waveform.Attributes:Get Waveform Sweep Status.vi` in `Macro: DSP`; the parent's sweep tick was superseded and never removed.
- **Correction to an assumption in the earlier analysis**: during a sweep the parent's `DAQ Status` is `started`, not `sweeping`. The `DAQ Status == "started"` gate on the restart therefore *does* pass mid-sweep. The restart fails for the ordering reason above, not the gating reason.
- `Data: Process Sampling` contains `And(DAQ Status == started, False)` feeding a Select whose true value is `Macro: Stop DAQmx\nDAQ: START`. Hard-wired off. Dead.
- `Macro: Start DAQmx` / `Macro: Stop DAQmx` are already a correct, polling handshake against DAQmx status (they re-queue `idle\nMacro: Start DAQmx` while DAQmx is in a transitional status). These are *not* leftovers and should stay. They are also the reason the parent does not need any new recovery logic: pressing Acquire already works.

## Corrections to earlier analysis (do not re-tread)

- Instrument.DAQ's **state machine** does not act on the -200621 error; it reacts only to the status event. But the earlier wording "Instrument.DAQ does not see the error (the child cleared it)" was wrong about the plumbing: `Handle Error.vi` publishes the error *before* the filter clears it, which is why all three SMO levels log it. The conclusion about `Macro: Post Error Handling` still stands (it only handles errors on the parent's own error wire), but for that reason, not because the error is invisible.
- **The triplets in the error log are the SMO logging chain, not three tasks or three cards.** Verified across 4 codes, 5 app runs and 11 triplets in the local logs, always in the order DAQmx -> Instrument-DAQ -> Multichannel-Lockin, always the same Task Name. All counts in the production log must be divided by three.
- -200290 was an early guess for the underflow code. The real one is **-200621**.
- The burst timing is **not** correlated with machine activity or a periodic system event; it is manual-restart cadence.
- `Add State(s) to Queue` does not prepend-or-replace. It only concatenates. The loss of pending states comes from frames that **bypass** it with a string constant.
- `MACRO: STOP` vs `Macro: Stop` is **not** a case-sensitivity bug. Case Insensitive Match is on for that case structure.
- The parent's "send signal to restart" is **not** dead because of its `started` gate. It fires, and then the `reset` handler sees the already-overwritten `idle` and does `Data: Clear Sweep Data` instead.
- Mid-sweep the parent's `DAQ Status` is `started`, not `sweeping`.

## Strategy decision (2026-09-20)

A and B were never alternatives, and the tension dissolves once the mechanism is pinned down.

**All of the recovery belongs in `DAQmx.lvclass:Process.vi` (Strategy A).** The failure is a single destroyed state queue inside that VI. Nothing in `Instrument.DAQ` needs to participate, and nothing new should be added there.

**Strategy B reduces to deletions.** The parent's only attempt to drive recovery has never worked, and on a sweep it destroys data. Delete it rather than repair it. That satisfies "prune the leftovers" and "do not involve Instrument.DAQ in recovery" at the same time: the parent becomes a pure observer of DAQmx status and a publisher of API state.

Specifically **reject B2** (the intent flag). It was motivated by a gate that turns out not to be the problem, and it would put the parent back into the recovery business.

### Sequencing

1. **A2** alone, then run overnight. If -200621 is followed by continued acquisition, that is the fix.
2. **B1'** (delete the parent's reset write) either with A2 or immediately after: without it, every recovery fires a `Data: Clear Sweep Data` at the parent.
3. **A5** (retry budget + recovery marker) so that "gave up" is a defined, logged state and so the verification criterion below can be checked.
4. **A1** only if step 1-3 leave a visible glitch for API consumers (Transport sees `DAQ Status` go idle and back during every recovery).

## Candidate changes

### Strategy A - self-contained in `DAQmx.lvclass:Process.vi`

| # | Change | Status |
|---|---|---|
| A1 | Suppress public status publication (or hold `started`) for the duration of a recovery attempt, so the parent and the API never see `error`/`idle` for a fault that is about to be cleared; publish `error` only when retries are exhausted | proposed (deferred to step 4) |
| A2 | Teardown states must not replace the state queue. See the change spec below | **accepted** |
| A3 | Prefer Clear over Stop for an already-errored task | **rejected** - the second Stop succeeds (DAQmx surfaces a latched error once), and Clear would hit the same latched error. A2 makes this unnecessary |
| A4 | Append `DAQ: ACQUIRE` explicitly to `Macro: Recover` | **done** - already in the uncommitted `Macro: Recover` constant |
| A5 | Retry counter with a time window; log a recovery marker on success, publish `error` + reason on exhaustion | accepted (step 3) |

#### A2 change spec

Principle: **teardown errors are swallowed and the queue continues; bring-up errors abort.**

All edits are in `src/DAQmx/Process.vi`, inside the main state case structure (the big string-selector case in the while loop, the one with `A=a` at its bottom-left).

##### Orientation: how every `DAQ: *` frame is laid out

Each of the five `DAQ: CREATE / START / ACQUIRE / STOP / CLEAR` frames contains an inner **error case** on the worker VI's `error out`, with frames `"No Error"` and `"Error", Default`. Every one of these inner cases has the same tunnel layout:

| Edge | Position | Wire colour | Carries |
|---|---|---|---|
| left (in) | topmost | **string (pink)** | `Parse State Queue -> Remaining States` (term 4) |
| left (in) | 2nd | string (pink) | `Parse State Queue -> Current State` (term 6), feeds `DAQmx.Error Handler.vi`'s `[error source]` |
| left (in) | 3rd | dark red | the `DAQmx` class wire |
| right (out) | **topmost** | **string (pink)** | **the state queue** - this is the one to fix |
| right (out) | 2nd | dark red | `DAQmx` class out |
| right (out) | 3rd | olive | error out |
| right (out) | bottom | blue | `DAQmx.Status--enum` for the following `setStatus.vi` |

The state-queue tunnel is the **only string output tunnel**, and the Remaining States input tunnel sits at **the same height** on the opposite edge, so in the `"No Error"` frame the two are joined by a straight horizontal wire. That is the shape you are restoring.

##### Change 1 (required) - `DAQ: STOP`, `"Error", Default` frame

1. Select the `DAQ: STOP` frame, then the inner case on `Sync.Stop.vi`'s error, then its `"Error", Default` frame.
2. Delete the string constant `MACRO: STOP`. It sits directly on the path between the two string tunnels.
3. Wire the topmost left string tunnel (Remaining States) straight across to the topmost right string tunnel. Compare with the `"No Error"` frame: that wire should now look identical in both frames.
4. Leave `DAQmx.Error Handler.vi` where it is. It publishes and clears; that behaviour is wanted.

##### Change 2 (required) - `DAQ: CLEAR`, `"Error", Default` frame

Identical treatment. Delete the string constant `Macro: Stop` and wire Remaining States across to the state-queue tunnel.

##### Change 3 (recommended) - stop announcing `error` for a swallowed fault

In the same two `"Error"` frames, change the `DAQmx.Status--enum` constant feeding the status tunnel so it matches the sibling `"No Error"` frame:

| Frame | today | change to |
|---|---|---|
| `DAQ: STOP` -> `"Error"` | `error` (10) | **`stopped` (8)** - same as `"No Error"` |
| `DAQ: CLEAR` -> `"Error"` | `error` (10) | **`idle` (0)** - same as `"No Error"` |

Rationale: if the error is being swallowed and the sequence continues, publishing `error` is a lie that the parent acts on. `Data: Process State` maps DAQmx `error` to parent `idle` and fires the dead `setState(reset)`, which on a sweep costs you a `Data: Clear Sweep Data`. Making this change means A2 is complete on its own and does not depend on B1' landing first. Nothing is lost diagnostically: `Handle Error.vi` has already published the error to the log by this point.

If you would rather bisect, do Changes 1 and 2 alone first - they are two wires and two deletions, and they are the actual fix.

##### Change 4 (optional, defensive) - `Macro: Recover`

Its five-state constant is wired straight to the state-queue tunnel, so it replaces the queue. Harmless today, because the only thing that queues `Macro: Recover` has already emptied the queue. Route it through an `Add State(s) to Queue` (constant into `State(s) in Front`, Remaining States into `State(s) in`) so it stays correct if A5 ever queues it alongside other states.

##### Do not change

- **`DAQ: CREATE`** and **`DAQ: START`** error frames. They replace the queue with `DAQ: CLEAR`, which is correct: these are bring-up failures and aborting is the right response. A5 will revisit them so they abort into a bounded retry instead of a bare `DAQ: CLEAR`.
- **`DAQ: ACQUIRE`** error frame. It replaces the queue, but the queue is empty whenever `DAQ: ACQUIRE` runs, so there is nothing to lose. Leave your `Macro: Stop` / `Macro: Recover` Select as it is.
- **`Error Handler`** and **`Macro: Initialize`**. Both replace the queue by design.

##### Why swallowing the stop error is safe

`Sync.Stop.vi` loops over the task arrays and calls `DAQmx Stop Task.vi` with an **unwired** `error in` on each iteration, collecting the result through a **pass-through** tunnel. So every task is stopped independently regardless of what any other task did, and the VI reports only the last iteration's error. `Sync.Destroy.vi` is the same shape: `DAQmx Control Task` (state 5) then `DAQmx Clear Task` per task, each starting clean. Continuing to `DAQ: CLEAR` after a failed stop therefore cannot leave a task un-torn-down, and `DAQmx Clear Task` implicitly stops anything still running.

##### Expected behaviour after the change

State trace for an underflow during acquisition, with Changes 1-3 applied:

```
DAQ: ACQUIRE   -200621, logged, cleared    status error(10)   queue := Macro: Recover
Macro: Recover                             status unchanged   queue := DAQ: STOP / CLEAR / CREATE / START / ACQUIRE
DAQ: STOP      -200621 on stop, swallowed  status stopped(8)  queue := CLEAR / CREATE / START / ACQUIRE
DAQ: CLEAR     ok                          status idle(0)     queue := CREATE / START / ACQUIRE
DAQ: CREATE    ok                          status created(4)  queue := START / ACQUIRE
DAQ: START     ok                          status started(6)  queue := ACQUIRE
DAQ: ACQUIRE   running again
```

Parent `DAQ Status` follows idle -> idle -> created -> started and ends at `started`. The data pipeline was never gated, so waveforms resume.

##### How to check you edited the right thing

Run `lvkit diff` against `HEAD` (set `PYTHONIOENCODING=utf-8`). Changes 1-3 should show up as, in `DAQ: STOP` and `DAQ: CLEAR`, a removed string constant, a changed enum constant, and no other structural change. Anything else in the diff is an accident.

### Strategy B - prune the parent's leftovers in `Instrument.DAQ:Process.vi`

| # | Change | Status |
|---|---|---|
| B1 | Stop mapping DAQmx `error` -> parent `idle`; give it its own status value | **rejected** - adding a `Status--enum` value is an API/wire change for Transport, and A1 removes the need |
| B1' | **Delete** the `error` branch's `DAQ.setstate.vi(reset)` write and its `DAQ Status == started` gate in `Data: Process State`, leaving the status map alone | **accepted** |
| B2 | Replace the `DAQ Status == "started"` restart gate with an explicit intent flag | **rejected** - see "Strategy decision" |
| B3 | Audit `Data: Process State` and neighbours for other leftovers | **accepted** - findings recorded above; the removals themselves are separate, low-risk cleanups, not part of the #160 fix |

### Lower priority - reduce how often it fires

| # | Change | Status |
|---|---|---|
| C1 | Raise min buffer above 1 (`ObtainPublicQueues.vi` / `onStart.vi`) | proposed |
| C2 | Revisit `AO.DataXferReqCond` (set in `DAQmx.Create Sample Clock.vi`) - keep the FIFO topped up rather than refilling when empty | proposed |
| C3 | Test whether driver-side `Output.BufSize` is settable on these cards | proposed |
| C4 | Fewer, larger writes (more samples per update) | proposed |
| C5 | Decide sweep policy on recovery: abort with a logged marker, or resume from the current setpoint. Currently the sweep dies silently | proposed |

## Uncommitted work in progress

`git status` on develop shows four modified DAQmx VIs. `lvkit diff` against HEAD:

- `src/DAQmx/Process.vi`
  - Added a `Macro: Recover` frame whose constant is `DAQ: STOP\nDAQ: CLEAR\nDAQ: CREATE\nDAQ: START\nDAQ: ACQUIRE`.
  - `DAQ: ACQUIRE`'s error frame now selects between `Macro: Stop` and `Macro: Recover` on `DAQmx.Error Handler.vi`'s `DAQmx Error?` output. Since -200621 is in the filter list, `DAQmx Error? = True` and `Macro: Recover` is taken. Good.
  - **Reentrancy changed `shared_clone` -> `non_reentrant`.** Probably unintended; check before committing. This is an SMO process VI.
  - This change is necessary but **not sufficient**: `Macro: Recover` still runs into the `MACRO: STOP` constant at step 6 and loses its tail. A2 is what makes it work.
- `src/DAQmx/private/DAQmx.Error Handler.vi`, `ObtainPublicQueues.vi`, `onCreated.vi`: byte-different but `lvkit diff` reports no logical change (cosmetic / save artefacts).

## Reading the error log

`%LOCALAPPDATA%\LevyLab\Error Logs\Multichannel-Lockin\<YYYY-MM-DD HHMMSS> Errors.txt`, one file per app launch (they come in pairs a second apart, one of which is usually empty), TSV with `Date, Time, Type, Name, Code, Message, Possible reason(s), Call Chain, Calling Class`. Records span multiple lines, so parse on the leading date, not on newlines. It is per-user, so it must be the account running the lock-in.

**Every error appears three times.** One entry per SMO level, always in the order `DAQmx.lvclass:DAQmx`, `Instrument.DAQ.lvclass:Instrument-DAQ`, `Instrument.Lockin.lvclass:Multichannel-Lockin` (the `Calling Class` column), tens of ms apart, with identical Task Name, Code and Call Chain. Divide counts by three before drawing conclusions, and do not read a triplet as three channels, tasks or cards.

The entry itself is written by whatever subscribes to an SMO's public `Error` event, which `SMO.lvclass:Handle Error.vi` fires. **How the error travels from the DAQmx SMO up to the other two was not traced** - `Instrument.DAQ`'s `Process.vi` registers no `Error` event, so it is not happening through its state machine. Only the observed regularity is being relied on here, and it is exceptionless across the local logs.

## How to verify a fix

A successful fix looks like: -200621 triplets still appear (the stall is environmental, and the error is published before it is filtered), but each is followed by a recovery marker and acquisition continues - no manual restart, and the run survives overnight unattended.

The clearest single signature: today a burst is one `DAQmx.Write.vi` -200621 (logged three times), then ~300 ms later one `DAQmx Stop Task.vi` -200621 (logged three times), then silence until someone clicks Acquire. After A2 the same two groups should appear and the run should continue, with the gap to the next burst becoming an environmental interval rather than a human reaction time.

Note that the dev machine reproduces the *same code path* with -200279 at `DAQmx.Read.vi` (AI overflow, also inside the filter list), so a fix can be exercised without waiting for an AO underflow.

## Open questions

- Re-read the production log with the divide-by-three rule and recount the bursts (126 entries is 42 events, which does not divide into 18 bursts of one Write + one Stop). Check whether a burst ever contains a second Stop Task error, which is the falsifier for mechanism step 8.
- Confirm in LabVIEW that the array wired into `Filter Error Codes__ogtk.vi` really is the expanded constant and not the disabled generator's tunnel. This now **matters**: the uncommitted `DAQ: ACQUIRE` change selects `Macro: Recover` only when `DAQmx Error? = True`, so if the filter list were empty at run time that change would silently do nothing. Static evidence says the constant is in the Enabled frame; it is a ten-second glance to be sure.
- Which frame of the main state case in `DAQmx/Process.vi` carries the `Default` label? lvkit reports none, but lvkit **hides a `Default` that is merged onto a labelled frame** - proved by the parent's `Open;Close` string case, which must have a default and shows none. So case_3444's default is merged onto one of its 18 frames and lvkit cannot say which. It does not affect the diagnosis (`MACRO: STOP` matches `Macro: Stop`), but it should be known before editing that structure.
- Was the reentrancy change on `DAQmx/Process.vi` intentional?
- Is -200621 hitting one card or all of them? **The log cannot answer this** (errors are merged per call). To find out you would have to instrument `DAQmx.Write.vi` to report the per-task error array rather than merging it, or log the Task Name per failing write. Worth doing before spending effort on C1-C4, since the mitigation differs for one bad card versus a bus-wide stall.
- What sends the 402844 JSON payload? Separate issue.

## Verification pass, 2026-09-20

Everything above was re-checked by a second, independent route. What changed:

| Claim | Re-checked how | Outcome |
|---|---|---|
| `DAQ: STOP`'s error frame replaces the queue | Node census: the VI contains exactly **16** `Add State(s) to Queue` nodes in both lvkit's netlist and the rendered diagram, all in the dispatch frame or in `Macro: Start` / `Macro: Stop` / `Macro: Exit` / `UI: Initialize`. None in any `DAQ: *` frame. The `MACRO: STOP` string constant (rect 987.6,258.6 - 1072.4,273.4) wires to the inner case's string output tunnel at 1109,263.1 | **holds** |
| Case Insensitive Match on the state case | Glyph geometry + second glyph on a known string case + LabVIEW Wiki | **holds** |
| -200621 in the live filter list | Frame-stacking geometry in the render | **holds**, but see open questions |
| One writer of `DAQ Status`; `sweeping` unreachable | Render node-interface census, plus shift-register init and `Initialize Core Data` | **holds** |
| Event 25 reads `DAQ Status` after it was overwritten | `DAQ.setstate.vi` is a pure `Generate User Event`; there is exactly **one** event structure in the parent and it is inside the `""` state frame, so the handler cannot run in the same loop iteration as the write | **holds** |
| "3 x Write, 3 x Stop Task" = three AO tasks stalling together | Local logs: 11 triplets, 4 codes, 5 runs, always one Task Name and three `Calling Class` values | **refuted** - see "Confirmed root cause" |
| "Instrument.DAQ does not see the error" | `SMO.lvclass:Handle Error.vi` publishes before the filter runs; the parent registers no `Error` event | **corrected** - it is logged at all three levels; the parent's state machine still does not act on it |
| Production log burst counts | Not re-checkable: that file is on the lock-in account, not the dev machine | **unverified** |

Third pass, while writing the A2 spec:

| Claim | Re-checked how | Outcome |
|---|---|---|
| Only the five `DAQ: *` frames replace the state queue | Exhaustive audit of what drives `case_3444.out2` in **all 18** frames of the main state case, from the JSON IR | **holds**, and the list is now complete: the other replacing frames are `Error Handler`, `Macro: Initialize` and `Macro: Recover`, all of which run with an empty queue or replace by design |
| The state-queue tunnel is identifiable by eye | Tunnel geometry and wire colour extracted for all five inner cases; the layout is identical in every one | **holds** - it is the only string output tunnel, topmost on the right edge |
| Status enum values 0/4/6/8 etc. | Cross-checked against the `setStatus` constants written *before* each worker VI (`DAQ: STOP` writes 7 `stopping`, `DAQ: CLEAR` writes 9 `clearing`, `DAQ: CREATE` 3, `DAQ: START` 5) and against the parent's `Data: Process State` frame order | **holds**, fully self-consistent |
| Continuing after a failed stop is safe | Read `Sync.Stop.vi` and `Sync.Destroy.vi`: per-task loops with unwired `error in` | **holds**, and stronger than assumed - teardown was already per-task resilient |
| The log tells you how many tasks stalled | Read the error aggregation in `DAQmx.Write.vi` (Merge Errors over an auto-indexed array) and `Sync.Stop.vi` (pass-through tunnel) | **refuted** - per-task multiplicity is discarded before the error is ever published |

## Method notes (tooling)

- `lvkit index` still hangs on this repo, so MCP `index`/`query` are unavailable. Per-VI `lvkit describe --format lvnet` works (about 22 s for `DAQmx/Process.vi`, about 60 s for `Instrument.DAQ/Process.vi`).
- `lvkit describe --format json` exposes `is_default` per case frame; the lvnet surface does not always. **Neither surface shows a `Default` that is merged onto an already-labelled frame** - it is silently dropped, so "lvkit reports no default" never means "there is no default".
- `lvkit render` writes a self-contained HTML/SVG. It is the fastest way to check things lvkit's netlist drops or mangles. Useful greps: `data-lv-frames` (true case-selector label lists), the `A=a` glyph (Case Insensitive Match, drawn at the owning structure's bottom-left and emitted between its border rect and its selector bar), `<title>` blocks on `<g class="lv-node">` (each node's full terminal interface - good for "who writes this cluster field"), large array constants, and the diagram's free-label comments. `data-lv-default` is **not** the LabVIEW default frame, only the frame the viewer opens on.
- **The renderer stacks every frame of a structure at the same coordinates.** Two sets of nodes occupying one canvas rectangle means two frames of one structure, which is how the Enabled/Disabled split in `DAQmx.Error Handler.vi` was settled.
- Error-log records span multiple lines (the Message and Possible reason(s) fields contain newlines), so split records on the leading `2026-..-..\t` date, not on `\n`. The `Calling Class` is the last tab-separated field of the record.
- `lvkit diff` against `git show HEAD:<path>` saved to a temp file is a clean way to see uncommitted VI changes. Set `PYTHONIOENCODING=utf-8`; the CLI crashes on box-drawing characters under cp1252.

## Adjacent work (done, unrelated to the pause)

- `DAQmx.Clip AO Waveforms.vi` raised -200488 then -200486 on a DAQmx Channel property node. Cause: reading task channel-configuration properties (`AO.Min`/`AO.Max`) with a bare channel reference instead of the task + **Active Channels**. Fixed 2026-09-20 by wiring the task and selecting via Active Channels. A 1 s debug Wait is still in that VI and must be removed before commit.
- A sweep of all 30 property-node VIs in the DAQmx class found only 6 with DAQmx **Channel** nodes; the other 5 are correct (task-referenced). `DAQmx.44xx.Coerce Fs.vi` reads `ChanType` off a generic refnum and appears to have **no callers** - possible dead code.
- Planned but not done: delete the case structure in `getWFMQueue.vi` that merges error 123, so a min-buffer timeout falls through to the dequeue attempt. Caveat: at `DAQ: START` there is no previous waveform, so guard the "dequeue empty **and** no previous waveform" case.
