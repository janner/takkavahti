# LXC: /proc is subset=pid, so /proc/stat is missing and psutil.boot_time crashes.
# Restore boot_time: real btime first, otherwise derived from /proc/self/stat.
import os
import time


def _boot_time():
    for p in ("/proc/stat", "/dev/.lxc/proc/stat"):
        try:
            with open(p) as f:
                for line in f:
                    if line.startswith("btime "):
                        return float(line.split()[1])
        except OSError:
            continue
    try:
        # field 22 (starttime, clk_tk) is index 19 after the closing parenthesis
        with open("/proc/self/stat") as f:
            ticks = int(f.read().rsplit(")", 1)[1].split()[19])
        return time.time() - ticks / os.sysconf("SC_CLK_TCK")
    except Exception:
        return 0.0


try:
    import psutil
    import psutil._pslinux as _psl

    psutil.boot_time = _boot_time
    _psl.boot_time = _boot_time
except Exception:
    pass