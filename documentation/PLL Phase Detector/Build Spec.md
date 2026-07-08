# Dedicated PLL Phase Detector — Build Spec

**Target:** LabVIEW 2019, JKI SMO, `levylabpitt/Multichannel-Lockin` (branch `develop`).
**Status:** Not built. Open question resolved (see §2). This document is the
implementation spec; it supersedes the "resolve first" item in the original handoff.

Companion: the original handoff narrative (rationale, TC derivation) and
`PFLL_design_summary.md` for system-level loop topology. **Note:** `PFLL_design_summary.md`
was not found on disk as of 2026-06-29 — confirm it exists before relying on it.

---

## 1. Goal (one paragraph)

Produce **one phase-error value per acquisition buffer** to drive the phase PID, derived
from a **dedicated** quadrature demod with a **short** time constant sized only to reject
the 2f mixer product — not for SNR. This decouples the phase loop from the long
measurement TC (300 ms, n=4) and lets the loop run ~10× faster. The measurement channels
keep their long global TC unchanged.

Signal path:

```
Target (ext-ref AI waveform) ─┬─ Mixer(Target, REF_X) ─→ X_inst ─→ short-TC RC LPF (own state) ─→ X ─┐
                              └─ Mixer(Target, REF_Y) ─→ Y_inst ─→ short-TC RC LPF (own state) ─→ Y ─┤
                                                                                                      │
                                                       atan2(Y, X) · 180/π ─→ phase error [deg] ──────┘
                                                       (take last filtered sample; no decimator)
```

`Target` = the AI channel carrying the strong external reference.
`REF_X` / `REF_Y` = the NCO in-phase / quadrature waveforms (see §2).

---

## 2. Resolved open question — quadrature source

**Decision: synthesize the cosine companion from the NCO phase accumulator. Do NOT use the
Hilbert chain.**

Evidence (from `Generator/Generate Reference Waveforms.vi`): the VI already builds **both**
quadratures from the *same* phase accumulator — one "Sine Wave" block driven by the
accumulated `phase`, and a second driven by the same `phase` **+ a `90°` constant** — and
publishes them as **`REF_X`** (in-phase / sin) and **`REF_Y`** (quadrature / cos). Both
share `t0`, `Frequency`, and the `Phase` accumulator.

Consequence: the quadrature pair is already available as waveforms. The Hilbert chain
stays unwired.

---

## 3. VI inventory (reuse — exact paths, roles, terminals)

All paths under `src/`. Terminal names taken from each VI's connector pane.

### Quadrature source
| VI | Role | Key terminals |
|----|------|----|
| `Generator/Generate Reference Waveforms.vi` | NCO; emits both quadratures | out: `REF_X`, `REF_Y`, `phase out`, `phase reset` |

### Mixer (reuse as-is — already dual-phase)
| VI | Role | Key terminals |
|----|------|----|
| `DSP/Mixer subVI.vi` | **Single-channel core.** Computes `Signal × Reference × 2` (the ×2 normalizes the ½ from the product-to-sum identity, per its own diagram comment). | in: `Signal in`, `Reference in`; out: `Signal*Reference out` |
| `DSP/Lockin.Mixer.vi` | Full bank. For each AI channel computes `AI×Ref_X→Waveforms.X` **and** `AI×Ref_Y→Waveforms.Y`. Already produces both projections — nothing to add. | DSP-class wire; consumes `Configuration.AI Channels`, `Waveforms.AI`, `Waveforms.Ref_X`, `Waveforms.Ref_Y`; produces `Waveforms.X`, `Waveforms.Y` |

> The detector mixes only **one** signal (Target), so prefer the lightweight
> `Mixer subVI.vi` called twice (once with `REF_X`, once with `REF_Y`). Reaching for the
> full `Lockin.Mixer.vi` drags in the whole channel-bank/config machinery.

### Cascaded-RC low-pass (reuse coefficients + apply; give it its OWN state — see §5)
| VI | Role | Key terminals |
|----|------|----|
| `DSP/Cascaded RC Filter Coefficients.vi` | Computes n-stage RC IIR coefficients (`α = 1 − exp(−1/(Fs·TC))` per stage). | — |
| `DSP/Create Low Pass RC Filter (FGV).vi` | Builds the cascaded-RC **IIR Filter Cluster** from TC/stages/Fs. | in: `init [F]`, `stages` (def **4**), `time constant (s)`, `error in`, `fs (Hz)`; out: `init out`, `IIR Filters`, `error out` |
| `DSP/Initialize Filter State.vi` | Manages warm/cold filter state inside the IIR Filter Cluster. `init=TRUE` re-settles, `init=FALSE` keeps state. | in: `IIR Filter Cluster`, `init (F)`, `Filter State in`; out: `IIR Filter Cluster`, `reset?`, `Filter State out` |
| `DSP/Lockin.Low Pass Filter (subVI).vi` | Per-channel apply used by the measurement path; state stored in the DSP object, indexed by `Element Data`. Reference for the apply node + Fc computation (`Fc = 1/(2π·TC)`). | in: `DSP in`, `signal in`, `Element Data` (I32), `error in`, `Butterworth? [T]`; out: `DSP out`, `signal out`, `Fc (Hz)`, `error out` |
| `DSP/Lockin.Low Pass Filter.vi` | Bank wrapper: separate in-phase/out-of-phase RC filters on X/Y, gated by `RC filter` bool. | DSP wire; `Waveforms.X/Y` in/out |

### TC / settling helpers
| VI | Role |
|----|------|
| `DSP/Calculate 3dB RC.vi` | 3 dB bandwidth from TC/n |
| `DSP/Calculate ENBW RC.vi` | equivalent noise bandwidth |
| `DSP/Calculate t_settle RC.vi` | settling time from TC/n (use for loop-lag budgeting) |

### Loop side (for the §8 retune, not the detector itself)
| VI | Role |
|----|------|
| `DSP/PLL_PID.vi` | phase PID |
| `DSP/FLL_PID.vi` | frequency PID (provides `f` for adaptive TC) |
| `DSP/Wrap Phase.vi` | phase wrap |
| `Instrument.DAQ/support/PLL/PLL.vi` | current PLL/FLL container; where the detector output replaces the measurement-TC θ |

### Do NOT use here
- The Hilbert chain (unwired; superseded by §2).
- The decimator (`DSP/Decimate DFD (*).vi`, `Instrument UI.Lockin/private/Decimate Waveforms.vi`) — the loop consumes one number/buffer; no decimation, and this deliberately sidesteps the global-M empty-array gating.

---

## 4. New VI — connector-level wiring

Create **`Instrument.DAQ/support/PLL/PLL Phase Detector.vi`** (or `Generator/PLL/…` if the
detector lives on the Generator side — place it wherever the PLL process loop runs).

### Connector pane

Inputs:
- `Target` — 1 waveform (the external-ref AI channel for this buffer)
- `REF_X` — 1 waveform (NCO sin)
- `REF_Y` — 1 waveform (NCO cos)
- `Fs` — DBL (Hz), from `Configuration.Timing.Sampling.Fs`
- `f` — DBL (Hz), current reference frequency from the FLL (drives adaptive TC)
- `k` — DBL, TC scaling constant (rejection target; see §6). Default 0.447 (~60 dB).
- `reset?` — Bool (settle filter state; assert on lock-start / large f-jump)
- `error in`

Outputs:
- `phase error [deg]` — DBL in (−180, 180]
- `X`, `Y` — DBL (optional, for monitoring/ripple checks)
- `error out`

### Internal dataflow (left → right)

1. **Adaptive TC:** `TC = k / f`. (Clamp `f` away from 0 to avoid divide-by-zero on
   startup; fall back to a default TC until the FLL locks.)
2. **Coefficients:** `Create Low Pass RC Filter (FGV).vi` with `stages=4`,
   `time constant (s)=TC`, `fs=Fs`. Recompute when `f` (hence TC) changes; cheap enough to
   call per buffer. Wire `init [F]` from `reset?`.
3. **Mix (two calls to `Mixer subVI.vi`):**
   - `Mixer subVI.vi`: `Signal in←Target`, `Reference in←REF_X` → `X_inst`
   - `Mixer subVI.vi`: `Signal in←Target`, `Reference in←REF_Y` → `Y_inst`
4. **Filter each quadrature through the cascaded-RC apply with PERSISTENT state** (§5):
   - X branch: IIR-apply(`X_inst`, coeffs_X, stateX) → `X_filt`; persist stateX
   - Y branch: IIR-apply(`Y_inst`, coeffs_Y, stateY) → `Y_filt`; persist stateY
5. **Representative sample:** take the **last** element of `X_filt` and `Y_filt`
   (one value per buffer). Output as `X`, `Y`.
6. **`atan2`:** `phase error [deg] = atan2(Y, X) · 180/π`. Amplitude-independent; native
   range (−180, 180] matches the PLL wrap.

---

## 5. Persistent filter state — the crux (get this right)

**How the measurement path does it:** filter state is carried as data in an
**IIR Filter Cluster** (the `Filter State` element of the cluster, managed by
`Initialize Filter State.vi`). `Lockin.Low Pass Filter (subVI).vi` stores that cluster
**in the DSP class object** (`DSP in → DSP out`), indexed per channel by `Element Data`,
and threads the object through the loop's shift register. `init=FALSE` preserves state
across buffers; `init=TRUE` re-settles.

**What the detector must do:** keep its **own** state, independent of the measurement DSP
object, so the two TCs never collide. Recommended (self-contained, matches the handoff's
"feedback-node pattern like the decimator"):

- Hold **two uninitialized shift registers** in the detector VI (or its enclosing PLL
  loop) — one IIR Filter Cluster for X, one for Y.
- Per buffer: pass the stored cluster in as `Filter State in`, run the cascaded-RC apply,
  store `Filter State out` back into the shift register.
- Drive `init (F)` of `Initialize Filter State.vi` from `reset?`:
  **TRUE only on lock-start (or large f-jump); FALSE on every subsequent buffer.**
- Do **not** route the detector through the measurement `Lockin.Low Pass Filter.vi` /
  shared DSP object — that path owns the 300 ms state and the wrong init cadence.

> Changing TC (adaptive `k/f`) updates the coefficients but should **not** reset the state
> — leave the running `y` values in place; the coefficient change is a small, acceptable
> transient. Only `reset?` clears state.

> If `Create Low Pass RC Filter (FGV).vi` is non-reentrant (it is an FGV), its `init out`
> bookkeeping is global and shared with the measurement path. It only **builds
> coefficients** from its inputs, so this is fine as long as the detector keeps its own
> *Filter State* cluster (above). If in doubt, mark a clone reentrant or compute
> coefficients with `Cascaded RC Filter Coefficients.vi` directly.

### Equivalent lightweight alternative
The cascaded RC is mathematically `y += α·(x − y)`, `α = 1 − exp(−1/(Fs·TC))`, applied n=4
times in series. If you prefer not to carry IIR clusters, implement directly with a
feedback node holding 4 state doubles per quadrature (8 total). Same result; fewer moving
parts. Use `Cascaded RC Filter Coefficients.vi` for α to keep the math identical to the
verified code.

---

## 6. Adaptive TC = k/f table (n = 4)

For n=4 cascaded RC stages, to reach 2f-rejection factor `R`:

```
TC ≈ R^(−1/4) / (4π · f)   ⇒   TC = k / f,   k = R^(−1/4) / (4π)
```

| 2f rejection | R     | R^(−1/4) | **k** (= TC·f) |
|--------------|-------|----------|----------------|
| ~40 dB       | 1e−2  | 3.16     | **0.252**      |
| ~60 dB       | 1e−3  | 5.62     | **0.447**      |
| ~80 dB       | 1e−4  | 10.0     | **0.796**      |

Resulting TC at representative frequencies (k = 0.447, ~60 dB):

| f (Hz) | TC = k/f  | t_settle = 10.05·TC |
|--------|-----------|---------------------|
| 1      | 447 ms    | 4.49 s              |
| 14     | **32 ms** | **321 ms**          |
| 100    | 4.5 ms    | 45 ms               |
| 1000   | 0.45 ms   | 4.5 ms              |

Pick `k` so the 2f-induced phase ripple sits ~10× below the lock tolerance, then stop.
Low f needs the longest TC → it sets the slowest phase-loop response; size the PID retune
(§8) against the **t_settle at the lowest operating frequency**, not at 14 Hz. Once the
FLL reports `f`, set `TC = k/f` to hold constant 2f rejection across the range.

Settling formula: `t_settle = 10.05 · TC` for n=4 (or call `Calculate t_settle RC.vi`).

---

## 7. atan2 / wrap / lock-point notes

- `atan2(Y, X)` yields (−180, 180]; amplitude-independent — no normalization needed.
- **Verify the lock point is interior**, not on the ±180 wrap boundary (Round-to-Nearest
  wrap). Lock near 0° is safe. If a hardware phase offset lands it near ±180°, move it off
  the boundary via the phase **setpoint** (e.g. 90°), not by re-wrapping.
- Reuse `DSP/Wrap Phase.vi` on the loop side for consistency with the existing PLL.

---

## 8. Phase-PID retune (after the detector is wired)

The detector's settling is ~10× shorter than the measurement TC, so the phase loop's
bandwidth ceiling moved up ~10×. **The old gains are invalid.**

- Retune from scratch; start gentle and raise gain toward the new ceiling.
- **No derivative term** — the loop is delay-dominated (filter settling = transport lag);
  D amplifies that.
- Budget the loop bandwidth against `t_settle` at the **lowest** operating frequency
  (longest TC), since that is the worst-case lag.
- Tune at a representative `f` first, then confirm stability across the full sweep range
  (TC and therefore lag change with `f`).
- `DSP/PLL_PID.vi` is the PID; `Instrument.DAQ/support/PLL/PLL.vi` is where the detector's
  `phase error` replaces the measurement-TC θ as the process variable.

---

## 9. Verification checklist

1. **Open-loop ripple:** with the loop open, confirm the phase-error ripple at 2f is well
   below the lock tolerance, and that it tracks the filter math for the chosen `k`
   (e.g. at 14 Hz / 60 dB the old 300 ms/n=4 measurement path gave ~5e−7°; the short TC
   will be larger but should still be comfortably sub-tolerance).
2. **State persistence:** confirm the filter does **not** re-settle each buffer — step the
   input and watch the response span multiple buffers (no per-buffer discontinuity).
3. **Amplitude independence:** scale `Target` amplitude; `phase error` must not move.
4. **Interior lock point:** confirm steady-state phase sits away from ±180°.
5. **Closed-loop:** with retuned gains, confirm faster lock acquisition than the old
   measurement-TC loop, no derivative-driven ringing, stable across the sweep range.

---

## 10. Open items / references

- `PFLL_design_summary.md` (referenced by the handoff for full loop topology) **was not
  found** anywhere under Dropbox/Documents as of 2026-06-29. Locate or author it before
  relying on system-level design claims.
- `reference/PLL_LV2012_NI Verified/` in the repo is almost certainly NI's reference PLL
  the existing `PLL.vi` was modeled on — useful for the §8 retune.
- VI block-diagram renders used to write this spec live at
  `C:\Users\ansom\Documents\Multichannel-Lockin-VI-Index` (regenerate with the
  `labview-vi-index` skill if VIs change).
