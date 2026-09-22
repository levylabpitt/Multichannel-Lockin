# Issue #5 - external reference (PLL / FLL): status and Generator audit

Audited 2026-09-21 on `Feature/Issue_160`. Read with lvkit and checked against LabVIEW's own block-diagram export for every claim marked (LV).

## Why #5 is still open

It is not finished. A complete signal chain exists and is wired into the live DAQ process, but it can only be switched on from debug front panels, and the phase loop as designed would not stay locked.

## What exists

`Macro: DSP` (every waveform block) -> `DSP: Phase` -> `PLL.vi` -> `FLL_PID.vi` and/or `PLL_PID.vi` -> new frequency / phase written into **REF channel 0** -> `DAQ.setREF.vi` -> private `setREF` event -> Generator stores it -> used from the next generated block.

| Piece | Location | What it does |
|---|---|---|
| Enable | `Instrument.DAQ/Process.vi`, state `DSP: Phase` | runs `PLL.vi` when the front-panel boolean **`Auto Phase`** is true |
| `PLL.vi` | `src/Instrument.DAQ/support/PLL/` | loads DSP with the current waveforms and config; runs FLL if `FLL`, PLL if `PLL`; writes REF[0] frequency and phase; calls `DAQ.setREF.vi` |
| `FLL_PID.vi` | `src/DSP/` | measures the frequency of **AI0** and of **Ref_X0** with `Extract Single Tone`; PID (setpoint = AI0 frequency, process = Ref_X0 frequency, output +/-1 Hz); new REF frequency = AI0 frequency + PID output (LV) |
| `PLL_PID.vi` | `src/DSP/` | mixes AI0 with Ref_X0 / Ref_Y0, 4th-order low-pass, atan2 -> phase error in degrees; PID with setpoint 0, output +/-360 deg, wrapped; writes the result as REF[0] **phase** (LV) |
| Experiments | `experiments/PLL/`, `src/Instrument.DAQ/Tests/Test PLL.vi` | prototypes |

## Blocking: why it cannot be used today

1. **`Auto Phase`** is a front-panel control on `Instrument.DAQ/Process.vi`. There is no API method, JSON command, UI control or saved configuration for it.
2. **`FLL` and `PLL`** are front-panel controls on `PLL.vi`, not on its connector pane, and both default to **False** (LV). Called as a subVI, both loops are always off.
3. With `Auto Phase` on and both loops off, `PLL.vi` reads REF[0] and writes the same values back through `DAQ.setREF.vi` on **every DSP block**: about 10 events per second that change nothing.
4. Hard-coded: the external reference must be on **AI0**, and only **REF0** is steered.
5. No lock indicator, lock-lost handling, or published status.

## Design problems that would stop it locking

6. **`PLL_PID.vi` is a phase-only loop.** Its PI output *is* the REF phase, clamped to +/-360 deg and wrapped. Any residual frequency error gives a steadily drifting phase, the integrator winds up to the clamp, and lock is lost. Standard fix: phase error -> PI -> **frequency correction** (Hz) added to the REF frequency. The Generator already accumulates phase between blocks (G3), so steering frequency is naturally phase-continuous, and the FLL becomes an acquisition aid rather than a second loop fighting the first.
7. **`FLL_PID.vi` overwrites its own gains.** Every call writes computed gains (Kc = 0.6, Ti = 60 x dt, Td = Ti / 4) into a local of the `PID gains (Frequency)` control that feeds the PID (LV), so that control has no effect. Ti goes into an input in **minutes**, so 60 x dt minutes is 3600 blocks and the integral term is effectively off. Probably meant 60 x dt **seconds**.
8. `FLL_PID.vi`'s "process" frequency is estimated from Ref_X, i.e. the reference it just set. Setting REF frequency directly to the smoothed measured AI0 frequency does the same job with no loop dynamics.
9. Both estimators use a circular buffer of `1 x #samples`, i.e. only the current block. The `1` looks like a placeholder for an averaging length.
10. Both loop VIs update front-panel charts and use property nodes on every call, inside the DSP path.
11. Loop delay is about two blocks (DSP measures block n, the Generator applies it to the next block it generates, G1). Tune gains for that delay.
12. **Packaging.** `FLL_PID.vi` needs `vi.lib/PRIrvin` XY Utilities (`Circular Buffer`) and the NI PID toolkit (`vi.lib/addons/control/pid`); `PLL_PID.vi` needs the PID toolkit. Through `PLL.vi` both are already linked into `Instrument.DAQ/Process.vi`, so they ship in the API package, but the `.vipb` declares only `levylab_lib_instrument_type` and `levylab_lib_levylab_instruments`, and the `.vipc` lists no packages. The exe bundles them; a VIPM install on a machine without them will have broken VIs.

## Generator findings

| # | Finding | Consequence |
|---|---|---|
| G1 | The Generator only generates when the AO waveform queue has **0 elements** (Timeout -> `GetQueueStatus` -> `In Range and Coerce` 0..0 -> `Generator: Generate`). The queue never holds more than one block ahead. | Any buffer deeper than 1 cannot fill. **#160 item C1 (min buffer > 1) would stall `DAQ: START`**: it waits for a second block that never comes, then error 123 after 5 s. C1 needs a matching Generator change (generate while count < target). Also relevant to how often -200621 happens: the software lead is at most one block. |
| G2 | That generation is triggered from the event structure's **Timeout**, wired from a front-panel control `timeout (ms)`, default **10** (LV). | A Timeout only fires after 10 ms with no other event. Any event stream faster than that starves generation. Fine at current rates, fragile, and the saved control default is the real setting. |
| G3 | `Generate Reference Waveforms.vi` is **phase-continuous**: uninitialized shift registers carry the last phase between calls, and phase setpoint changes are applied as deltas (LV). A frequency change does **not** reset phase: the "REF frequency or phase changed?" result is OR'd with `reset phase`, but the OR output is unwired (LV). | Good for a PLL. The OR and the `Is Reference Changed.vi` call are dead code; remove them or wire the intent. |
| G4 | `REF.Channel--Cluster.ctl` exists three times (Generator, DSP, Instrument.DAQ). | Drift risk. Not compared. |

Not audited: AO waveform generation (`Generate AO Waveforms.vi`), sweeps (`Sweep/`), staircase and chirp.

## To finish #5 (proposed order)

1. **Decide scope.** Does the external reference steer only the demodulation references, or the AO outputs too? This decides whether `Generate AO Waveforms.vi` joins in.
2. **Expose it.** Configuration fields (enable, AI channel, REF channel(s)), an API method, a UI control, and a published lock status. Remove the dependence on `Auto Phase` and on `PLL.vi`'s front panel.
3. **Rebuild the loop** as in item 6: measured frequency for acquisition, then a phase detector driving a frequency correction. Fix item 7 if FLL_PID survives.
4. **Stop the event churn**: only call `DAQ.setREF.vi` when the value actually changes, or write REF from the DSP path without a round trip through the event system.
5. Move diagnostics out of the DSP path (item 10).
6. Declare or remove the package dependencies (item 12).
7. Test with a known external tone on AI0 at an offset from the REF frequency, and verify pull-in range, lock time and phase noise.
