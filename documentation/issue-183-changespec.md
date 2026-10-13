# Issue #183 - getStatus replies late (>0.7 s) around startSweep (change spec)

**Problem.** Around `startSweep`, the lock-in server sometimes does not answer `getStatus` for about 0.7 s, which is 7 ZMQ attempts at the API's 100 ms timeout. Combined with levylabpitt/RemoteControl.ZMQ#1, that becomes the error 91 dialog in Transport `Lockin_sweep`. The client-side fixes (RemoteControl.ZMQ#1, levylabpitt/Instrument-Framework#200) make the run survive it. This issue is about the server answering promptly.

**Scope.** Measure first, then fix only what the measurement shows. No API or wire change. The locations below were read with lvkit on `develop` (3.8.0.91) on 2026-10-13. Paths are relative to `src/`.

## What is already known

- `Instrument.Lockin/Overrides/Handle Command.vi`, frame "16, 17" (`getStatus` and its neighbour; lvkit shows only the first values of a multi-value frame), unbundles the cached `Status--enum` from the class and converts it. It is cheap and makes no call into the DAQ.
- Frame "39" (`setState` and, per lvkit, probably the start/stop commands; check in LabVIEW) calls `Instrument.DAQ/API/DAQ.setstate.vi`. That VI only does `Generate User Event` (high priority) and returns. **`startSweep` does not block the command handler.**
- Frame "40" (`setSweep`) calls `Replace Sweep Waveforms.vi` and `DAQ.setSweep.vi`. Transport calls `setSweep` just before `startSweep`, so its cost lands in the same window.
- Frame "20" calls `Lockin.logConfiguration.vi` (database logging), and frames "42" / "43" call `Lockin.setLogMode.vi`.

So the late reply is probably **not** one long frame in `Handle Command.vi`. More likely, the server loop is not getting to run.

## Steps

### 1. Measure (new test VI, not shipped)

Add `Tests/Measure getStatus Latency.vi` to the Unit Tests project:

1. Open a Remote client to a running Lockin exe (same address as Transport).
2. Repeat N = 50 times:
   - `setSweep` with a typical Transport sweep configuration;
   - `startSweep`;
   - then for 3 s, call `getStatus` back to back with a 5000 ms timeout, so the client never retries, and log each call's time (`Tick Count` before and after);
   - `stopSweep`, then wait for idle.
3. Report, per run: the max latency, and the time from `startSweep` to that max. Write it to CSV.

Run it on a rig with the real cards and on a simulated one. If the max latency is under 100 ms everywhere, the problem is environmental (CPU load from other software) and steps 2 and 3 can be skipped.

### 2. Locate the stall

Pick a run with a large max latency, and check in this order:

1. **UI thread contention.** If `Instrument UI.Lockin` updates large graphs or uses property nodes when the sweep starts, everything forced into the UI thread waits for it. Check whether `Instrument.Lockin/Process.vi`, `Handle Command.vi`, or the RemoteControl server VIs run in the UI execution system or call anything that does (property nodes, front-panel references). Test: close the Lockin UI and repeat step 1.
2. **CPU starvation from `Instrument.DAQ` at sweep start.** Sweep waveform generation (`Replace Sweep Waveforms.vi`, `Generator`), the DAQmx task restart, and the first DSP blocks. Test: time `Instrument.DAQ/Process.vi`'s sweep-start states with `Tick Count` logging, and watch per-core CPU during the window.
3. **Database logging** (`Lockin.logConfiguration.vi`) when a state change or `setSweep` triggers it. Test: turn logging off with `setLogMode` and repeat step 1.

### 3. Fix

This depends on step 2. Likely shapes:

- Move UI work out of the UI thread's path, or throttle graph updates for the first second of a sweep.
- Give the command/server loop its own execution system (`other 1`) or a higher priority than the DSP/generator VIs.
- Run sweep-waveform generation in `Instrument.DAQ`, not inside the `setSweep` frame of `Handle Command.vi`.
- Make database logging asynchronous.

## Acceptance

With the step 1 test VI, 50 runs on the real rig: the max `getStatus` latency is under 100 ms in every run.

Related: levylabpitt/RemoteControl.ZMQ#1, levylabpitt/Instrument-Framework#200, levylabpitt/Transport#180.
