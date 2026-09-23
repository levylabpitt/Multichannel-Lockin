# Issue #160, round 2 - underflow rate and sweep continuity (change spec)

Instructions first; the evidence is at the bottom. Follows [issue-160-changespec.md](issue-160-changespec.md) (recovery, released in 3.6.0.80).

## Changes

| # | What | Why | Priority |
|---|---|---|---|
| 1 | Keep **two** AO blocks ahead instead of one | removes the structural cause of the underflow | **done** 2026-09-22: Generator gate 0..1, min buffer 2, two pre-writes, feedback delay 2 - all four verified |
| 2 | After a recovery, write the block that failed before anything new | stops a sweep from skipping a block | **done** 2026-09-22, see "AS BUILT" |
| 3 | Stop reading DAQmx properties on every write | trims per-write latency | optional, only if 1 is not enough |
| 4 | Pair each pre-write with its own dequeue | the first block after every start and recovery was paired with the wrong REF | **done** 2026-09-22, see "Change 4" |
| 5 | Size the AO buffer explicitly to two blocks (#167) | without it the second pre-write fails with -200547 on every start | **open** 2026-09-23, see "Change 5" |

### Change 1 - two-block AO lead (done, verified 2026-09-22)

Use N = 2 throughout. Steps 1 and 2 must land together: min buffer 2 with the old 0..0 Generator gate would hang `DAQ: START` for 5 s and fail with error 123.

1. **Generator** `src/Generator/Process.vi`, event `[0] Timeout`, frame `"started"`: the `In Range and Coerce` that gates `Generator: Generate` has limits 0..0. Change the **upper limit to 1**, so the Generator generates while the AO queue holds 0 or 1 blocks.
2. **Min buffer** `src/DAQmx/Methods (overrides)/onCreated.vi`: the constant wired to `ObtainPublicQueues.vi` terminal `Min Queue Buffer` is 1. Change it to **2**. `DAQ: START` then waits (up to 5 s, already there) until two blocks are queued.
3. **Pre-write two blocks** in `DAQ: START`. After the existing `getWFMQueue.vi` (`wait for min buffer?` = T), call `getWFMQueue.vi` again with `wait for min buffer?` = F to take the second block. Then write both before any task starts: two `DAQmx.Write.vi` calls, first block then second, ahead of the `DAQmx Start Task` loop. Doing it inside `DAQmx.Start AO.vi` (a second `AO []` input and a second `DAQmx.Write.vi` before its Start Task loop) keeps `DAQ: START` tidy. Two separate writes, not one concatenated write, matter for step 4.
4. **Pairing delay 1 -> 2.** The AI block read in an iteration was generated alongside the AO block written N iterations earlier.
   - `src/DAQmx/private/DAQmx.Write.vi`: the Feedback Node that drives `AOwfm out (previous)` -> right-click > Properties > **Delay = 2**. That VI is non-reentrant and shared by `DAQmx.Start AO.vi` and `Sync.Acquire.vi`, so the two pre-writes fill the delay line and the first `DAQ: ACQUIRE` pairs AI block 1 with AO block 1.
   - `src/DAQmx/Process.vi`, `DAQ: ACQUIRE`: the two Feedback Nodes on `getWFMQueue.vi`'s REF_X / REF_Y outputs -> **Delay = 2**.

Cost: an AO change reaches the output one block later than today (e.g. +100 ms at a 10 Hz refresh rate).

### Change 2 - resume with the failed block - AS BUILT (2026-09-22)

Implemented differently from, and better than, the draft below: the owed block lives on the class wire and stays owed until its write succeeds, so no "which call failed" test is needed.

- `DAQmx.lvclass` private data gained `Recovery.Pending AO / REF_X / REF_Y` and `Waveforms.AO / AI / REF_X / REF_Y`.
- `getWFMQueue.vi` writes the dequeued block into the three `Recovery.Pending` fields (on the fallback path too).
- `Sync.Acquire.vi` writes `Recovery.Pending AO`, clears all three Pending fields on write success, and stores `Waveforms.AI` on read success.
- `DAQmx.Write.vi` pushes the clipped AO and `Recovery.Pending REF_X/REF_Y` through three feedback nodes at **delay 2** and writes `Waveforms.AO/REF_X/REF_Y`. The nodes sit in the No Error frame, so a failed write does not advance the delay line and pairing survives a recovery.
- `setWaveforms.vi` publishes from the four `Waveforms` fields.
- `getWFMQueue.Initial.vi` uses `Recovery.Pending AO` as the first pre-written block when it is non-empty, otherwise dequeues, then dequeues the second. `DAQ: START` feeds both to `Sync.Start.vi` -> `DAQmx.Start AO.vi`.

Why this covers both failure modes: a failed write leaves Pending set, so the block is replayed. A failed read with a good write clears Pending, and the written block plays out during the recovery (1.2 s median against a block time of order 100 ms), so nothing is owed.

**Residual issues.** Status re-read from the VIs 2026-09-22 22:00:

1. ~~`Macro: Stop` leaves `Pending REF_X` / `Pending REF_Y` stale.~~ **Done** - its Bundle By Name now writes the flag plus all three `[MeasureData]` fields as empty.
2. **Open - won't fix.** If anything in `DAQ: START` fails after block 1's write (block 2's write, or `DAQmx Start Task`), block 1 is lost: it sits in an AO buffer that `DAQ: CLEAR` discards, and `Recovery.Pending AO` has already moved on to block 2. A real fix means changing the recovery contract from one pending block to a queue of pending blocks - `Recovery.Pending AO` becomes an array, and `getWFMQueue.vi`, `Sync.Acquire.vi`, `DAQmx.Prime AO.vi` and `Macro: Stop` all change with it. That is a lot of surface for a one-block loss in a path that did not occur once in 27 recoveries. Revisit only if a sweep shows a step that survives the fixes above.
3. ~~The two pre-writes read the same `Pending REF_X/REF_Y`.~~ **Done** 2026-09-22 - see "Change 4".
4. ~~`setWaveforms.vi` computes `Empty Array?` on REF_X / REF_Y and leaves them unwired.~~ **Done** - the two nodes were deleted. The publish gate is deliberately AO **and** AI non-empty.
5. ~~Dead terminals on the connector panes.~~ **Done** - `Sync.Acquire.vi`, `setWaveforms.vi` and `DAQmx.Write.vi` all have clean panes.

### Change 4 - pair each pre-write with its own dequeue (done 2026-09-22)

`DAQmx.Write.vi` takes its REF by unbundling `Recovery.Pending REF_X/REF_Y` off the class wire it is handed. That is correct in the acquire path, where `DAQ: ACQUIRE` calls `getWFMQueue.vi` immediately before `Sync.Acquire.vi`. The start path broke it: `getWFMQueue.Initial.vi` did **both** dequeues, so the class it returned carried block 2's REF and both pre-writes saw it. The delay line got REF(2) twice instead of REF(1), REF(2), so the **first AI block published after every start and every recovery** was paired with the wrong reference.

That is only invisible when consecutive blocks are REF-identical. During a frequency sweep they are not, so after a mid-sweep recovery the first published point demodulated against the wrong reference - the same symptom as the ramp step this spec is trying to remove.

Fixed by moving each write next to its own dequeue, which also removed six terminals:

- `getWFMQueue.Initial.vi` -> renamed **`DAQmx.Prime AO.vi`**. It keeps the `Empty Array?(Recovery.Pending AO)` case (replay the owed block, else dequeue with `wait for min buffer?` = T), then calls `DAQmx.Write.vi` on that class, then `getWFMQueue.vi` with `wait for min buffer?` = F, then unbundles `Recovery.Pending AO` and calls `DAQmx.Write.vi` again. Outputs `AO 1` and `AO 2` are gone; the pane is class + error only.
- `DAQmx.Start AO.vi` lost both `DAQmx.Write.vi` calls, the `Empty Array?` gate and the inputs `AO in 1` / `AO in 2`. It is now just the Start Task loop, reading the AO task array from `DAQmx in`.
- `Sync.Start.vi` lost `AO 1` / `AO 2`.
- `DAQ: START` calls `DAQmx.Prime AO.vi` then `Sync.Start.vi` on the class and error chain; the writes still all happen before any task starts.

`getWFMQueue.vi`'s whole body sits inside `case error in (no error)`, so a failed first write skips the second dequeue and leaves `Pending AO` holding block 1.

The invariant is now structural: **every `DAQmx.Write.vi` call is immediately preceded, on the same class wire, by the dequeue that set `Recovery.Pending`.**

**Watch the polarity of the two `Empty Array?` gates - they are opposite.** The first asks "is anything owed?", so its **True** frame (nothing owed) is the one that dequeues. The second asks "did the second dequeue produce a block?", so its **False** frame (a block is there) is the one that writes. Copying the shape of the first into the second inverts it, which is what happened on the first pass; caught by reading the IR and fixed 2026-09-22 22:39. An inverted second gate never writes block 2 in normal operation, silently undoing Change 1.

### Change 5 - size the AO output buffer before the first write (#167, open)

**Symptom (3.6.1.81, hardware).** `DAQmx.Write.vi` returns -200547, "a previous DAQmx Write automatically configured the output buffer size ... no more data can be written prior to starting the task". It fires on the second pre-write in `DAQmx.Prime AO.vi`, so `DAQ: START` fails on every start and every recovery attempt. 3.6.1.81 cannot acquire.

**Cause.** Change 1 step 3 relied on writing two blocks before `DAQmx Start Task`, but nothing configures the AO buffer, so DAQmx does it implicitly: the first Multiple Samples write creates a buffer exactly the size of that write (one block), and with auto start = F nothing more can be written until the task starts. The evidence section below already says "DAQmx sizes the output buffer from the data written before start"; the spec drew the wrong conclusion from it (that writing two blocks would give a two-block buffer).

**Why keep two writes rather than one concatenated write.** A single two-block write would size the buffer correctly by itself, but it pushes one waveform through `DAQmx.Write.vi`'s delay line, so the REF pairing from Changes 2 and 4 would be off by one block. Writing block 1, starting, then writing block 2 brings back the race Change 1 removed. Configuring the buffer is what NI's error text prescribes and leaves Changes 1-4 as they are.

**Where.** `src/DAQmx/private/DAQmx.Create Sample Clock.vi`, frame `"No Error"`. It is the only place timing is set (called only from `Sync.Create.vi`, i.e. `DAQ: CREATE`, which the recovery path re-runs), and it runs before any write. The buffer size therefore follows every change of block size.

1. After the `DAQmx Timing (Sample Clock).vi` for-loop, add a new for-loop that auto-indexes the **AO task array**: the second array into the `Build Array` feeding the timing loop, the same array the existing `Output.BufSize` read loop indexes. (lvkit labels it `#s`; class field labels are scrambled, so identify it by that loop, not the name.)
2. Inside, a `DAQmx Buffer` property node, **write** `Output.BufSize` (U32) = **2 x samples per channel**. Samples per channel is the I32 class field already wired to the timing VI's `samples per channel` input (the same field `DAQmx.Read.vi` uses as `number of samples per channel`, i.e. the block length; lvkit prints it as `Fs.Output`). `DAQmx Configure Output Buffer.vi` is equivalent if you prefer the VI.
3. Error chain: the timing loop's error output -> shift register on the new loop -> `error out` of the frame (currently `case_139::out0` comes straight from the timing loop).
4. Optional: wire the task out of the new loop into the `Output.BufSize` read loop so the `Output.Buffer` indicator is read after the write and shows the configured size.

The factor 2 must be at least the number of blocks pre-written, i.e. the `Min Queue Buffer` constant in `Methods (overrides)/onCreated.vi`. A larger factor is harmless with regeneration off (the lead is still what is written, the writes just never wait for space), but 2 is the minimum that works and keeps the two numbers visibly the same.

**Check on hardware.** After a start, `Output.Buffer` on `DAQmx.Create Sample Clock.vi` should read 2 x samples per block per AO task, and `DAQ: START` should complete with no -200547.

**Tests.** `Test Sync.vi`, `Test Sync with Queues.vi` and `Test Sync (DAQmx).vi` all go through `Sync.Create.vi`, so they pick up the fix; the two that pre-write twice currently fail the same way.

### Verified as built, 2026-09-22 22:40

Read back from the VIs with `lvkit describe --format lvnet` and `read_vi`:

- `DAQmx.Prime AO.vi`, `Sync.Start.vi` and `DAQmx.Start AO.vi` all have the same pane: `DAQmx in` @11, `error in` @8 -> `DAQmx out` @3, `error out` @0. The AO blocks no longer cross a connector pane at all; they go straight from each dequeue into the `DAQmx.Write.vi` next to it.
- `DAQmx.Prime AO.vi` body: `Empty Array?(Pending AO)` [False -> replay the owed block on the incoming class; True -> `getWFMQueue.vi(wait=T)`] -> `DAQmx.Write.vi` -> `getWFMQueue.vi(wait=F)` -> `Empty Array?(Pending AO)` [False -> `DAQmx.Write.vi`; True -> pass through].
- `DAQ: START` is `setStatus.vi` -> `DAQmx.Prime AO.vi` -> `Sync.Start.vi`, on the class and error chain.
- `Sync.Start.vi` is `DAQmx.Start AO.vi` -> `DAQmx.Start AI.vi`; `DAQmx.Start AO.vi` is the Start Task loop alone.
- `getWFMQueue.vi` and `DAQmx.Write.vi` both have their whole body inside `case error in (no error)`, so a failed first write leaves `Recovery.Pending AO` holding block 1 and the second dequeue and write become no-ops.
- `src/DAQmx/DAQmx.lvclass` lists `DAQmx.Prime AO.vi` and no longer lists `getWFMQueue.Initial.vi`.

`Write.TotalSampPerChanGenerated` (option (b) below) is now only needed if a recovery ever completes faster than the AO buffer drains, which would leave written-but-unplayed blocks discarded by `DAQ: CLEAR`. Not the case at the current timings.

<details>
<summary>Original draft of Change 2 (superseded)</summary>

### Change 2 - resume with the failed block

In the failing `DAQ: ACQUIRE`, `getWFMQueue.vi` dequeued block m and its write failed. After recovery, `DAQ: START` dequeues m+1, so m never plays and a ramp jumps by one block. An underflow means the buffer drained, so everything written before m has played; m is the only block lost, whatever the lead.

1. `DAQmx.Recovery--Cluster.ctl`: add **`Pending AO`** (`[MeasureData]`, default empty).
2. Decide **what is actually owed**. A successful write only puts a block in the AO buffer; `DAQ: CLEAR` later discards whatever has not played. Two ways to determine it:

   **(a) Simple, default: gate on the write.** Add an output **`write failed?`** (TF) to `src/DAQmx/Sync.Acquire.vi`, taken from `DAQmx.Write.vi`'s `error out` status before the Merge Errors (the VI runs write and read in parallel and merges with the **read's error first**, so the merged error cannot tell you which failed). Owe the dequeued block only when the write failed.

   Rationale: after the fault the AO task keeps generating while the state machine recovers, which takes 1.2 s median against a block time of order 100 ms, so anything already written drains and plays. A block whose write failed never entered the buffer and is the only one owed.

   Risk: if a recovery is ever faster than the buffer depth, or the fault is a read error (-200279) that leaves written blocks unplayed, this under-replays and the ramp still skips.

   **(b) Exact: ask the device.** Before `DAQ: STOP` tears the tasks down, read the DAQmx Write property **`Write.TotalSampPerChanGenerated`** for each AO task and compare it with the total samples written per channel (track the running total where blocks are written). The difference is what was written but never generated. Owe those blocks regardless of which call failed. Verify on hardware that the property still reads on a task holding a latched error.

   **Replay whole blocks only, either way.** AI and AO block boundaries must stay aligned, because REF waveforms are generated per block and the demodulation pairs them with AI blocks. Resuming sample-accurately with a partial block would offset every later boundary and put REF out of step with AI. Replay blocks that had not started generating and accept a gap shorter than one block for one that was partly played.
3. `DAQ: ACQUIRE` -> `"Error"` frame: in the existing Bundle By Name that writes `Recovering?` and `Fault`, also write `Recovery.Pending AO` <- the `AO` output of this frame's `getWFMQueue.vi` (the array wired into `Sync.Acquire.vi`), gated on whichever test you took in step 2. With (b), `Pending AO` becomes an array of the owed blocks rather than one.
4. `DAQ: START`: Unbundle `Recovery.Pending AO` first. Trigger on **`Pending AO` non-empty**, not on `Recovering?`: `DAQmx.Error Handler.vi` clears `Recovering?` when an *unrecognised* error hits `DAQ: STOP` or `DAQ: CLEAR` mid-recovery, and A2 then carries the recovery through to `DAQ: START` anyway, so the flag can be false while a block is still owed. (`Recovering?` does work for the normal path; if you prefer it as the single owner, keep the clears in step 5 and after use either way.) **Non-empty:** use it as the first pre-written block instead of the first `getWFMQueue.vi` dequeue. With Change 1, the second block comes from one `getWFMQueue.vi` call as usual. Then bundle `Pending AO` = empty. **Empty:** as today.
5. `Macro: Stop`: in the Bundle By Name that sets `Recovering?` = F, also set `Pending AO` = empty, so a stale block never replays on a manual restart.

Pairing needs no extra work. Because `DAQmx.Write.vi`'s delay line is shared, the replayed block goes through it like any other, and the first `DAQ: ACQUIRE` after recovery pairs the AI block with block m. That holds with delay 1 or 2.

Still lost after Change 2: the AI block read during the failing iteration is not published, because `setWaveforms.vi` receives the merged write error. The sweep data therefore misses one point; the output no longer jumps. Recovering that point would mean giving `setWaveforms.vi` only the read's error; not included here.


</details>

### Change 3 - optional: no DAQmx property reads per write

Every write reads task properties: `DAQmx.Write.vi` reads `NumChans` and `Devices` per task, and `DAQmx.Clip AO Waveforms.vi` reads `AO.Min` / `AO.Max` through `Active Channels`. Read them once when the tasks are created, store them in the class, and use the stored values. The time these reads take was not measured. Do this only if underflows persist after Change 1.

### Not recommended: a shorter `getWFMQueue.vi` timeout

The 0.75-block wait does eat most of the slack. But a shorter wait means more fallbacks to the previous waveform, and **during a sweep the fallback is itself a discontinuity**: it replays the last ramp segment, so the output steps back. With a two-block lead the wait is harmless, so leave it.

## Test VIs

`src/DAQmx/Tests/Test Sync.vi` and `Test Sync with Queues.vi` were relinked 2026-09-22 to the new panes: `Sync.Acquire.vi` is called with class + error only and the AO/AI blocks are unbundled off the class wire afterwards. `Test Clip.vi`, `Test Sync (DAQmx).vi`, `Test Sync SMO.vi` and `Test Waveforms.vi` call nothing whose pane changed. The Caraya suites under `Tests/Unit Test/` call only public `Instrument.Lockin` API VIs, none of whose panes changed, so they were not stale - `Test Sweep API.vi` uses `setSweepTable.vim` and never bundles a `Sweep.Configuration--Cluster`, so the #164 rename missed it too.

`ObtainPublicQueues.vi` in `Test Sync with Queues.vi` now gets `Min Queue Buffer` = **2**, matching `Methods (overrides)/onCreated.vi`, so its acquire loop waits for two blocks as production does.

Change 4 removed `Sync.Start.vi`'s `AO 1` / `AO 2` inputs, so each test now does its own priming: **two `DAQmx.Write.vi` calls in series** between `Test Waveforms.vi` and `Sync.Start.vi`, chained on class and error. Both tests are members of `DAQmx.lvclass`, so calling the private `DAQmx.Write.vi` is allowed. Both writes are fed from the same `Test Waveforms.vi` call, so blocks 1 and 2 are identical and the AO output has a phase jump at block 3 - harmless for a lead test; add a second `Test Waveforms.vi` call if you want it phase-continuous.

Neither test calls `DAQmx.Prime AO.vi`, deliberately: `Test Sync.vi` has no queues at all, and in `Test Sync with Queues.vi` both loops start after `Sync.Start.vi`, so the queue is empty at start time and the priming VI's first dequeue would block.

`Test Sync SMO.vi` goes through the real SMO path, so it picks up min buffer 2 from `onCreated.vi`, and it does not call `Sync.Start.vi` directly. No change needed.

## Check on the hardware PC

After a start, open the front panel of `DAQmx.Create Sample Clock.vi` and read the indicators `Output.Buffer` and `Output.Onboard Buffer` (the DAQmx `Output.BufSize` / `Output.OnbrdBufSize` properties, in samples per channel), `Fs (S/s)`, and the samples per block. The buffer should equal one block today and two after Change 1. Block time T = samples / Fs; the smaller T is, the smaller the margin.

## Evidence

**Hardware log, 2026-09-22 12:10-12:27** (`2026-09-22 120942 Errors.txt`, attached to #160; counts are events, not log lines):

- Recovery works: 27 underflows, 26 recoveries (5160), no 5161.
- Underflows every 33 s median (0.7 s to 115 s). 4 came within 1 s of a completed recovery.
- Recovery time (write error -> 5160): median 1.2 s, max 16.7 s.

**Why one block of lead underflows** (read from the VIs):

- `Sync.Start.vi` -> `DAQmx.Start AO.vi` writes **one** block, then starts the tasks. With regeneration off, DAQmx sizes the output buffer from the data written before start, so the buffer is one block (confirm with the check above).
- The loop is paced by the AI read, so the lead never grows past what was pre-written. Each write has to land within about one block time of the previous one.
- Before each write, `getWFMQueue.vi` can wait up to 0.75 of a block (its three dequeues run in parallel with the same timeout). The rest of the loop (publishing, per-write property reads, Windows scheduling) takes the remaining margin.
- The Generator also stays only one block ahead (issue-5 audit, G1), and generation is heavier during sweeps.
- The previous-waveform fallback runs only when a dequeue times out, so it cannot prevent an underflow while waveforms are still arriving.

**Open, not in this spec:** in five of the 27 recoveries the gap between the write error and the `DAQmx Stop Task` error was 4.8-16.6 s; otherwise it is under 2 s. That time is spent inside `DAQ: STOP`'s `Sync.Stop.vi`, and the code does not show why. During a sweep it is a pause. If it persists after Change 1, time `Sync.Stop.vi` per task.
