# Lock-in stress, CPU and memory tests

`lockin_stress.py` drives a running `Multichannel Lockin.exe` over its JSON-RPC interface (ZMQ, port 29170) and samples the exe's process once a second the whole time: CPU, private bytes, working set, handles, threads. It is self-contained (pyzmq, psutil, matplotlib as PEP 723 inline dependencies), so it runs from any branch:

```bash
uv run Tests/stress/lockin_stress.py
```

```bash
uv run Tests/stress/lockin_stress.py profile blocksize soak --soak-min 60
```

Start the exe first. The script snapshots sampling, AO, REF, link frequency and state, and restores them at the end. Each run writes `<time>_<phases>_results.json`, `_monitor.csv` and `_monitor.png` (CPU, memory and handles over time with the phases shaded) to `results/<date>_<firmware>/`.

## Phases

| Phase | What it measures |
| --- | --- |
| `profile` | CPU and memory in typical situations, `--profile-s` each: stopped, acquiring with no clients, getResults at 10 Hz, getAI at 1 Hz, getAll at 1 Hz, both together, getAll and getResults flat out |
| `blocksize` | CPU and memory against `#s` with no RPC load (`--block-sizes`, `--block-s`), plus DAQ overruns counted from the exe's error log |
| `soak` | `--soak-min` minutes at getResults 10 Hz + getAll every 2 s; growth rates (MB/min, handles/min) over the whole run and over the second half |
| `latency` | Round-trip time and reply size of every getter |
| `freshness` | How often getResults' time stamp advances while polling flat out |
| `concurrency` | 1-32 parallel clients, small and large replies |
| `setters` | Set then immediately read back; counts stale read-backs |
| `state` | stop/start timings |
| `sweep` | 2 s and 10 s sweeps: transitions and total time |
| `churn` | A new connection per request, and abandoned requests |
| `grid` (opt-in) | Every `--grid-fs` x `--grid-ns` combination for `--grid-s` s with getResults at 10 Hz: whether acquisition keeps running, errors during the switch and in steady state (from the exe's error log), CPU, memory, getAI time |
| `sampling` (opt-in) | getAI/getAll time, size and memory as `#s` grows to `--max-samples` |
| `overrun` (opt-in) | Small blocks with and without RPC load; can stop acquisition |
| `torn` (opt-in) | getAI while `#s` toggles; can stop acquisition |
| `robustness` (opt-in) | Malformed requests; `--destructive` adds the two that change configuration |

Default run: everything except the opt-in phases.

## Findings, 3.9.0.99 (2026-10-30, VM, simulated PXI1Slot2-5 PXI-4461 + Dev1 USB-4431, 12 AI, 9 AO, 96 kHz, #s 10000)

Host: Hyper-V VM with 4 virtual processors (2 cores / 4 threads of a Ryzen 7 2700X) and 20 GB RAM. The simulated devices generate their data inside the exe, so its CPU figures include the simulation. Raw data in `results/2026-10-30_3.9.0.99_first-pass/` (from an earlier version of the script; its monitor files are JSON with CPU as % of one core) and `results/2026-10-30_3.9.0.99/`.

### CPU and memory

From `results/2026-10-30_3.9.0.99/191635_profile-blocksize-soak_*` (60 s per scenario, 45 s per block size, 20 min soak). CPU is in cores (the VM has 4).

| Situation | Exe CPU (cores) | Private memory (MB) |
| --- | --- | --- |
| Freshly started exe, idle | about 0.1 | 343 |
| Stopped, after it has run | 0.16 | 561 |
| Acquiring, no clients | 1.0 | 580 |
| getResults at 10 Hz | 1.1 | 580 |
| getAI at 1 Hz | 1.6 | 630-675 |
| getAll at 1 Hz | 2.0 | 635-715 |
| getResults 10 Hz + getAll 1 Hz | 2.0 | 625-705 |
| getAll flat out | 2.0 | 630-720 |
| getResults flat out | 1.5 | 605 |

| `#s` (block) | Exe CPU (cores), no clients | Private memory (MB) |
| --- | --- | --- |
| 5000 (52 ms) | 1.5 | 560 |
| 10000 (104 ms) | 1.0 | 600 |
| 25000 (260 ms) | 0.8 | 790 |
| 50000 (521 ms) | 0.73 | 1040 |
| 100000 (1.04 s) | 0.71 | 1550-1600 |
| back to 10000 | 1.2 | 730 (did not return to 600) |

- No leak at a realistic load: over the 20 min soak (getResults 10 Hz + getAll every 2 s) private memory saw-tooths between about 720 and 840 MB with a slope of 0.0 MB/min, and handles stay at 64490. CPU is a steady 2 cores.
- Acquisition and demodulation alone cost about 1 core at the default 10000 samples, more for smaller blocks (1.5 cores at 5000; 2000 and below cannot keep up). Each RPC client pulling waveforms at 1 Hz costs another 0.6 (getAI) to 1 core (getAll), so a UI or script that polls getAll doubles the exe's CPU.
- Memory grows about 10.5 MB per 1000 samples of `#s`, roughly 100 times the raw AI data (12 channels x 8 bytes per sample is about 0.1 MB per 1000). Going back to a smaller `#s` leaves about 130 MB allocated. In the first pass, `#s` 200000 with getAI/getAll calls took the exe to 5.4 GB, and it came back only to about 1 GB.
- The exe holds about 64400 Windows handles from start-up on. That is its baseline, not growth.
- During the 25000-100000 block sizes the whole VM sat at 100% CPU (4 cores) while the exe used only 0.7. Something else was busy; no NI process on the VM used noticeable CPU, so it was probably load on the Hyper-V host. Not identified.

### Sampling rate x buffer size

`uv run Tests/stress/lockin_stress.py grid` (two runs: `204540_grid_*` and `210343_grid_*`; 20 s per combination, getResults polled at 10 Hz, blocks longer than 5 s skipped). "Steady state" is from run 2, which counts errors after the switch has settled; errors logged while switching are in the JSON as `switch_errors`. CPU, memory and getAI columns show run 1 / run 2.

| Fs (Hz) | #s | Block (ms) | Steady state | Exe CPU (cores) | Private (MB) | getAI (s) |
| --- | --- | --- | --- | --- | --- | --- |
| 10000 | 1000 | 100 | ok | 0.7 / 0.6 | 584 / 736 | 0.1 / 0.1 |
| 10000 | 2500 | 250 | ok | 0.4 / 0.4 | 587 / 727 | 0.2 / 0.2 |
| 10000 | 5000 | 500 | ok | 0.3 / 0.3 | 598 / 726 | 0.6 / 0.4 |
| 10000 | 10000 | 1000 | ok | 0.2 / 0.2 | 680 / 800 | 1.0 / 0.8 |
| 10000 | 25000 | 2500 | ok | 0.2 / 0.2 | 841 / 964 | 3.9 / 2.2 |
| 10000 | 50000 | 5000 | ok | 0.2 / 0.2 | 1052 / 1187 | 4.6 / 4.5 |
| 25600 | 1000 | 39.1 | ok | 0.7 / 0.7 | 625 / 731 | 0.1 / 0.1 |
| 25600 | 2500 | 97.7 | ok | 0.4 / 0.4 | 624 / 723 | 0.2 / 0.2 |
| 25600 | 5000 | 195.3 | ok | 0.3 / 0.3 | 627 / 726 | 0.4 / 0.5 |
| 25600 | 10000 | 390.6 | ok | 0.2 / 0.2 | 718 / 786 | 0.9 / 0.9 |
| 25600 | 25000 | 976.6 | ok | 0.2 / 0.2 | 849 / 935 | 2.4 / 2.0 |
| 25600 | 50000 | 1953.1 | ok | 0.2 / 0.2 | 962 / 1201 | 2.9 / 4.4 |
| 25600 | 100000 | 3906.2 | read timeout, recovers | 0.3 / 0.3 | 1565 / 1651 | 5.2 / 5.2 |
| 51200 | 1000 | 19.5 | overrun, recovers | 1.2 / 0.9 | 794 / 848 | 0.3 / 0.3 |
| 51200 | 2500 | 48.8 | overrun, recovers | 1.4 / 1.4 | 739 / 821 | 0.2 / 0.4 |
| 51200 | 5000 | 97.7 | ok | 1.4 / 1.5 | 760 / 779 | 0.4 / 1.2 |
| 51200 | 10000 | 195.3 | ok | 1.1 / 0.8 | 741 / 786 | 1.2 / 1.1 |
| 51200 | 25000 | 488.3 | ok | 0.6 / 0.6 | 887 / 941 | 2.5 / 2.7 |
| 51200 | 50000 | 976.6 | ok | 0.5 / 0.5 | 1159 / 1197 | 4.8 / 5.6 |
| 51200 | 100000 | 1953.1 | ok | 0.4 / 0.5 | 1625 / 1661 | 10.1 / 11.6 |
| 96000 | 1000 | 10.4 | **stops** | 0.8 / 0.8 | 696 / 721 | 0.1 / 0.1 |
| 96000 | 2500 | 26 | overrun, recovers | 1.4 / 1.4 | 738 / 835 | 0.5 / 0.4 |
| 96000 | 5000 | 52.1 | ok | 1.4 / 1.6 | 987 / 1074 | 0.2 / 0.4 |
| 96000 | 10000 | 104.2 | ok | 1.9 / 1.6 | 836 / 1394 | 2.7 / 0.8 |
| 96000 | 25000 | 260.4 | ok | 1.3 / 1.6 | 924 / 1539 | 2.9 / 1.0 |
| 96000 | 50000 | 520.8 | ok | 0.8 / 1.6 | 1173 / 1420 | 5.8 / 4.3 |
| 96000 | 100000 | 1041.7 | ok | 0.7 / 1.1 | 1643 / 1696 | 13.1 / 11.1 |
| 102400 | 1000 | 9.8 | **stops** | 0.6 / 0.6 | 723 / 721 | 0.1 / 0.2 |
| 102400 | 2500 | 24.4 | ok | 1.6 / 2.5 | 858 / 700 | 0.8 / 0.2 |
| 102400 | 5000 | 48.8 | ok | 1.5 / 1.6 | 1048 / 705 | 0.4 / 0.8 |
| 102400 | 10000 | 97.7 | ok | 1.5 / 1.3 | 1402 / 778 | 0.4 / 1.9 |
| 102400 | 25000 | 244.1 | ok | 1.6 / 1.0 | 1533 / 942 | 0.8 / 3.5 |
| 102400 | 50000 | 488.3 | ok | 1.6 / 0.8 | 1362 / 1188 | 1.7 / 6.1 |
| 102400 | 100000 | 976.6 | ok | 1.3 / 0.8 | 1638 / 1659 | 11.2 / 11.1 |
| 204800 | 1000 | 4.9 | **stops** | 0.7 / 0.6 | 716 / 725 | 0.1 / 0.1 |
| 204800 | 2500 | 12.2 | ok | 2.3 / 2.5 | 691 / 707 | 0.4 / 0.3 |
| 204800 | 5000 | 24.4 | ok | 1.6 / 1.6 | 681 / 712 | 0.5 / 0.7 |
| 204800 | 10000 | 48.8 | ok | 1.4 / 1.3 | 764 / 796 | 1.6 / 1.6 |
| 204800 | 25000 | 122.1 | ok | 1.0 / 1.1 | 937 / 965 | 3.3 / 4.5 |
| 204800 | 50000 | 244.1 | ok | 0.8 / 0.8 | 1203 / 1225 | 5.5 / 6.0 |
| 204800 | 100000 | 488.3 | ok | 0.7 / 0.7 | 1737 / 1668 | 10.4 / 11.2 |

- Acquisition stops for good (recovery gives up, state `idle`) only at `#s` 1000 with Fs of 96 kHz or more: blocks of 10 ms or less. It happened in both runs.
- Blocks of about 20-50 ms are marginal: 51.2 kHz with 1000 and 2500 samples and 96 kHz with 2500 had one overrun each in steady state in both runs, and recovered. 102.4 and 204.8 kHz with 2500 samples (12-24 ms) overran only while switching. Block length alone does not decide it: 204.8 kHz x 10000 (48.8 ms) was clean while 51.2 kHz x 2500 (48.8 ms) overran twice. Blocks of 50 ms and longer were clean everywhere except the next point.
- 25.6 kHz x 100000 (3.9 s blocks) hit a DAQmx read timeout (-200284) while switching in both runs, then recovered, while 10 kHz x 50000 (5 s blocks) did not. Worth checking how the read timeout is derived.
- CPU depends mostly on block length, not on the rate: at 10-25.6 kHz the exe needs 0.2-0.4 cores once blocks are 250 ms or longer, and at 51.2-204.8 kHz it falls from 1.3-1.6 cores at 50-100 ms blocks to 0.7-0.8 at 0.5-1 s blocks. Very short blocks are the expensive case (2.3-2.5 cores at 12-24 ms).
- Memory follows `#s` and hardly the rate: about 600-800 MB up to 10000 samples, about 1.2 GB at 50000, 1.6-1.7 GB at 100000.
- getAI time grows with `#s` (about 0.1 s per 1000 samples, 10-13 s at 100000). At large buffers a client polling getAI blocks every other RPC request for that long.
- The two runs agree on outcomes but differ by up to 0.8 core and 600 MB in places (for example 96 kHz x 10000: 1.9 / 1.6 cores, 836 / 1394 MB), so treat single CPU and memory numbers as +/- that much. Memory in particular depends on what ran before.

### Outside the VM

These numbers come from a 2-core VM with simulated devices. On a dedicated PC with real cards:

- Memory, the bugs below and the one-request-at-a-time RPC behavior should carry over. RPC times scale with single-core speed, so a modern desktop might be 1.5-2x faster, not 10x.
- CPU should be clearly lower (no simulated data generation, more and faster cores), and the marginal 20-50 ms block zone should move toward shorter blocks with fewer isolated overruns. Do not count on blocks under about 20 ms without testing.
- The simulator accepted 204.8 kHz on every device, but a real USB-4431 tops out at 102.4 kS/s, and DSA cards coerce the rate. The USB-4431 is not hardware-synchronized and is the device most likely to fall behind with short blocks. Real DSA filter delay makes start-up and the first result slower than measured here.

To check, run on the lab machine with the real hardware (keep Fs at 102.4 kHz or below when the 4431 is in the channel list):

```bash
uv run Tests/stress/lockin_stress.py profile blocksize
```

```bash
uv run Tests/stress/lockin_stress.py grid --grid-fs 25600 51200 96000 102400
```

Running the same on a physical PC with simulated devices separates the effect of the VM from the effect of the simulation.

### RPC performance

- Requests are handled one at a time: about 6 ms per small request, about 140 requests/s in total whether 1 or 32 clients are connected.
- getAI (2.5 MB) takes about 560 ms and getAll (3.1 MB) about 1 s, so replies are built at about 4-5 MB/s. A small request queued behind getAll waits for it: with two clients polling getAll, getState took about 3 s.
- getResults updates every 104 ms, the block time.
- stop takes about 100 ms, start about 170 ms, and the first new result arrives about 310 ms after start. 2 s and 10 s sweeps finish in 3.5 s and 11.3 s.
- 500 connect/request/close cycles and 50 abandoned requests caused no failures and no handle growth.

### Problems found

1. Acquisition stops quietly when DAQmx reads fall behind. At `#s` 2000 or less (blocks of about 20 ms) reads fail with -200279 even with no RPC load; recovery gives up after 3 failures in 10 s (5161) and the state goes to `idle`. Toggling `#s` between 10000 and 20000 every 0.7 s while reading getAI did the same at normal block sizes. Setters keep returning success afterwards, so a script does not notice.
2. getAI mixes block sizes while `#s` changes: 17 of 25 replies had 9 channels at one length and 3 at the other.
3. `setREF_TC` with `TC: NaN` is accepted and stored; building the filter then fails (-5947, `Create Low Pass RC Filter (FGV).vi`) and acquisition stops.
4. `setSampling` with unknown keys returns success and sets the typedef defaults (Fs 204789, #s 15753).
5. Setters reply before the value is applied: right after `setREF_TC`, about 1 in 3 read-backs returned the old value (5 in 150 for `setAO_Amplitude`).
6. A request nested 20000 arrays deep hung the RPC server for good (process alive, no replies); depth 5000 was answered but added about 50k handles that were never released. Not a realistic request; listed for completeness.
7. `HELP setSweep` returns the sweep table schema as `request_schema` instead of the sweep configuration.
