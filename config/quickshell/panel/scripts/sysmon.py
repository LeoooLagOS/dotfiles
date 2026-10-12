#!/usr/bin/env python3
"""Live system readings for the bar's system monitor (bar/SystemMonitor.qml).

Prints one JSON line every INTERVAL seconds while it runs (the monitor runs it
only while it's open): every CPU thread's usage and frequency, temperatures,
load, memory and swap, disks and their I/O, network rates, and the processes
(the 120 busiest by CPU plus the 120 biggest by memory; the monitor sorts and
filters). Everything comes from /proc and /sys; nothing to install.

A process's CPU % is its share of the whole machine (all threads = 100 %),
like the total, so the column adds up.
"""

import json
import os
import pwd
import sys
import time

INTERVAL = 1.5
PAGE = os.sysconf("SC_PAGE_SIZE")
NCPU = os.cpu_count() or 1
TOP = 120


def read(path, default=""):
    try:
        with open(path) as f:
            return f.read()
    except OSError:
        return default


def cpu_times():
    """[(busy, total)] for the whole CPU (index 0) and each thread."""
    out = []
    for line in read("/proc/stat").splitlines():
        if not line.startswith("cpu"):
            break
        v = [int(x) for x in line.split()[1:9]]
        idle = v[3] + v[4]
        total = sum(v)
        out.append((total - idle, total))
    return out


def freqs():
    out = []
    for i in range(NCPU):
        f = read(f"/sys/devices/system/cpu/cpu{i}/cpufreq/scaling_cur_freq").strip()
        out.append(round(int(f) / 1000) if f.isdigit() else 0)
    return out


def temps():
    """CPU package and per-core temperatures (coretemp / k10temp), NVMe."""
    res = {"cpu": 0, "cores": {}, "nvme": 0}
    base = "/sys/class/hwmon"
    for h in sorted(os.listdir(base)):
        d = os.path.join(base, h)
        name = read(os.path.join(d, "name")).strip()
        if name in ("coretemp", "k10temp", "zenpower"):
            for f in os.listdir(d):
                if not f.endswith("_input"):
                    continue
                label = read(os.path.join(d, f.replace("_input", "_label"))).strip()
                val = int(read(os.path.join(d, f), "0") or 0) // 1000
                if label.startswith(("Package", "Tctl", "Tdie")):
                    res["cpu"] = val
                elif label.startswith("Core"):
                    res["cores"][label] = val
        elif name == "nvme" and not res["nvme"]:
            res["nvme"] = int(read(os.path.join(d, "temp1_input"), "0") or 0) // 1000
    return res


def meminfo():
    m = {}
    for line in read("/proc/meminfo").splitlines():
        k, _, v = line.partition(":")
        m[k] = int(v.split()[0]) * 1024
    total, avail = m.get("MemTotal", 1), m.get("MemAvailable", 0)
    cache = m.get("Cached", 0) + m.get("Buffers", 0) + m.get("SReclaimable", 0) - m.get("Shmem", 0)
    return {
        "total": total, "used": total - avail, "avail": avail, "cache": max(0, cache),
        "swapTotal": m.get("SwapTotal", 0), "swapUsed": m.get("SwapTotal", 0) - m.get("SwapFree", 0),
    }


def disks():
    out, seen = [], set()
    for line in read("/proc/mounts").splitlines():
        dev, mnt, fs = line.split()[:3]
        if not dev.startswith("/dev/") or fs in ("squashfs", "overlay") or dev in seen:
            continue
        if mnt not in ("/", "/home", "/boot", "/boot/efi") and not mnt.startswith(("/mnt", "/media", "/run/media")):
            continue
        seen.add(dev)
        try:
            st = os.statvfs(mnt)
        except OSError:
            continue
        total = st.f_blocks * st.f_frsize
        out.append({"mount": mnt, "total": total, "used": total - st.f_bfree * st.f_frsize})
    return out


def disk_bytes():
    """Bytes read / written so far on the physical disks (whole devices only)."""
    r = w = 0
    for line in read("/proc/diskstats").splitlines():
        p = line.split()
        name = p[2]
        if name.startswith(("loop", "ram", "zram", "dm-")) or (name[-1].isdigit() and not name.startswith("nvme")):
            continue
        if name.startswith("nvme") and "p" in name[4:]:
            continue
        r += int(p[5]) * 512
        w += int(p[9]) * 512
    return r, w


def net_bytes():
    rx = tx = 0
    for line in read("/proc/net/dev").splitlines()[2:]:
        name, _, rest = line.partition(":")
        name = name.strip()
        if name == "lo" or name.startswith(("veth", "docker", "virbr", "br-")):
            continue
        v = rest.split()
        rx += int(v[0])
        tx += int(v[8])
    return rx, tx


_users = {}


def user(uid):
    if uid not in _users:
        try:
            _users[uid] = pwd.getpwuid(uid).pw_name
        except KeyError:
            _users[uid] = str(uid)
    return _users[uid]


def processes(prev, dt_total, mem_total):
    """Per process: CPU % since the last sample, memory, threads, state."""
    now, out, nthreads, running = {}, [], 0, 0
    for pid in os.listdir("/proc"):
        if not pid.isdigit():
            continue
        stat = read(f"/proc/{pid}/stat")
        if not stat:
            continue
        # comm may contain spaces and parentheses: split around the last ")"
        l, r = stat.find("("), stat.rfind(")")
        comm = stat[l + 1:r]
        f = stat[r + 2:].split()
        state = f[0]
        ticks = int(f[11]) + int(f[12])
        threads = int(f[17])
        rss = int(f[21]) * PAGE
        now[pid] = ticks
        nthreads += threads
        if state == "R":
            running += 1
        cpu = (ticks - prev[pid]) / dt_total * 100 if pid in prev and dt_total > 0 else 0.0
        try:
            uid = os.stat(f"/proc/{pid}").st_uid
        except OSError:
            continue
        out.append({"pid": int(pid), "name": comm, "user": user(uid), "cpu": round(cpu, 1),
                    "mem": round(rss / mem_total * 100, 1), "rss": rss, "threads": threads, "state": state})
    total = len(out)
    by_cpu = sorted(out, key=lambda p: -p["cpu"])[:TOP]
    by_mem = sorted(out, key=lambda p: -p["rss"])[:TOP]
    pick = {p["pid"]: p for p in by_cpu + by_mem}
    for p in pick.values():
        cmd = read(f"/proc/{p['pid']}/cmdline").replace("\0", " ").strip()
        p["cmd"] = cmd[:160]
    return list(pick.values()), now, total, nthreads, running


def main():
    prev_cpu = cpu_times()
    prev_disk, prev_net = disk_bytes(), net_bytes()
    prev_proc = {}
    prev_t = time.monotonic()
    _, prev_proc, *_ = processes({}, 0, 1)
    model = next((l.split(":", 1)[1].strip() for l in read("/proc/cpuinfo").splitlines() if l.startswith("model name")), "")
    while True:
        time.sleep(INTERVAL)
        t = time.monotonic()
        dt = t - prev_t
        cur = cpu_times()
        usage = []
        for (b0, t0), (b1, t1) in zip(prev_cpu, cur):
            usage.append(round((b1 - b0) / (t1 - t0) * 100, 1) if t1 > t0 else 0.0)
        dt_total = cur[0][1] - prev_cpu[0][1]
        mem = meminfo()
        procs, prev_proc, nprocs, nthreads, running = processes(prev_proc, dt_total, mem["total"])
        d, n = disk_bytes(), net_bytes()
        la = read("/proc/loadavg").split()
        data = {
            "model": model,
            "cpu": usage[0], "cores": usage[1:], "freqs": freqs(), "temps": temps(),
            "load": [float(x) for x in la[:3]], "uptime": float(read("/proc/uptime").split()[0]),
            "mem": mem, "disks": disks(),
            "io": {"read": (d[0] - prev_disk[0]) / dt, "write": (d[1] - prev_disk[1]) / dt},
            "net": {"rx": (n[0] - prev_net[0]) / dt, "tx": (n[1] - prev_net[1]) / dt},
            "procs": procs, "nprocs": nprocs, "nthreads": nthreads, "running": running,
        }
        print(json.dumps(data, separators=(",", ":")), flush=True)
        prev_cpu, prev_disk, prev_net, prev_t = cur, d, n, t


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, BrokenPipeError):
        sys.exit(0)
