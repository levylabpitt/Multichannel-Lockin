# /// script
# requires-python = ">=3.11"
# dependencies = ["pyzmq>=26", "psutil>=6", "matplotlib>=3.8"]
# ///
"""Stress, performance, CPU and memory tests against a running Multichannel Lockin.exe (JSON-RPC over ZMQ).

    uv run Tests/stress/lockin_stress.py                  # default phases (see DEFAULT)
    uv run Tests/stress/lockin_stress.py profile soak     # just these phases
    uv run Tests/stress/lockin_stress.py soak --soak-min 60

The exe's process is sampled once a second the whole time (CPU, RSS, private bytes, handles, threads).
Sampling, AO, REF, link frequency and state are snapshotted first and restored at the end.
Results go to Tests/stress/results/<setup>/<date>_<firmware>/, where <setup> names the computer and DAQ hardware
(default <COMPUTERNAME>_<DAQ devices>, or --setup): summary JSON, monitor CSV and a PNG per run.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import glob
import json
import os
import random
import platform
import statistics
import subprocess
import sys
import threading
import time
from pathlib import Path

import psutil
import zmq

ADDR = "tcp://localhost:29170"
EXE = "Multichannel Lockin.exe"
HERE = Path(__file__).resolve().parent
ERROR_LOGS = Path(os.path.expandvars(r"%LOCALAPPDATA%\LevyLab\Error Logs\Multichannel-Lockin"))
CORES = psutil.cpu_count()

DEFAULT = ["profile", "blocksize", "latency", "freshness", "concurrency", "setters", "state", "sweep", "churn",
           "soak"]
OPT_IN = ["grid", "phase", "sampling", "overrun", "torn", "robustness"]  # reconfigure hard, or can stop acquisition


class RpcError(Exception):
    pass


class Client:
    """Minimal JSON-RPC 2.0 REQ client (same wire format as the Instrument Framework)."""

    def __init__(self, address: str = ADDR, timeout: float = 30.0, context: zmq.Context | None = None):
        self.address, self.timeout = address, timeout
        self._ctx = context or zmq.Context.instance()
        self._sock: zmq.Socket | None = None
        self._id = 0
        self._lock = threading.Lock()

    def call(self, method: str, params=None):
        with self._lock:
            self._id += 1
            req = {"jsonrpc": "2.0", "method": method, "params": {} if params is None else params, "id": str(self._id)}
            if self._sock is None:
                s = self._ctx.socket(zmq.REQ)
                s.setsockopt(zmq.LINGER, 0)
                s.setsockopt(zmq.RCVTIMEO, int(self.timeout * 1000))
                s.setsockopt(zmq.SNDTIMEO, int(self.timeout * 1000))
                s.connect(self.address)
                self._sock = s
            try:
                self._sock.send_string(json.dumps(req))
                reply = json.loads(self._sock.recv_string())
            except zmq.Again as err:
                self.close_unlocked()
                raise TimeoutError(f"no reply to {method} within {self.timeout} s") from err
        if "error" in reply:
            raise RpcError(f"{method}: {reply['error']}")
        return reply.get("result")

    def close_unlocked(self):
        if self._sock is not None:
            self._sock.close(0)
            self._sock = None

    def close(self):
        with self._lock:
            self.close_unlocked()


# --- helpers ---------------------------------------------------------------------------------------


def host_info() -> dict:
    """The computer and the DAQ devices Windows sees (real devices only; simulated ones are not PnP devices)."""
    ps = ("$c = Get-CimInstance Win32_ComputerSystem; [pscustomobject]@{"
          "cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name.Trim(); "
          "model = \"$($c.Manufacturer) $($c.Model)\"; hypervisor_present = $c.HypervisorPresent; "
          "daq = @(Get-PnpDevice -PresentOnly -Class DAQDevice -EA SilentlyContinue | ForEach-Object FriendlyName)"
          "} | ConvertTo-Json")
    try:
        info = json.loads(subprocess.run(["powershell", "-NoProfile", "-Command", ps], capture_output=True,
                                         text=True, timeout=60).stdout)
    except (OSError, ValueError, subprocess.TimeoutExpired):
        info = {"daq": []}
    return dict(name=platform.node(), os=platform.platform(), cores=CORES,
                physical_cores=psutil.cpu_count(logical=False),
                ram_gb=round(psutil.virtual_memory().total / 1e9, 1), **info)


def default_setup(host: dict) -> str:
    return "_".join([host["name"]] + sorted(set(host.get("daq") or [])))


def log(*a):
    print(*a, flush=True)


def proc() -> psutil.Process:
    return next(p for p in psutil.process_iter(["name"]) if p.info["name"] == EXE)


def stats(xs: list[float]) -> dict:
    if not xs:
        return {}
    s = sorted(xs)
    q = lambda f: s[min(len(s) - 1, int(f * len(s)))]  # noqa: E731
    return dict(n=len(s), mean=round(statistics.mean(s), 2), p50=round(q(0.5), 2), p95=round(q(0.95), 2),
                p99=round(q(0.99), 2), max=round(s[-1], 2))


def timed(c: Client, method: str, params=None):
    t = time.perf_counter()
    r = c.call(method, params)
    return (time.perf_counter() - t) * 1e3, r


def slope_per_min(ts: list[float], ys: list[float]) -> float:
    """Least-squares slope, units per minute."""
    if len(ts) < 3:
        return 0.0
    mt, my = statistics.mean(ts), statistics.mean(ys)
    den = sum((t - mt) ** 2 for t in ts)
    return 0.0 if den == 0 else 60 * sum((t - mt) * (y - my) for t, y in zip(ts, ys)) / den


def overrun_count() -> int:
    """-200279 read errors logged by the exe today (each is logged 3x, once per layer)."""
    files = glob.glob(str(ERROR_LOGS / "*Errors.txt"))
    if not files:
        return 0
    return open(max(files, key=os.path.getmtime), "rb").read().count(b"-200279\tError -200279 occurred at DAQmx") // 3


def error_log() -> Path | None:
    files = glob.glob(str(ERROR_LOGS / "*Errors.txt"))
    return Path(max(files, key=os.path.getmtime)) if files else None


def log_mark() -> tuple[Path | None, int]:
    f = error_log()
    return f, f.stat().st_size if f else 0


def errors_since(mark: tuple[Path | None, int]) -> dict[str, int]:
    """Error codes the exe logged since `mark`, counted once per occurrence (each is logged by 3 layers)."""
    f, pos = mark
    if f is None or error_log() != f:
        f, pos = error_log(), 0
    if f is None:
        return {}
    with open(f, "rb") as fh:
        fh.seek(pos)
        text = fh.read().decode(errors="replace")
    codes: dict[str, int] = {}
    for line in text.splitlines():
        parts = line.split("\t")
        if len(parts) > 4 and parts[0][:2] == "20" and parts[2] == "Err":
            codes[parts[4]] = codes.get(parts[4], 0) + 1
    return {k: max(1, v // 3) for k, v in codes.items()}


def ensure_started(c: Client, wait: float = 2.0):
    if c.call("getState") != "started":
        c.call("setState", {"State": "start"})
        time.sleep(wait)


def set_samples(c: Client, ns: int, fs: float, settle: float = 3.0):
    c.call("setSampling", {"Fs": fs, "#s": ns})
    time.sleep(settle)
    ensure_started(c)


class Monitor(threading.Thread):
    """Samples the exe once a second. `mark` labels samples with the current phase/scenario."""

    def __init__(self, p: psutil.Process, period: float = 1.0):
        super().__init__(daemon=True)
        self.p, self.period, self.samples, self.stop_ev, self.mark = p, period, [], threading.Event(), ""
        self.t0 = time.time()
        self.p.cpu_percent(None)
        psutil.cpu_percent(None)

    def run(self):
        while not self.stop_ev.wait(self.period):
            try:
                m = self.p.memory_info()
                self.samples.append(dict(
                    t=round(time.time() - self.t0, 1), phase=self.mark, rss_mb=round(m.rss / 1e6, 1),
                    private_mb=round(m.private / 1e6, 1), handles=self.p.num_handles(), threads=self.p.num_threads(),
                    cpu_core_pct=self.p.cpu_percent(None), system_cpu_pct=psutil.cpu_percent(None)))
            except psutil.NoSuchProcess:
                self.samples.append(dict(t=round(time.time() - self.t0, 1), phase=self.mark, dead=True))
                return

    def window(self, label: str) -> list[dict]:
        return [s for s in self.samples if s["phase"] == label and "dead" not in s]


def summarize(samples: list[dict]) -> dict:
    if not samples:
        return {}
    cpu = [s["cpu_core_pct"] for s in samples]
    ts = [s["t"] for s in samples]
    return dict(
        seconds=round(ts[-1] - ts[0], 1),
        cpu_cores_mean=round(statistics.mean(cpu) / 100, 2), cpu_cores_max=round(max(cpu) / 100, 2),
        cpu_pct_of_machine_mean=round(statistics.mean(cpu) / CORES, 1),
        system_cpu_pct_mean=round(statistics.mean(s["system_cpu_pct"] for s in samples), 1),
        rss_mb_start=samples[0]["rss_mb"], rss_mb_end=samples[-1]["rss_mb"], rss_mb_max=max(s["rss_mb"] for s in samples),
        private_mb_start=samples[0]["private_mb"], private_mb_end=samples[-1]["private_mb"],
        private_mb_max=max(s["private_mb"] for s in samples),
        private_mb_per_min=round(slope_per_min(ts, [s["private_mb"] for s in samples]), 2),
        handles_start=samples[0]["handles"], handles_end=samples[-1]["handles"],
        handles_per_min=round(slope_per_min(ts, [s["handles"] for s in samples]), 2),
        threads_max=max(s["threads"] for s in samples),
    )


MON: Monitor  # set in main


def run_load(c_unused, label: str, seconds: float, loads: list[tuple[str, float]]):
    """Run each (method, rate_hz) load in its own client thread for `seconds` (rate 0 = flat out),
    labelling monitor samples with `label`. Returns the monitor summary plus call latencies."""
    MON.mark = label
    t_end = time.time() + seconds
    res: dict = {}

    def worker(i, method, hz):
        c = Client(context=zmq.Context())
        lat, errs = [], 0
        nxt = time.time()
        while time.time() < t_end:
            try:
                lat.append(timed(c, method)[0])
            except (TimeoutError, RpcError):
                errs += 1
            if hz:
                nxt += 1 / hz
                time.sleep(max(0.0, nxt - time.time()))
        c.close()
        res[i] = (method, lat, errs)

    ths = [threading.Thread(target=worker, args=(i, m, hz)) for i, (m, hz) in enumerate(loads)]
    [t.start() for t in ths]
    if not ths:
        time.sleep(seconds)
    [t.join(seconds + 60) for t in ths]
    out = summarize(MON.window(label))
    for _, (m, lat, errs) in res.items():
        out[f"{m}_ms"] = stats(lat)
        out[f"{m}_errors"] = errs
    return out


def fmt_profile(label: str, r: dict) -> str:
    return (f"  {label:28s} cpu {r.get('cpu_cores_mean', 0):4.2f} cores (max {r.get('cpu_cores_max', 0):4.2f})  "
            f"private {r.get('private_mb_start', 0):6.0f}->{r.get('private_mb_end', 0):6.0f} MB "
            f"(max {r.get('private_mb_max', 0):6.0f}, {r.get('private_mb_per_min', 0):+6.1f} MB/min)  "
            f"handles {r.get('handles_start', 0)}->{r.get('handles_end', 0)}  threads {r.get('threads_max', 0)}")


# --- CPU / memory phases ---------------------------------------------------------------------------


def p_profile(c: Client, args):
    """CPU and memory of the exe in typical situations, each held for --profile-s seconds."""
    d = args.profile_s
    out = {}
    scenarios = [
        ("stopped, no RPC", "stop", []),
        ("started, no RPC", "start", []),
        ("getResults @ 10 Hz", "start", [("getResults", 10)]),
        ("getAI @ 1 Hz", "start", [("getAI", 1)]),
        ("getAll @ 1 Hz", "start", [("getAll", 1)]),
        ("getResults 10 Hz + getAll 1 Hz", "start", [("getResults", 10), ("getAll", 1)]),
        ("getAll flat out", "start", [("getAll", 0)]),
        ("getResults flat out", "start", [("getResults", 0)]),
        ("started, no RPC (after)", "start", []),
    ]
    for label, state, loads in scenarios:
        if state == "stop":
            c.call("setState", {"State": "stop"})
            time.sleep(2)
        else:
            ensure_started(c)
        r = run_load(c, f"profile: {label}", d, loads)
        r["state"] = c.call("getState")
        out[label] = r
        log(fmt_profile(label, r))
    return out


def p_blocksize(c: Client, args):
    """CPU and memory against #s (block size) with no RPC load, then back at the original #s."""
    orig = c.call("getSampling")
    out = {}
    for ns in [*args.block_sizes, orig["#s"]]:
        set_samples(c, ns, orig["Fs"])
        e0 = overrun_count()
        label = f"#s={ns} ({ns / orig['Fs'] * 1e3:.0f} ms)"
        r = run_load(c, f"blocksize: {label}", args.block_s, [])
        r["overruns"] = overrun_count() - e0
        r["state"] = c.call("getState")
        out[label] = r
        log(fmt_profile(label, r) + f"  overruns {r['overruns']}  {r['state']}")
    c.call("setSampling", orig)
    ensure_started(c)
    return out


def p_soak(c: Client, args):
    """Long run at a realistic load (getResults 10 Hz + getAll every 2 s), to find slow growth."""
    secs = args.soak_min * 60
    ensure_started(c)
    e0 = overrun_count()
    r = run_load(c, "soak", secs, [("getResults", 10), ("getAll", 0.5)])
    # Growth over the second half, after allocations from start-up of the load have settled.
    w = MON.window("soak")
    r["second_half"] = summarize(w[len(w) // 2:])
    r["overruns"] = overrun_count() - e0
    r["state"] = c.call("getState")
    log(fmt_profile(f"soak {args.soak_min} min", r))
    log(fmt_profile("  second half", r["second_half"]) + f"  overruns {r['overruns']}  {r['state']}")
    return r


# --- RPC performance phases ------------------------------------------------------------------------


def p_latency(c: Client, args):
    """Round-trip latency of small and large replies."""
    out = {}
    for m, n in [("ACK", 300), ("IDN", 300), ("getState", 300), ("getStatus", 300), ("getSampling", 300),
                 ("getAOconfig", 300), ("getREFconfig", 300), ("getInputGain", 300), ("getResults", 200),
                 ("getAO", 40), ("getAI", 40), ("getAll", 20), ("getAllData", 20)]:
        lat, size = [], 0
        for _ in range(n):
            ms, r = timed(c, m)
            lat.append(ms)
            size = len(json.dumps(r))
        out[m] = {**stats(lat), "reply_bytes": size}
        log(f"  {m:14s} p50 {out[m]['p50']:8.1f} ms  p99 {out[m]['p99']:8.1f} ms  {size:>9d} bytes")
    return out


def p_freshness(c: Client, args, seconds: float = 30):
    """How often getResults' timestamp advances (block rate) while polling flat out."""
    stamps, calls, t_end = [], 0, time.time() + seconds
    while time.time() < t_end:
        r = c.call("getResults")
        calls += 1
        if not stamps or stamps[-1][1] != r["Time Stamp"]:
            stamps.append((time.time(), r["Time Stamp"]))
    gaps = [(b[0] - a[0]) * 1e3 for a, b in zip(stamps, stamps[1:])]
    fs = c.call("getSampling")
    out = dict(calls=calls, calls_per_s=round(calls / seconds, 1), updates=len(stamps),
               expected_block_ms=round(fs["#s"] / fs["Fs"] * 1e3, 1), update_gap_ms=stats(gaps))
    log(f"  {out}")
    return out


def _worker(n_id, mix, t_end, res):
    c = Client(timeout=30, context=zmq.Context())
    lat, errs = [], []
    while time.time() < t_end:
        m = random.choice(mix)
        try:
            lat.append(timed(c, m)[0])
        except (TimeoutError, RpcError) as e:
            errs.append(f"{m}: {e}")
    c.close()
    res[n_id] = (lat, errs)


def p_concurrency(c: Client, args, seconds: float = 15):
    """K parallel clients, each its own socket, hammering a mix of getters."""
    out = {}
    for mix_name, mix, ks in [("small", ["getState", "getResults", "getAOconfig", "getSampling", "ACK"], (1, 2, 4, 8, 16, 32)),
                              ("large", ["getAI", "getAO", "getResults"], (1, 2, 4, 8))]:
        for k in ks:
            MON.mark = f"concurrency {mix_name} {k}"
            res: dict = {}
            t_end = time.time() + seconds
            ths = [threading.Thread(target=_worker, args=(i, mix, t_end, res)) for i in range(k)]
            [t.start() for t in ths]
            [t.join(seconds + 60) for t in ths]
            lat = [x for v in res.values() for x in v[0]]
            errs = [x for v in res.values() for x in v[1]]
            r = dict(clients=k, req_per_s=round(len(lat) / seconds, 1), latency=stats(lat), errors=len(errs),
                     sample_errors=errs[:3], **summarize(MON.window(MON.mark)))
            out[f"{mix_name}_{k}"] = r
            log(f"  {mix_name:5s} k={k:2d} {r['req_per_s']:7.1f} req/s  p50 {r['latency'].get('p50')} ms  "
                f"p99 {r['latency'].get('p99')} ms  errors {len(errs)}  cpu {r.get('cpu_cores_mean')} cores")
    return out


def p_setters(c: Client, args, n: int = 150):
    """Rapid single-channel setters with immediate read-back; counts stale first reads."""
    out = {}
    chans = [a["Channel"] for a in c.call("getAOconfig")]
    stale, lat, settle = 0, [], []
    for _ in range(n):
        ch, amp = random.choice(chans), round(random.uniform(0, 0.05), 4)
        lat.append(timed(c, "setAO_Amplitude", {"Channel": ch, "Amplitude": amp})[0])
        t0 = time.perf_counter()
        for tries in range(200):
            if abs(next(a for a in c.call("getAOconfig") if a["Channel"] == ch)["Amplitude"] - amp) < 1e-9:
                break
            stale += tries == 0
        settle.append((time.perf_counter() - t0) * 1e3)
    out["setAO_Amplitude"] = dict(set_ms=stats(lat), readback_ms=stats(settle), stale_first_reads=stale, n=n)
    ref = c.call("getREFconfig")
    stale, lat = 0, []
    for _ in range(n):
        ch, tc = random.choice(ref)["Channel"], random.choice([0.01, 0.03, 0.1, 0.3, 1.0])
        lat.append(timed(c, "setREF_TC", {"Channel": ch, "TC": tc})[0])
        stale += abs(next(r for r in c.call("getREFconfig") if r["Channel"] == ch)["TC"] - tc) > 1e-12
    out["setREF_TC"] = dict(set_ms=stats(lat), stale_first_reads=stale, n=n)
    for k, v in out.items():
        log(f"  {k:16s} set p50 {v['set_ms']['p50']} ms  stale first read-back {v['stale_first_reads']}/{n}")
    return out


def p_state(c: Client, args, n: int = 15):
    """stop/start cycles: time to stopped, to 'started' and to the first fresh result."""
    to_started, to_result, to_stopped = [], [], []
    for _ in range(n):
        t0 = time.perf_counter()
        c.call("setState", {"State": "stop"})
        while c.call("getState") not in ("stopped", "idle", "created") and time.perf_counter() - t0 < 20:
            pass
        to_stopped.append((time.perf_counter() - t0) * 1e3)
        ts0 = c.call("getResults")["Time Stamp"]
        t0 = time.perf_counter()
        c.call("setState", {"State": "start"})
        while c.call("getState") != "started" and time.perf_counter() - t0 < 20:
            pass
        to_started.append((time.perf_counter() - t0) * 1e3)
        while c.call("getResults")["Time Stamp"] == ts0 and time.perf_counter() - t0 < 20:
            pass
        to_result.append((time.perf_counter() - t0) * 1e3)
    out = dict(to_stopped_ms=stats(to_stopped), to_started_ms=stats(to_started), to_first_result_ms=stats(to_result))
    log(f"  stopped p50 {out['to_stopped_ms']['p50']} ms, started p50 {out['to_started_ms']['p50']} ms, "
        f"first result p50 {out['to_first_result_ms']['p50']} ms")
    return out


def p_sweep(c: Client, args):
    """Short 2-channel sweeps: does it finish, how long vs requested, result size."""
    out = {}
    for sweep_time in (2.0, 10.0):
        c.call("setSweep", {"initialWaitTime": 0.5, "sweepTime": sweep_time, "returnToStart": True, "sweepChannels": [
            {"Enable?": True, "Channel": 1, "Start": 0, "End": 0.05, "Pattern": "Ramp /"},
            {"Enable?": True, "Channel": 2, "Start": 0, "End": -0.05, "Pattern": "Ramp /\\"}]})
        t0 = time.perf_counter()
        c.call("setState", {"State": "start sweep"})
        seen = []
        while time.perf_counter() - t0 < sweep_time * 4 + 20:
            st = c.call("getStatus")
            if not seen or seen[-1][1] != st:
                seen.append((round((time.perf_counter() - t0) * 1e3), st))
            if len(seen) > 1 and st != "sweeping":
                break
            time.sleep(0.05)
        dur = (time.perf_counter() - t0) * 1e3
        ms, sw = timed(c, "getSweepResults")
        out[str(sweep_time)] = dict(transitions=seen, total_ms=round(dur), getSweepResults_ms=round(ms, 1),
                                    bytes=len(json.dumps(sw)))
        log(f"  sweep {sweep_time}s: {seen} total {dur:.0f} ms, results {len(json.dumps(sw)) / 1e3:.0f} kB")
    ensure_started(c)
    return out


def raw(payload: bytes, timeout_ms: int = 5000):
    s = zmq.Context.instance().socket(zmq.REQ)
    s.setsockopt(zmq.LINGER, 0)
    s.setsockopt(zmq.RCVTIMEO, timeout_ms)
    s.connect(ADDR)
    try:
        s.send(payload)
        t = time.perf_counter()
        rep = s.recv_string()
        return round((time.perf_counter() - t) * 1e3, 1), rep[:300]
    except zmq.Again:
        return None, "NO REPLY (timeout)"
    finally:
        s.close(0)


def p_churn(c: Client, args, n: int = 500):
    """A fresh connection per request, then 50 abandoned getAI requests; watch handles."""
    p = proc()
    h0, lat, fails = p.num_handles(), [], 0
    for _ in range(n):
        ms, _ = raw(b'{"jsonrpc":"2.0","method":"getState","params":{},"id":"c"}')
        if ms is None:
            fails += 1
        else:
            lat.append(ms)
    for _ in range(50):
        s = zmq.Context.instance().socket(zmq.REQ)
        s.setsockopt(zmq.LINGER, 0)
        s.connect(ADDR)
        s.send(b'{"jsonrpc":"2.0","method":"getAI","params":{},"id":"a"}')
        s.close(0)
    t = time.perf_counter()
    c.call("ACK")
    ack_ms = (time.perf_counter() - t) * 1e3
    time.sleep(3)
    out = dict(connections=n, failures=fails, latency=stats(lat), handles_before=h0, handles_after=p.num_handles(),
               ack_after_abandoned_ms=round(ack_ms, 1))
    log(f"  {n} connections, {fails} failures, p50 {out['latency'].get('p50')} ms, handles {h0}->{out['handles_after']}")
    return out


# --- opt-in phases (heavy, or can stop acquisition) ------------------------------------------------


def p_sampling(c: Client, args):
    """getAI/getAll latency, size and memory as #s grows (up to --max-samples)."""
    out = {}
    orig = c.call("getSampling")
    pr = proc()
    for ns in [x for x in (10000, 50000, 100000, 150000, 200000) if x <= args.max_samples]:
        set_samples(c, ns, orig["Fs"], settle=max(3.0, 4 * ns / orig["Fs"]))
        rss_idle = pr.memory_info().private / 1e6
        ai_ms, ai = zip(*(timed(c, "getAI") for _ in range(3)))
        lens = sorted({len(w["Y"]) for w in ai[-1]})
        del ai
        al_ms, al = timed(c, "getAll")
        size = len(json.dumps(al))
        del al
        out[ns] = dict(ai_lengths=lens, getAI_ms=stats(list(ai_ms)), getAll_ms=round(al_ms), getAll_bytes=size,
                       private_mb_idle=round(rss_idle), private_mb_after=round(pr.memory_info().private / 1e6))
        log(f"  #s={ns:6d} getAI p50 {out[ns]['getAI_ms']['p50']:7.0f} ms  getAll {al_ms:7.0f} ms {size / 1e6:5.1f} MB  private {rss_idle:.0f} -> "
            f"{out[ns]['private_mb_after']} MB  AI lengths {lens}")
    c.call("setSampling", orig)
    ensure_started(c)
    return out


def p_grid(c: Client, args):
    """Every Fs x #s combination (skipping blocks longer than --grid-max-block s): the rate actually applied,
    whether acquisition keeps running, CPU and memory with getResults polled at 10 Hz, result update gaps,
    getAI time, and errors the exe logged. Can stop acquisition; it is restarted for the next combination."""
    orig = c.call("getSampling")
    out = []
    combos = [(fs, ns) for fs in args.grid_fs for ns in args.grid_ns if ns / fs <= args.grid_max_block]
    log(f"  {len(combos)} combinations, ~{len(combos) * (args.grid_s + 8) / 60:.0f} min")
    for fs, ns in combos:
        mark = log_mark()
        ensure_started(c)
        t_set = time.perf_counter()
        try:
            c.call("setSampling", {"Fs": fs, "#s": ns})
            set_err = None
        except RpcError as e:
            set_err = str(e)[:200]
        applied = c.call("getSampling")
        block = applied["#s"] / applied["Fs"] if applied["Fs"] else 0
        time.sleep(max(3.0, 3 * block))  # let the old-size blocks flush
        switch_errs = errors_since(mark)  # logged while reconfiguring, kept apart from steady state
        ensure_started(c)
        mark = log_mark()
        label = f"grid: Fs={fs:g} #s={ns}"
        MON.mark = label
        # getResults at 10 Hz: a realistic light load. Lag = how far the newest result's time stamp trails
        # the clock; if processing falls behind, DAQmx's backlog grows and so does the lag, until it overruns.
        stamps, lags, t_end = [], [], time.time() + args.grid_s
        while time.time() < t_end:
            t = time.time()
            try:
                ts = c.call("getResults")["Time Stamp"]
                lags.append((t, (time.time() - dt.datetime.fromisoformat(ts.replace("Z", "+00:00")).timestamp()) * 1e3))
                if not stamps or stamps[-1][1] != ts:
                    stamps.append((t, ts))
            except (TimeoutError, RpcError, ValueError):
                pass
            time.sleep(max(0.0, 0.1 - (time.time() - t)))
        r = summarize(MON.window(label))
        gaps = [(b[0] - a[0]) * 1e3 for a, b in zip(stamps, stamps[1:])]
        lag_ms = [x for _, x in lags]
        lag_slope = slope_per_min([t for t, _ in lags], lag_ms) / 60 if lags else None  # ms of lag per s
        try:
            ai_ms, ai = timed(c, "getAI")
            ai_lens = sorted({len(w["Y"]) for w in ai})
            del ai
        except (TimeoutError, RpcError) as e:
            ai_ms, ai_lens = None, str(e)[:100]
        state = c.call("getState")
        errs = errors_since(mark)
        row = dict(fs_req=fs, ns_req=ns, fs_applied=applied["Fs"], ns_applied=applied["#s"], set_error=set_err,
                   block_ms=round(block * 1e3, 1), state=state, result_updates_seen=len(stamps),
                   update_gap_ms=stats(gaps), lag_ms=stats(lag_ms),
                   lag_growth_ms_per_s=round(lag_slope, 1) if lag_slope is not None else None,
                   getAI_ms=round(ai_ms) if ai_ms else None, ai_lengths=ai_lens, errors=errs,
                   switch_errors=switch_errs,
                   cpu_cores=r.get("cpu_cores_mean"), cpu_cores_max=r.get("cpu_cores_max"),
                   private_mb=r.get("private_mb_end"), private_mb_max=r.get("private_mb_max"),
                   settle_s=round(time.perf_counter() - t_set - args.grid_s, 1))
        out.append(row)
        flag = "" if state == "started" and not errs else "  <--"
        log(f"  Fs {fs:>7g} #s {ns:>6d} -> applied {applied['Fs']:>9.1f} / {applied['#s']:>6d}  block {row['block_ms']:7.1f} ms  "
            f"{state:8s} lag p50 {row['lag_ms'].get('p50', 0):7.0f} ms ({row['lag_growth_ms_per_s']:+.0f} ms/s)  "
            f"cpu {row['cpu_cores']} cores  "
            f"private {row['private_mb']} MB  getAI {row['getAI_ms']} ms  errors {errs}  (switch {switch_errs}){flag}")
        if state != "started":
            ensure_started(c, wait=3)
    c.call("setSampling", orig)
    ensure_started(c)
    return out


def unwrap_deg(xs: list[float]) -> list[float]:
    out = []
    for x in xs:
        if out:
            x += 360 * round((out[-1] - x) / 360)
        out.append(x)
    return out


def p_phase(c: Client, args):
    """Demodulated phase stability for each --phase-cases Fs:#s:f. Sets Fs and #s, links AO and REF to f, waits
    for the filter to settle, then records every new getResults for --phase-s: Theta and R of every AI against
    Ref1. A stable setup gives a constant Theta; a Fs/#s/f combination that breaks phase continuity between blocks
    shows up as scatter, steps or drift."""
    orig_link = c.call("getLinkFrequency")
    out = []
    for case in args.phase_cases:
        fs, ns, f = (float(x) for x in case.split(":"))
        c.call("setSampling", {"Fs": fs, "#s": int(ns)})
        c.call("setLinkFrequency", {"Link": True, "Frequency": f})
        applied = c.call("getSampling")
        tc = max(r["TC"] for r in c.call("getREFconfig"))
        block = applied["#s"] / applied["Fs"]
        time.sleep(max(5.0, 10 * tc + 3 * block))
        ensure_started(c)
        label = f"phase: Fs={fs:g} #s={int(ns)} f={f:g}"
        MON.mark = label
        mark = log_mark()
        series, last, t_end = {}, None, time.time() + args.phase_s
        while time.time() < t_end:
            t = time.time()
            try:
                r = c.call("getResults")
            except (TimeoutError, RpcError):
                continue
            if r["Time Stamp"] != last:
                last = r["Time Stamp"]
                d = {kv["key"]: kv["value"] for kv in r["Results (Dictionary)"]}
                for k, v in d.items():
                    if k.endswith(".Ref1.Theta"):
                        ch = k.split(".")[0]
                        series.setdefault(ch, []).append((last, v, d.get(f"{ch}.Ref1.R")))
            time.sleep(max(0.0, 0.1 - (time.time() - t)))
        row = dict(fs_req=fs, ns_req=int(ns), f=f, fs_applied=applied["Fs"], ns_applied=applied["#s"],
                   block_ms=round(block * 1e3, 2), cycles_per_block=round(f * block, 4),
                   state=c.call("getState"), errors=errors_since(mark), channels={})
        for ch, s in series.items():
            ts = [dt.datetime.fromisoformat(x[0].replace("Z", "+00:00")).timestamp() for x in s]
            th = unwrap_deg([x[1] for x in s])
            steps = [abs(b - a) for a, b in zip(th, th[1:])]
            row["channels"][ch] = dict(
                n=len(s), R_mean=statistics.mean(x[2] for x in s if x[2] is not None),
                theta_mean=round(statistics.mean(th), 4), theta_std=round(statistics.pstdev(th), 4),
                theta_min=round(min(th), 4), theta_max=round(max(th), 4),
                drift_deg_per_min=round(slope_per_min(ts, th), 4), max_step_deg=round(max(steps, default=0), 4),
                series=[[x[0], round(x[1], 5), x[2]] for x in s])
        out.append(row)
        log(f"  Fs {fs:g} (applied {applied['Fs']:.3f}) #s {int(ns)} f {f:g}: block {row['block_ms']} ms, "
            f"{row['cycles_per_block']} cycles/block, {row['state']}, errors {row['errors']}")
        for ch, v in row["channels"].items():
            log(f"    {ch}: R {v['R_mean']:.4g} V  theta {v['theta_mean']:+.3f} deg  std {v['theta_std']:.4f}  "
                f"range {v['theta_max'] - v['theta_min']:.4f}  drift {v['drift_deg_per_min']:+.4f} deg/min  "
                f"max step {v['max_step_deg']:.4f}  (n {v['n']})")
    c.call("setLinkFrequency", orig_link)
    return out


def p_overrun(c: Client, args):
    """Small blocks: do DAQmx reads fall behind (-200279) with and without RPC load? Can stop acquisition."""
    orig = c.call("getSampling")
    out = {}
    for ns in (2000, 5000, 10000):
        for load in ([], [("getAI", 0)]):
            set_samples(c, ns, orig["Fs"])
            e0 = overrun_count()
            label = f"#s={ns} load={'getAI flat out' if load else 'none'}"
            r = run_load(c, f"overrun: {label}", 25, load)
            out[label] = dict(overruns=overrun_count() - e0, state_after=c.call("getState"),
                              cpu_cores_mean=r.get("cpu_cores_mean"))
            log(f"  {label:32s} overruns {out[label]['overruns']}  state {out[label]['state_after']}")
    c.call("setSampling", orig)
    ensure_started(c)
    return out


def p_torn(c: Client, args, seconds: float = 40):
    """Read getAI while #s toggles 10000/20000: count replies whose channels have mixed lengths."""
    orig = c.call("getSampling")
    ensure_started(c)
    stop = threading.Event()

    def toggle():
        cc, i = Client(context=zmq.Context()), 0
        while not stop.is_set():
            cc.call("setSampling", {"Fs": orig["Fs"], "#s": (10000, 20000)[i % 2]})
            i += 1
            time.sleep(0.7)

    th = threading.Thread(target=toggle)
    th.start()
    n = mixed = 0
    examples = []
    t_end = time.time() + seconds
    while time.time() < t_end:
        lens = [len(w["Y"]) for w in c.call("getAI")]
        n += 1
        if len(set(lens)) > 1:
            mixed += 1
            examples.append(lens)
    stop.set()
    th.join()
    out = dict(replies=n, mixed_length=mixed, examples=examples[:3], state_after=c.call("getState"))
    log(f"  {mixed}/{n} getAI replies had mixed channel lengths; state after: {out['state_after']}")
    c.call("setSampling", orig)
    ensure_started(c)
    return out


def p_robustness(c: Client, args):
    """Malformed requests; after each, the server must still answer ACK. NaN TC stops acquisition on 3.9.0.99."""
    cases = {
        "not_json": b"hello there",
        "empty": b"",
        "truncated_json": b'{"jsonrpc":"2.0","method":"getState"',
        "json_array": b"[1,2,3]",
        "no_method": b'{"jsonrpc":"2.0","id":"1"}',
        "unknown_method": b'{"jsonrpc":"2.0","method":"selfDestruct","params":{},"id":"1"}',
        "wrong_param_type": b'{"jsonrpc":"2.0","method":"setSampling","params":"fast please","id":"1"}',
        "bad_state": b'{"jsonrpc":"2.0","method":"setState","params":{"State":"explode"},"id":"1"}',
        "binary_garbage": bytes(random.getrandbits(8) for _ in range(4096)),
        "huge_10MB": json.dumps({"jsonrpc": "2.0", "method": "setSweepTable",
                                 "params": [{"Channel": 99, "Table": [0.0] * 1_000_000}], "id": "1"}).encode(),
    }
    if args.destructive:
        cases["unknown_keys"] = b'{"jsonrpc":"2.0","method":"setSampling","params":{"rate":1,"n":2},"id":"1"}'
        cases["nan_tc"] = b'{"jsonrpc":"2.0","method":"setREF_TC","params":{"Channel":1,"TC":NaN},"id":"1"}'
    out = {}
    for name, payload in cases.items():
        ms, rep = raw(payload, 15000)
        _, ack = raw(b'{"jsonrpc":"2.0","method":"ACK","params":{},"id":"x"}')
        out[name] = dict(reply_ms=ms, reply=rep, alive_after="ACK" in ack)
        log(f"  {name:18s} {ms} ms: {rep[:100]!r}  alive={out[name]['alive_after']}")
        if not out[name]["alive_after"]:
            break
    out["state_after"] = c.call("getState")
    out["sampling_after"] = c.call("getSampling")
    return out


PHASES = dict(profile=p_profile, blocksize=p_blocksize, soak=p_soak, latency=p_latency, freshness=p_freshness,
              concurrency=p_concurrency, setters=p_setters, state=p_state, sweep=p_sweep, churn=p_churn,
              sampling=p_sampling, grid=p_grid, phase=p_phase, overrun=p_overrun, torn=p_torn, robustness=p_robustness)


# --- output ----------------------------------------------------------------------------------------


def plot(samples: list[dict], path: Path, title: str):
    try:
        import matplotlib

        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        return
    s = [x for x in samples if "dead" not in x]
    if not s:
        return
    t = [x["t"] / 60 for x in s]
    fig, ax = plt.subplots(3, 1, figsize=(12, 9), sharex=True)
    ax[0].plot(t, [x["cpu_core_pct"] / 100 for x in s], lw=0.8, label="exe")
    ax[0].plot(t, [x["system_cpu_pct"] * CORES / 100 for x in s], lw=0.8, alpha=0.6, label="whole machine")
    ax[0].set_ylabel("CPU (cores)")
    ax[0].legend(loc="upper right")
    ax[1].plot(t, [x["private_mb"] for x in s], lw=0.8, label="private")
    ax[1].plot(t, [x["rss_mb"] for x in s], lw=0.8, alpha=0.6, label="working set")
    ax[1].set_ylabel("memory (MB)")
    ax[1].legend(loc="upper right")
    ax[2].plot(t, [x["handles"] for x in s], lw=0.8)
    ax[2].set_ylabel("handles")
    ax[2].set_xlabel("minutes")
    # Shade alternate phases and label them.
    spans, cur, start = [], None, None
    for x in s:
        if x["phase"] != cur:
            if cur is not None:
                spans.append((cur, start, x["t"] / 60))
            cur, start = x["phase"], x["t"] / 60
    spans.append((cur, start, s[-1]["t"] / 60))
    for i, (name, a, b) in enumerate(spans):
        for k in ax:
            if i % 2:
                k.axvspan(a, b, color="0.92", zorder=0)
        if b - a > (t[-1] - t[0]) / 60:
            ax[0].text((a + b) / 2, ax[0].get_ylim()[1], name.replace(": ", "\n"), fontsize=6, ha="center", va="top",
                       rotation=90)
    fig.suptitle(title)
    fig.tight_layout()
    fig.savefig(path, dpi=110)
    plt.close(fig)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("phases", nargs="*", help=f"default: {' '.join(DEFAULT)}; opt-in: {' '.join(OPT_IN)}")
    ap.add_argument("--profile-s", type=float, default=60, help="seconds per profile scenario")
    ap.add_argument("--block-s", type=float, default=45, help="seconds per block size")
    ap.add_argument("--block-sizes", type=int, nargs="+", default=[5000, 10000, 25000, 50000, 100000])
    ap.add_argument("--grid-fs", type=float, nargs="+", default=[10000, 25600, 51200, 96000, 102400, 204800])
    ap.add_argument("--grid-ns", type=int, nargs="+", default=[1000, 2500, 5000, 10000, 25000, 50000, 100000])
    ap.add_argument("--grid-s", type=float, default=20, help="seconds per grid combination")
    ap.add_argument("--grid-max-block", type=float, default=5, help="skip combinations with longer blocks (s)")
    ap.add_argument("--phase-cases", nargs="+", default=["94000:10000:500", "94000:10000:5000", "48000:10000:1355",
                                                          "94000:9400:1355"], help="phase: Fs:#s:f per case")
    ap.add_argument("--phase-s", type=float, default=30, help="seconds of results per phase case")
    ap.add_argument("--soak-min", type=float, default=20, help="soak duration in minutes")
    ap.add_argument("--max-samples", type=int, default=100000, help="largest #s for the sampling phase")
    ap.add_argument("--destructive", action="store_true", help="robustness: include requests known to change config")
    ap.add_argument("--setup", help="name of the computer + hardware (default <COMPUTERNAME>_<DAQ devices>)")
    ap.add_argument("--out", type=Path, help="results folder (default results/<setup>/<date>_<firmware>)")
    args = ap.parse_args()
    names = args.phases or DEFAULT
    bad = [n for n in names if n not in PHASES]
    if bad:
        sys.exit(f"unknown phase(s): {bad}")

    c = Client()
    idn = c.call("IDN")
    host = host_info()
    setup = args.setup or default_setup(host)
    out_dir = args.out or HERE / "results" / setup / f"{dt.date.today()}_{idn['firmware']}"
    out_dir.mkdir(parents=True, exist_ok=True)
    stamp = dt.datetime.now().strftime("%H%M%S")
    tag = f"{stamp}_{'-'.join(names)}"
    snap = {m: c.call(m) for m in ("getSampling", "getAOconfig", "getREFconfig", "getState", "getLinkFrequency")}
    channels = dict(ai=[w.get("attributes", {}).get("NI_ChannelName") for w in c.call("getAI")],
                    ao=[a["Channel"] for a in snap["getAOconfig"]])
    p = proc()
    results: dict = dict(idn=idn, phases=names, args={k: str(v) for k, v in vars(args).items()},
                         setup=setup, host=host, channels=channels,
                         exe=dict(pid=p.pid, started=dt.datetime.fromtimestamp(p.create_time()).isoformat(),
                                  private_mb_at_start=round(p.memory_info().private / 1e6, 1),
                                  handles_at_start=p.num_handles()),
                         snapshot=snap)
    log(f"{setup}: {host.get('cpu')}, {len(channels['ai'])} AI, {len(channels['ao'])} AO")
    log(f"{idn['model']} {idn['firmware']}  pid {p.pid}  private {results['exe']['private_mb_at_start']} MB  "
        f"handles {results['exe']['handles_at_start']}  -> {out_dir}")
    global MON
    MON = Monitor(p)
    MON.start()
    try:
        for name in names:
            MON.mark = name
            log(f"== {name}")
            t0 = time.time()
            try:
                results[name] = PHASES[name](c, args)
            except Exception as e:  # record and continue with the next phase
                results[name] = {"EXCEPTION": repr(e)}
                log(f"  !! {e!r}")
                c = Client()
            results[name + "_wall_s"] = round(time.time() - t0, 1)
    finally:
        MON.mark = "restore"
        try:
            c.call("setSampling", snap["getSampling"])
            c.call("setAO", snap["getAOconfig"])
            c.call("setREF", snap["getREFconfig"])
            c.call("setLinkFrequency", snap["getLinkFrequency"])
            if snap["getState"] == "started":
                ensure_started(c, wait=3)
            elif c.call("getState") == "started":
                c.call("setState", {"State": "stop"})
                time.sleep(2)
            results["restored"] = {m: c.call(m) == v for m, v in snap.items()}
            results["state_at_end"] = c.call("getState")
        except Exception as e:
            results["restored"] = repr(e)
        time.sleep(2)
        MON.stop_ev.set()
        MON.join()
        results["exe_overall"] = summarize([s for s in MON.samples if "dead" not in s])
        (out_dir / f"{tag}_results.json").write_text(json.dumps(results, indent=1, default=str))
        with open(out_dir / f"{tag}_monitor.csv", "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=["t", "phase", "rss_mb", "private_mb", "handles", "threads",
                                              "cpu_core_pct", "system_cpu_pct", "dead"])
            w.writeheader()
            w.writerows(MON.samples)
        plot(MON.samples, out_dir / f"{tag}_monitor.png", f"{setup}  {idn['firmware']}  {tag}")
        log(f"restored: {results['restored']}")
        log(f"wrote {out_dir / tag}_*")


if __name__ == "__main__":
    main()
