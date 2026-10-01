import re, os, glob
from parse_profiles import parse, find

folder = os.path.dirname(os.path.abspath(__file__))
def runkey(p):
    m = re.search(r"_(\d+)Ss_(\d+)S", p)
    return (int(m.group(1)), int(m.group(2))) if m else (0, 0)
files = sorted(glob.glob(os.path.join(folder, "profile_*.txt")), key=runkey)

PATH = [  # (label, name suffix, field)
    ("Instrument.DAQ:Lockin.Engine", "Instrument.DAQ.lvclass:Lockin.Engine.vi", "Total Time"),
    ("DSP:Lockin.Engine", "DSP.lvclass:Lockin.Engine.vi", "Total Time"),
    ("Lockin.Mixer", "DSP.lvclass:Lockin.Mixer.vi", "Total Time"),
    ("Lockin.Low Pass Filter", "DSP.lvclass:Lockin.Low Pass Filter.vi", "Total Time"),
    ("Lockin.Low Pass Filter Bank", "DSP.lvclass:Lockin.Low Pass Filter Bank.vi", "Total Time"),
    ("DFD Filter Array", "DSP.lvclass:DFD Filter Array.vi", "Total Time"),
    ("Resample", "DSP.lvclass:Resample.vi", "Total Time"),
    ("Prefilter", "Instrument.DAQ.lvclass:Prefilter.vi", "Total Time"),
    ("DAQmx.Write", "DAQmx.lvclass:DAQmx.Write.vi", "Total Time"),
    ("Sync.Acquire (self)", "DAQmx.lvclass:Sync.Acquire.vi", "VI Time"),
]
LONG = [("DAQmx.Write", "DAQmx.lvclass:DAQmx.Write.vi"), ("Sync.Acquire", "DAQmx.lvclass:Sync.Acquire.vi"),
        ("Generate Waveforms", "Generator.lvclass:Generate Waveforms.vi"),
        ("Generator.GetQueueStatus", "Generator.lvclass:Generator.GetQueueStatus.vi"),
        ("Periodic Trigger__ogtk", "Periodic Trigger__ogtk.vi")]
UI = [("Parse Results Array (all)", "Instrument.Lockin.lvclass:Parse Results Array (all).vi"),
      ("Dictionary to Chart", "Instrument UI.Lockin.lvclass:Dictionary to Chart.vi"),
      ("Parse Results (table)", "Instrument UI.Lockin.lvclass:Parse Results (table).vi")]

runs = []
for p in files:
    hdr, flat, exp = parse(p)
    rate, spb = runkey(p)
    rd = find(flat, "DAQmx.lvclass:DAQmx.Read.vi")
    r = dict(name=os.path.basename(p)[8:-4], rate=rate, spb=spb, flat=flat, exp=exp,
             window=(hdr["End"] - hdr["Begin"]).total_seconds(),
             dur=rd["Total Time"] / 1e6, blocks=rd["# Runs"],
             period_ms=(spb / rate * 1e3) if rate else None,
             read_avg=rd["Average"] / 1e3)
    runs.append(r)

def row(label, vals, fmt="{:>10}"):
    print(f"{label:<34}" + "".join(fmt.format(v) for v in vals))

def f1(x, d=1): return "-" if x is None else f"{x:.{d}f}"

row("run", [r["name"] for r in runs], "{:>16}")
W = "{:>16}"
row("samples/block", [r["spb"] for r in runs], W)
row("block period (ms) = spb/rate", [f1(r["period_ms"]) for r in runs], W)
row("profiler window (s, 1 s res.)", [f1(r["window"], 0) for r in runs], W)
row("run duration = Read total (s)", [f1(r["dur"], 2) for r in runs], W)
row("blocks (Read # runs)", [r["blocks"] for r in runs], W)
row("Read avg wait (ms)", [f1(r["read_avg"]) for r in runs], W)

print("\n-- per-block cost (us/block = Total / blocks) --")
work = {}
for label, key, fld in PATH:
    vals = []
    for r in runs:
        v = find(r["flat"], key)
        pb = v[fld] / r["blocks"] if r["blocks"] else None
        vals.append(pb); work.setdefault(r["name"], {})[label] = pb
    row(label, [f1(x, 0) for x in vals], W)
row("  calls/block LPF Bank", [f1(find(r["flat"], PATH[4][1])["# Runs"] / r["blocks"], 2) if r["blocks"] else "-" for r in runs], W)
row("  calls/block DFD Filter Array", [f1(find(r["flat"], PATH[5][1])["# Runs"] / r["blocks"], 2) if r["blocks"] else "-" for r in runs], W)

print("\n-- per-block cost as % of block period --")
for label, key, fld in PATH:
    vals = []
    for r in runs:
        pb = work[r["name"]][label]
        vals.append(None if pb is None or not r["period_ms"] else 100 * pb / (r["period_ms"] * 1e3))
    row(label, [f1(x, 2) for x in vals], W)

print("\n-- Longest (ms) / Average (ms) / # Runs --")
for label, key in LONG:
    row(label, [f"{find(r['flat'], key)['Longest']/1e3:.1f}/{find(r['flat'], key)['Average']/1e3:.2f}/{find(r['flat'], key)['# Runs']}" for r in runs], W)

print("\n-- UI/parse: us per block (Total/blocks); [us/call x calls] --")
for label, key in UI:
    vals = []
    for r in runs:
        v = find(r["flat"], key)
        vals.append((f"{v['Total Time']/r['blocks']:.0f}" if r["blocks"] else f"{v['Total Time']/r['window']:.0f}/s")
                    + f" [{v['Average']}x{v['# Runs']}]")
    row(label, vals, "{:>22}")

print("\n-- Sync.Acquire callees (us/call) --")
for r in runs:
    e = r["exp"].get("DAQmx.lvclass:Sync.Acquire.vi", {})
    print(r["name"], {k.split(':')[-1]: (v["Average"], v["# Runs"]) for k, v in e.items() if v["# Runs"]})
