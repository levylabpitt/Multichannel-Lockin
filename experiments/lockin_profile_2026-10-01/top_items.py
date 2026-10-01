import glob, os, re
import numpy as np
from compare import runs, PATH, find

# ---- scaling: per-block cost = a + b * samples_per_block (least squares over the 6 acquiring runs)
acq = [r for r in runs if r["blocks"]]
x = np.array([r["spb"] for r in acq], float)
print(f"{'item':<30}{'a (us)':>9}{'b (us/kS)':>11}{'R^2':>7}   per-block us at spb=" + " ".join(str(int(v)) for v in x))
for label, key, fld in PATH:
    y = np.array([find(r["flat"], key)[fld] / r["blocks"] for r in acq])
    b, a = np.polyfit(x, y, 1); pred = a + b * x
    r2 = 1 - ((y - pred) ** 2).sum() / ((y - y.mean()) ** 2).sum()
    print(f"{label:<30}{a:9.0f}{b*1000:11.0f}{r2:7.3f}   " + " ".join(f"{v:.0f}" for v in y))

# ---- top items by Total Time, excluding waiting, startup and wait-dominated wrappers
WAIT = re.compile(r"DAQmx\.Read\.vi|zmq_recv|Read Message|Wait|Dequeue|Event|Sleep|Timeout|Notifier|Occurrence", re.I)
def wait_inside(name, exp, flat):
    """Time this VI spends in direct callees that are waiting VIs (from the expanded section)."""
    return sum(v["Total Time"] for c, v in exp.get(name, {}).items() if WAIT.search(c))
for r in runs:
    flat, exp = r["flat"], r["exp"]
    rows = []
    for n, v in flat.items():
        if v["# Runs"] <= 3 or WAIT.search(n.split(":")[-1]):
            continue
        w = wait_inside(n, exp, flat)
        rows.append((v["Total Time"] - w, v["Total Time"], w, v["VI Time"], v["# Runs"], v["Average"], v["Longest"], n))
    rows.sort(reverse=True)
    print(f"\n== {r['name']} (window {r['window']:.0f} s, blocks {r['blocks']}) : Total-minus-direct-waits | Total | wait | self | runs | avg | longest")
    for t in rows[:22]:
        print(f"{t[0]:>9} {t[1]:>9} {t[2]:>9} {t[3]:>8} {t[4]:>6} {t[5]:>7} {t[6]:>7}  {t[7]}")
