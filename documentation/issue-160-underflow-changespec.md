# Issue #160, round 2 - underflow rate and sweep continuity (change spec)

Instructions first; the evidence is at the bottom. Follows [issue-160-changespec.md](issue-160-changespec.md) (recovery, released in 3.6.0.80).

## Changes

| # | What | Why | Priority |
|---|---|---|---|
| 1 | Keep **two** AO blocks ahead instead of one | removes the structural cause of the underflow | **done** 2026-09-22: Generator gate 0..1, min buffer 2, two pre-writes, feedback delay 2 - all four verified |
| 2 | After a recovery, write the block that failed before anything new | stops a sweep from skipping a block | **done** 2026-09-22, see "AS BUILT" |
| 3 | Stop reading DAQmx properties on every write | trims per-write latency | optional, only if 1 is not enough |

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

**Residual issues** (all minor, none blocking a hardware run):

1. `Macro: Stop` clears `Recovering?` and one waveform field only; `Pending REF_X/REF_Y` keep stale values. Harmless, because every write path is preceded by a dequeue that rewrites all three, but clear all three for consistency.
2. If `Sync.Start.vi` itself fails during a recovery, one block is lost: `getWFMQueue.Initial.vi`'s second dequeue has already overwritten `Pending AO` with the second block, so the first is unrecoverable. Rare, costs one block. Fix only if it shows up.
3. The two pre-writes inside `DAQmx.Start AO.vi` both read the same `Pending REF_X/REF_Y` (the second block's), so the delay line gets REF(m+1) twice instead of REF(m), REF(m+1). Benign **only because** each block holds an integer number of REF periods, which makes the arrays identical; that is a silent dependency on `Find Integer Period Fs and Ns`. Pass REF per write if you want it exact.
4. `setWaveforms.vi`'s publish gate tests only `Waveforms.AO` and `Waveforms.AI`; the two `Empty Array?` nodes on REF_X / REF_Y are unused. Either add them to the gate or delete them.
5. Dead terminals now that data rides the class wire: `Sync.Acquire.vi`'s `AO` input and its `AOwfm out (previous)` / `AIwfm` outputs, `DAQmx.Write.vi`'s `AOwfm out (previous)`, and `setWaveforms.vi`'s four waveform inputs. Remove them from the connector panes so nobody rewires them later.

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
