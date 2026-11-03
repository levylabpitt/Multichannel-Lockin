# Lock-in stress, CPU and memory tests

`lockin_stress.py` drives a running `Multichannel Lockin.exe` over its JSON-RPC interface (ZMQ, port 29170) and samples the exe's process once a second the whole time: CPU, private bytes, working set, handles, threads. It is self-contained (pyzmq, psutil, matplotlib as PEP 723 inline dependencies), so it runs from any branch:

```bash
uv run Tests/stress/lockin_stress.py
```

```bash
uv run Tests/stress/lockin_stress.py profile blocksize soak --soak-min 60
```

Start the exe first. The script snapshots sampling, AO, REF, link frequency and state, and restores them at the end. Each run writes `<time>_<phases>_results.json`, `_monitor.csv` and `_monitor.png` (CPU, memory and handles over time with the phases shaded) to `results/<setup>/<date>_<firmware>/`.

`<setup>` names the computer and its DAQ hardware: by default the computer name plus the DAQ devices Windows reports (`Astartes_USB-4431`). Simulated devices are not Windows devices, so name a simulated setup with `--setup`, for example `--setup VM-HyperV_simulated`. Each results JSON also records the host (CPU, board, cores, RAM, OS, whether a hypervisor is present, DAQ devices) and the AI and AO channels. Write the findings for a setup in `results/<setup>/README.md`.

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
| `phase` (opt-in) | Demodulated phase stability for each `--phase-cases Fs:#s:f` (AO and REF linked at f): Theta and R of every AI over `--phase-s` s; mean, std, drift, largest step, and the full series |
| `sampling` (opt-in) | getAI/getAll time, size and memory as `#s` grows to `--max-samples` |
| `overrun` (opt-in) | Small blocks with and without RPC load; can stop acquisition |
| `torn` (opt-in) | getAI while `#s` toggles; can stop acquisition |
| `robustness` (opt-in) | Malformed requests; `--destructive` adds the two that change configuration |

Default run: everything except the opt-in phases.

## Setups tested

| Setup | Hardware | Findings |
| --- | --- | --- |
| `VM-HyperV_simulated` | Hyper-V VM (4 vCPU of a Ryzen 7 2700X), simulated 4x PXI-4461 + USB-4431, 12 AI, 9 AO | [README](results/VM-HyperV_simulated/README.md) |
| `Astartes_USB-4431` | Physical Ryzen 7 2700X PC, one real USB-4431, 4 AI, 1 AO | [README](results/Astartes_USB-4431/README.md) |

At the defaults (96 kHz, `#s` 10000, 3.9.0.99):

| | VM, simulated | Astartes, USB-4431 |
| --- | --- | --- |
| Exe CPU, acquiring, no clients | 1.0 cores | 0.63 cores |
| Exe CPU, getResults 10 Hz + getAll 1 Hz | 2.0 cores | 0.99 cores |
| Soak, 20 min | no growth | no growth |
| Small RPC request | 6 ms, 140 req/s | 15.5 ms, 64 req/s |
| Unsafe block lengths | 10 ms or less stops; 20-50 ms marginal | 10-20 ms overruns; **0.5 s and longer: AO underflow** (5 s stops) |

## Problems found

In the exe, seen in the runs above. VM = VM-HyperV_simulated, 4431 = Astartes_USB-4431.

1. Acquisition stops quietly when DAQmx reads fall behind. At `#s` 2000 or less (blocks of about 20 ms) reads fail with -200279 even with no RPC load; recovery gives up after 3 failures in 10 s (5161) and the state goes to `idle`. Toggling `#s` between 10000 and 20000 every 0.7 s while reading getAI did the same at normal block sizes. Setters keep returning success afterwards, so a script does not notice. (VM; 4431: at `#s` 1000 with 51.2 and 96 kHz.)
2. The USB-4431's AO underflows (-200621) with blocks of about 0.5 s or longer and is recovered by restarting, which glitches output and results; at 5 s blocks recovery fails. Not seen with simulated devices. (4431)
3. getAI mixes block sizes while `#s` changes: 17 of 25 replies had 9 channels at one length and 3 at the other.
4. `setREF_TC` with `TC: NaN` is accepted and stored; building the filter then fails (-5947, `Create Low Pass RC Filter (FGV).vi`) and acquisition stops.
5. `setSampling` with unknown keys returns success and sets the typedef defaults (Fs 204789, #s 15753).
6. Setters reply before the value is applied: right after `setREF_TC`, about 1 in 3 read-backs returned the old value (5 in 150 for `setAO_Amplitude`) on the VM; 3 in 150 and 0 in 150 on the 4431.
7. A request nested 20000 arrays deep hung the RPC server for good (process alive, no replies); depth 5000 was answered but added about 50k handles that were never released. Not a realistic request; listed for completeness.
8. `HELP setSweep` returns the sweep table schema as `request_schema` instead of the sweep configuration.
