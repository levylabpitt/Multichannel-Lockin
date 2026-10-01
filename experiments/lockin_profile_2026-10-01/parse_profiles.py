"""Parse LabVIEW Profile Performance and Memory dumps (tab-delimited .txt).

Each file has a flat section (one row per VI, VI Time = self time) followed by an
"Expanded VI Data:" section (caller rows, with "-->" callee rows giving the time
spent in that callee when called from that caller). Times are microseconds.
"""
import re, sys, glob, os, json
from datetime import datetime

COLS = ["VI Time", "Sub VIs Time", "Total Time", "# Runs", "Average", "Shortest", "Longest"]

def parse(path):
    lines = open(path, encoding="latin-1").read().splitlines()
    hdr = {}
    for l in lines[:6]:
        m = re.match(r"(Begin|End): \w+, (.*)\.$", l)
        if m:
            hdr[m.group(1)] = datetime.strptime(m.group(2), "%b %d, %Y %I:%M:%S %p")
    # A call already in progress when the profiler starts can be recorded with a
    # bogus duration (seen: ~8e10 us in an 8 s window). Drop such a call: it is
    # the Longest, so subtract it once and decrement # Runs. Shortest stays valid;
    # the corrected Longest is unknown and is set to -1.
    limit_us = ((hdr["End"] - hdr["Begin"]).total_seconds() + 2) * 1e6 if len(hdr) == 2 else None
    def drop_bogus(v):
        if limit_us and v["# Runs"] > 1 and v["Longest"] > limit_us:
            for k in ("VI Time", "Total Time"):
                v[k] -= v["Longest"]
            v["VI Time"] = max(v["VI Time"], 0)
            v["# Runs"] -= 1
            v["Average"] = v["VI Time"] // v["# Runs"]  # LabVIEW Average is self time per call
            v["Longest"] = -1
            v["dropped_bogus_call"] = True
        return v
    flat, expanded, section, caller = {}, {}, "flat", None
    for l in lines:
        if l.startswith("Expanded VI Data"):
            section = "exp"; continue
        f = l.split("\t")
        if len(f) < 8 or not f[1].strip().isdigit():
            continue
        name = f[0]
        v = drop_bogus(dict(zip(COLS, (int(x) for x in f[1:8]))))
        if section == "flat":
            # reentrant clones can appear as separate rows; sum them under one name
            base = re.sub(r":Instance:[0-9a-f-]+\.vi$", "", name)
            if base in flat:
                a = flat[base]
                for k in ("VI Time", "Sub VIs Time", "Total Time", "# Runs"):
                    a[k] += v[k]
                a["Longest"] = max(a["Longest"], v["Longest"])
                a["Shortest"] = min(a["Shortest"], v["Shortest"]) if a["# Runs"] else v["Shortest"]
                a["Average"] = a["VI Time"] // a["# Runs"] if a["# Runs"] else 0
            else:
                flat[base] = v
        else:
            if name.startswith("-->"):
                if caller is not None:
                    expanded.setdefault(caller, {})[name[3:]] = v
            else:
                caller = name
    return hdr, flat, expanded

def find(flat, key):
    """Exact match on the part after the last ':' class qualifier, else substring."""
    hits = [n for n in flat if n.endswith(key)]
    if len(hits) != 1:
        hits = [n for n in hits if flat[n]["# Runs"]] or hits
    if len(hits) != 1:
        raise KeyError(f"{key}: {hits}")
    return flat[hits[0]]

if __name__ == "__main__":
    folder = os.path.dirname(os.path.abspath(__file__))
    out = {}
    for p in sorted(glob.glob(os.path.join(folder, "profile_*.txt"))):
        hdr, flat, exp = parse(p)
        out[os.path.basename(p)] = dict(hdr={k: str(v) for k, v in hdr.items()}, flat=flat, expanded=exp)
    json.dump(out, open(os.path.join(folder, "profiles.json"), "w"), indent=0)
    print("parsed", len(out), "files")
