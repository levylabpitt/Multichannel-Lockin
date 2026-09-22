# Issue #160, round 2 - underflow rate and sweep continuity (change spec)

Instructions first; the evidence is at the bottom. Follows [issue-160-changespec.md](issue-160-changespec.md) (recovery, released in 3.6.0.80).

## Changes

| # | What | Why | Priority |
|---|---|---|---|
| 1 | Keep **two** AO blocks ahead instead of one | removes the structural cause of the underflow | **required** |
| 2 | After a recovery, write the block that failed before anything new | stops a sweep from skipping a block | **required** for sweeps |
| 3 | Stop reading DAQmx properties on every write | trims per-write latency | optional, only if 1 is not enough |

### Change 1 - two-block AO lead

Use N = 2 throughout.

1. **Generator** `src/Generator/Process.vi`, event `[0] Timeout`, frame `"started"`: the `In Range and Coerce` that gates `Generator: Generate` has limits 0..0. Change the **upper limit to 1**, so the Generator generates while the AO queue holds 0 or 1 blocks.
2. **Min buffer** `src/DAQmx/Methods (overrides)/onCreated.vi`: the constant wired to `ObtainPublicQueues.vi` terminal `Min Queue Buffer` is 1. Change it to **2**. `DAQ: START` then waits (up to 5 s, already there) until two blocks are queued.
3. **Pre-write two blocks** in `DAQ: START`. After the existing `getWFMQueue.vi` (`wait for min buffer?` = T), call `getWFMQueue.vi` again with `wait for min buffer?` = F to take the second block. Then write both before any task starts: two `DAQmx.Write.vi` calls, first block then second, ahead of the `DAQmx Start Task` loop. Doing it inside `DAQmx.Start AO.vi` (a second `AO []` input and a second `DAQmx.Write.vi` before its Start Task loop) keeps `DAQ: START` tidy. Two separate writes, not one concatenated write, matter for step 4.
4. **Pairing delay 1 -> 2.** The AI block read in an iteration was generated alongside the AO block written N iterations earlier.
   - `src/DAQmx/private/DAQmx.Write.vi`: the Feedback Node that drives `AOwfm out (previous)` -> right-click > Properties > **Delay = 2**. That VI is non-reentrant and shared by `DAQmx.Start AO.vi` and `Sync.Acquire.vi`, so the two pre-writes fill the delay line and the first `DAQ: ACQUIRE` pairs AI block 1 with AO block 1.
   - `src/DAQmx/Process.vi`, `DAQ: ACQUIRE`: the two Feedback Nodes on `getWFMQueue.vi`'s REF_X / REF_Y outputs -> **Delay = 2**.

Cost: an AO change reaches the output one block later than today (e.g. +100 ms at a 10 Hz refresh rate).

### Change 2 - resume with the failed block

In the failing `DAQ: ACQUIRE`, `getWFMQueue.vi` dequeued block m and its write failed. After recovery, `DAQ: START` dequeues m+1, so m never plays and a ramp jumps by one block. An underflow means the buffer drained, so everything written before m has played; m is the only block lost, whatever the lead.

1. `DAQmx.Recovery--Cluster.ctl`: add **`Pending AO`** (`[MeasureData]`, default empty).
2. `DAQ: ACQUIRE` -> `"Error"` frame: in the existing Bundle By Name that writes `Recovering?` and `Fault`, also write `Recovery.Pending AO` <- the `AO` output of this frame's `getWFMQueue.vi` (the array wired into `Sync.Acquire.vi`). It only matters when `Recovering?` = T; when `DAQmx Error?` is F the next state is `Macro: Stop`, which clears it (step 4).
3. `DAQ: START`: Unbundle `Recovery.Pending AO` first. **Non-empty:** use it as the first pre-written block instead of the first `getWFMQueue.vi` dequeue. With Change 1, the second block comes from one `getWFMQueue.vi` call as usual. Then bundle `Pending AO` = empty. **Empty:** as today.
4. `Macro: Stop`: in the Bundle By Name that sets `Recovering?` = F, also set `Pending AO` = empty, so a stale block never replays on a manual restart.

Pairing needs no extra work. Because `DAQmx.Write.vi`'s delay line is shared, the replayed block goes through it like any other, and the first `DAQ: ACQUIRE` after recovery pairs the AI block with block m. That holds with delay 1 or 2.

Still lost after Change 2: the AI block read during the failing iteration is not published, because `setWaveforms.vi` receives the merged write error. The sweep data therefore misses one point; the output no longer jumps. Recovering that point would mean giving `setWaveforms.vi` only the read's error; not included here.

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
