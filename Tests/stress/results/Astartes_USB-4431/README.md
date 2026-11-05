# Astartes_USB-4431: 3.9.0.99 (2026-11-03, physical PC, one real USB-4431, 4 AI, 1 AO, 96 kHz, #s 10000)

Host: Gigabyte B450M DS3H, AMD Ryzen 7 2700X (8 cores / 16 threads, the same CPU that hosted the VM in [VM-HyperV_simulated](../VM-HyperV_simulated/README.md)), 128 GB RAM, Windows 11 with Hyper-V enabled. Device `Dev1` (USB-4431), channels `Dev1/ai0-3`, AO1 looped back to AI1 (R = 0.100 V at 0.1 V amplitude); AI2-4 carry no signal. One exe instance (pid 31732) for every run, so later runs start from the memory left by earlier ones. Raw data in `2026-11-03_3.9.0.99/` and `2026-11-04_3.9.0.99/` (a repeat of the phase test).

Note the channel count: 4 AI and 1 AO here against 12 AI and 9 AO on the VM, so memory, reply sizes and getAI times are not directly comparable; CPU per situation is.

## CPU and memory

From `094617_profile-...-soak_*` (60 s per scenario, 45 s per block size, 20 min soak). CPU is in cores (the PC has 16 threads).

| Situation | Exe CPU (cores) | Private memory (MB) | VM, for comparison (cores) |
| --- | --- | --- | --- |
| Stopped, after it has run | 0.15 | 449 | 0.16 |
| Acquiring, no clients | 0.63 | 447 | 1.0 |
| getResults at 10 Hz | 0.68 | 446 | 1.1 |
| getAI at 1 Hz | 0.82 | 469-479 | 1.6 |
| getAll at 1 Hz | 0.92 | 488-501 | 2.0 |
| getResults 10 Hz + getAll 1 Hz | 0.99 | 464-495 | 2.0 |
| getAll flat out | 1.52 | 491-508 | 2.0 |
| getResults flat out | 0.82 | 466-472 | 1.5 |

| `#s` (block) | Exe CPU (cores), no clients | Private memory (MB) |
| --- | --- | --- |
| 5000 (52 ms) | 0.74 | 457 |
| 10000 (104 ms) | 0.62 | 472 |
| 25000 (260 ms) | 0.37 | 532 |
| 50000 (521 ms) | 0.40 | 620 |
| 100000 (1.04 s) | 0.35 | 714-826 |
| back to 10000 | 0.60 | 513 (did not return to 472) |

- About 0.6 cores to acquire and demodulate at the defaults, against 1.0 on the VM with simulated devices. RPC clients pulling waveforms cost 0.2-0.3 cores each at 1 Hz (0.6-1.0 on the VM).
- No leak: over the 20 min soak private memory went 516 -> 502 MB (+0.2 MB/min overall, +0.1 in the second half), handles stayed at 64990, no overruns. CPU 0.74 cores.
- Memory grows about 3.7 MB per 1000 samples of `#s` with 4 AI (about 10.5 on the VM with 12 AI), so roughly 0.9 MB per 1000 samples per channel on both. As on the VM, going back to a smaller `#s` leaves some of it allocated (about 40 MB here).
- Handles sit at about 64900 from start-up on, as on the VM.

## Sampling rate x buffer size

`grid --grid-fs 10000 25600 51200 96000 102400` twice (`102514_grid_*`, `104207_grid_*`; 20 s per combination, getResults at 10 Hz). Every requested rate was applied exactly. Steady state counts errors after the switch has settled; errors while switching are in the JSON as `switch_errors`.

| Fs (Hz) | #s | Block (ms) | Steady state, run 1 / run 2 | Exe CPU (cores) | Private (MB) | getAI (s) |
| --- | --- | --- | --- | --- | --- | --- |
| 10000 | 1000 | 100 | ok | 0.5 / 2.2 | 470 / 528 | 0.0 / 0.1 |
| 10000 | 2500 | 250 | ok | 0.15 / 1.1 | 471 / 527 | 0.0 / 0.1 |
| 10000 | 5000 | 500 | ok | 0.31 / 0.81 | 475 / 523 | 0.1 / 0.1 |
| 10000 | 10000 | 1000 | AO underflow, recovers / ok | 0.21 / 0.57 | 498 / 543 | 0.2 / 0.2 |
| 10000 | 25000 | 2500 | AO underflow, recovers / ok | 0.19 / 0.18 | 553 / 580 | 0.5 / 0.4 |
| 10000 | 50000 | 5000 | **stops** / **stalls** (AO write blocked, result lag grows 1 s/s) | 0.19 / 0.22 | 625 / 646 | 0.9 / 1.1 |
| 25600 | 1000 | 39.1 | ok | 0.66 / 0.99 | 501 / 524 | 0.0 / 0.0 |
| 25600 | 2500 | 97.7 | ok | 0.51 / 0.45 | 481 / 503 | 0.1 / 0.1 |
| 25600 | 5000 | 195.3 | ok | 0.4 / 0.32 | 484 / 504 | 0.1 / 0.1 |
| 25600 | 10000 | 390.6 | ok | 0.28 / 0.32 | 509 / 527 | 0.2 / 0.2 |
| 25600 | 25000 | 976.6 | ok / AO underflow, recovers | 0.19 / 0.25 | 556 / 582 | 0.5 / 0.4 |
| 25600 | 50000 | 1953.1 | AO underflow, recovers | 0.21 / 0.21 | 651 / 672 | 0.9 / 0.9 |
| 25600 | 100000 | 3906.2 | AO underflow, recovers | 0.17 / 0.21 | 811 / 825 | 1.9 / 1.7 |
| 51200 | 1000 | 19.5 | **stops** (overrun) / overrun, recovers | 0.27 / 0.96 | 504 / 546 | 0.0 / 0.1 |
| 51200 | 2500 | 48.8 | ok | 0.66 / 0.73 | 499 / 529 | 0.1 / 0.1 |
| 51200 | 5000 | 97.7 | ok | 0.53 / 0.5 | 496 / 502 | 0.1 / 0.1 |
| 51200 | 10000 | 195.3 | ok | 0.34 / 0.38 | 525 / 526 | 0.2 / 0.2 |
| 51200 | 25000 | 488.3 | ok | 0.28 / 0.28 | 581 / 580 | 0.5 / 0.4 |
| 51200 | 50000 | 976.6 | AO underflow, recovers | 0.27 / 0.31 | 667 / 666 | 0.9 / 1.0 |
| 51200 | 100000 | 1953.1 | AO underflow, recovers | 0.24 / 0.29 | 835 / 844 | 1.9 / 1.7 |
| 96000 | 1000 | 10.4 | **stops** (overrun) / overrun, recovers | 0.32 / 1.77 | 513 / 542 | 0.0 / 0.1 |
| 96000 | 2500 | 26 | ok | 1.48 / 1.21 | 502 / 506 | 0.1 / 0.1 |
| 96000 | 5000 | 52.1 | ok | 0.83 / 0.89 | 502 / 507 | 0.1 / 0.1 |
| 96000 | 10000 | 104.2 | ok | 0.53 / 0.59 | 524 / 531 | 0.2 / 0.2 |
| 96000 | 25000 | 260.4 | ok | 0.4 / 0.38 | 578 / 587 | 0.4 / 0.4 |
| 96000 | 50000 | 520.8 | ok / AO underflow, recovers | 0.35 / 0.38 | 663 / 688 | 0.8 / 0.8 |
| 96000 | 100000 | 1041.7 | AO underflow, recovers | 0.41 / 0.32 | 840 / 847 | 1.9 / 1.7 |
| 102400 | 1000 | 9.8 | ok | 2.15 / 1.48 | 538 / 543 | 0.1 / 0.1 |
| 102400 | 2500 | 24.4 | AO underflow, recovers / ok | 1.31 / 1.32 | 502 / 506 | 0.1 / 0.1 |
| 102400 | 5000 | 48.8 | ok | 0.7 / 0.92 | 501 / 506 | 0.1 / 0.1 |
| 102400 | 10000 | 97.7 | ok | 0.54 / 0.53 | 526 / 534 | 0.2 / 0.2 |
| 102400 | 25000 | 244.1 | ok | 0.39 / 0.37 | 579 / 581 | 0.4 / 0.4 |
| 102400 | 50000 | 488.3 | AO underflow, recovers | 0.39 / 0.32 | 668 / 670 | 0.9 / 0.8 |
| 102400 | 100000 | 976.6 | AO underflow, recovers | 0.32 / 0.29 | 843 / 842 | 1.7 / 1.5 |

- **New on real hardware: AO underflow.** The USB-4431's output underflows (-200621 "Onboard device memory underflow ... could not write data to the device fast enough", at `DAQmx.Write.vi`) with blocks of about 0.5 s or longer: in most combinations with a block of 1 s or more (about once per 20 s window), and occasionally at 0.5 s, recovering each time (5160 "Recovered from DAQmx error -200621 after 1 attempt"). It also happens on most switches of `#s`. Each recovery restarts the tasks, so the output and the demodulated results glitch. With 5 s blocks (10 kHz x 50000) recovery fails: run 1 gave up (5161) and went `idle`; in run 2 the AO write blocked (-200292 "samples to write could not be written to the buffer yet") and the newest result fell behind by 1 s every second. The simulated devices never underflowed, so this needs a look at how AO is written per block. A guess, not checked in the code: writing a whole block of AO at once, timed by the AI block, does not keep the 4431's onboard AO buffer topped up when blocks are long.
- Short blocks: `#s` 1000 at 51.2 and 96 kHz (10-20 ms) overran (-200279) in both runs, stopping for good in run 1 and recovering in run 2. 102.4 kHz x 1000 (9.8 ms) ran clean in both, so the limit is not a sharp block length. 2500 samples and up were clean apart from one AO underflow at 102.4 kHz x 2500. The VM had the same picture: blocks of 10 ms or less are not safe.
- The sweet spot is blocks of about 50-500 ms: no steady-state errors in either run.
- CPU is lower than on the VM throughout (0.3-0.6 cores at 100 ms - 1 s blocks, against 0.7-1.6), and depends on block length the same way. Run 2's first combinations (10 kHz x 1000 and 2500: 2.2 and 1.1 cores) are much higher than run 1's; they followed straight after the 30 s phase measurement, so treat them as noise.
- Memory follows `#s` (about 500 MB at 10000, 670 MB at 50000, 840 MB at 100000 with 4 AI).
- getAI with 4 AI: about 0.2 s at 10000 samples, 1.5-1.9 s at 100000.

## Demodulated phase

`phase` (`2026-11-03_3.9.0.99/103937_phase_*`, `2026-11-03_3.9.0.99/105615_phase_*`, `2026-11-04_3.9.0.99/165441_phase_*`): AO and REF linked at f, TC 0.3 s, roll-off 2, a 5.3 s wait after each change, then 30 s of results; AI1 (loopback). Cases run one after another, so each starts from the previous one's settings ("Before"; the first case of a run starts from the exe's 96 kHz / 10000 / 1355 Hz). "Initial offset" is the first result minus the settled value (mean of the last 50 results), also as a time, offset / (360 f). "Steady std" is the scatter over the last three quarters of the window.

| Run, case | Fs / #s / f | Before | Cycles per block | Settled theta (deg) | Initial offset (deg) | Steady std (deg) |
| --- | --- | --- | --- | --- | --- | --- |
| `103937` 1 | 94000 / 10000 / 500 | 96000 / 10000 / 1355 | 53.19 | -104.889 | -0.0272 (-151 ns) | 0.0001 |
| `103937` 2 | 94000 / 10000 / 5000 | 94000 / 10000 / 500 | 531.9 | -161.159 | +0.2352 (+131 ns) | 0.0001 |
| `103937` 3 | 48000 / 10000 / 1355 | 94000 / 10000 / 5000 | 282.29 | -131.817 | -0.0003 (-1 ns) | 0.0002 |
| `103937` 4 | 94000 / 9400 / 1355 | 48000 / 10000 / 1355 | 135.5 | +29.951 | -0.0941 (-193 ns) | 0.0001 |
| `105615` 1 | 94000 / 9400 / 500 | 96000 / 10000 / 1355 | 50 | -20.635 | -0.0156 (-86 ns) | 0.0002 |
| `105615` 2 | 94000 / 9400 / 1360 | 94000 / 9400 / 500 | 136 | -16.069 | -0.0179 (-37 ns) | 0.0002 |
| `105615` 3 | 94000 / 9400 / 5000 | 94000 / 9400 / 1360 | 500 | -38.606 | +0.0861 (+48 ns) | 0.0002 |
| `105615` 4 | 94000 / 18800 / 1360 | 94000 / 9400 / 5000 | 272 | -115.584 | +0.0001 (0 ns) | 0.0002 |
| `165441` 1 | 94000 / 9400 / 1360 | 96000 / 10000 / 1355 | 136 | -16.069 | -0.0121 (-25 ns) | 0.0002 |
| `165441` 2 | 94000 / 18800 / 1360 | 94000 / 9400 / 1360 | 272 | -16.069 | -0.0001 (0 ns) | 0.0002 |
| `165441` 3 | 94000 / 9400 / 1360 | 94000 / 18800 / 1360 | 136 | -16.069 | -0.0001 (0 ns) | 0.0002 |
| `165441` 4 | 94000 / 18800 / 1360 | 94000 / 9400 / 1360 | 272 | -16.069 | 0.0000 (0 ns) | 0.0002 |
| `165441` 5 | 94000 / 9400 / 1360 | 94000 / 18800 / 1360 | 136 | -16.069 | -0.0001 (0 ns) | 0.0002 |

- Once settled, the phase scatter is 0.0001-0.0002 deg in every case, whatever the rate, block length, frequency, or whether the block holds a whole number of cycles. There are no steps at block boundaries, even with half a cycle left over per block (135.5).
- The differences in the full-window std (0.0002 to 0.026 deg, as first reported from these runs) all come from a **settling transient**: after a change, the phase starts 25-190 ns (as a time delay) away from its final value and creeps there, settled to 0.0005 deg about 3-4 s into the window, so about 8-10 s after the change. That is about 30 TC, so it is not the demodulation filter; it behaves like a delay between AO and AI that settles after the tasks restart. The size in ns does not depend on f, which is why it looked like more scatter at 5 kHz.
- Changing only `#s` (9400 <-> 18800 at 1360 Hz, four times in `165441`) left the phase unchanged to 0.001 deg with no transient. 7 of the 9 changes of f or Fs had the transient; the two that did not both came from a 5 kHz case.
- The settled absolute phase is reproducible: 94 kHz / 1360 Hz settled at -16.069 deg in six cases across two days, after five different predecessors, except once: right after the 5 kHz case (`105615` 4) it settled at -115.584 deg, 99.5 deg away. Not explained; the 5 kHz predecessor stands out again.
- For measurements: wait about 10 s after changing f or Fs, not just a few TC; changing `#s` alone is safe.
- getResults updated about 10 times a second at 48 kHz x 10000 (289 results in 30 s with 208 ms blocks), but once per block at 94 kHz x 18800 (151-155 in 30 s). Not explained.
- AI2-4 have no signal at f (5-70 uV), so their phase is noise.

## RPC performance

- Small requests take 15.5 ms (p50), and the server handles about 64 requests/s whether 1 or 32 clients are connected: still one request at a time, but **2.5x slower than on the VM** (6 ms, 140 requests/s). 15.5 ms is one tick of the default Windows timer (15.6 ms), so the RPC loop is probably waiting on a timer or timeout whose resolution is coarser on this host than on the VM.
- getAI (0.74 MB, 4 AI) takes 215 ms and getAll (1.34 MB) 373 ms: replies are built at about 3.5 MB/s, a little slower than the VM's 4-5 MB/s.
- getResults updates every 104 ms (p50 108 ms), the block time.
- stop takes 92 ms, start 234 ms, the first new result arrives 361 ms after start. 2 s and 10 s sweeps finish in 3.2 s and 11.2 s.
- Setters: `setREF_TC` read back the old value 3 times in 150 (about 1 in 3 on the VM), `setAO_Amplitude` never.
- 500 connect/request/close cycles: no failures, no handle growth. All non-destructive malformed requests were answered and the server stayed alive.
- `sampling`: getAI 0.2 s / 0.9 s / 1.9 s and getAll 0.4 / 1.6 / 3.2 s at `#s` 10000 / 50000 / 100000; private memory peaked at 1.2 GB at 100000 and getAI lengths were consistent.
