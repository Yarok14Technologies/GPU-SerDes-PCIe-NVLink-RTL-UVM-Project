

# ✅ **`tools/plot_eye.py`** — Statistical Eye Diagram Generator

```python
#!/usr/bin/env python3
"""
plot_eye.py
------------
Generate a statistical eye diagram from a sampled serial waveform.

Expected input:
- CSV with two columns: time (ns), voltage (0/1 or analog)

Example run:
python plot_eye.py --input ../sim/logs/serial_trace.csv --ui 0.1 --samples 2000
"""

import argparse
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True,
                        help="CSV file with [time, voltage]")
    parser.add_argument("--ui", type=float, default=0.1,
                        help="Unit Interval (UI) in ns")
    parser.add_argument("--samples", type=int, default=2000,
                        help="Number of samples to overlay")
    parser.add_argument("--out", default="eye_diagram.png",
                        help="Output image file")

    args = parser.parse_args()

    # Load waveform
    df = pd.read_csv(args.input, names=["time", "v"])

    t = df["time"].values
    v = df["v"].values

    # Normalize time to UI boundaries
    t_norm = np.mod(t, args.ui)

    plt.figure(figsize=(8, 5))

    # Overlay multiple traces to form eye
    for i in range(min(args.samples, len(t_norm))):
        idx = np.random.randint(0, len(t_norm))
        plt.plot(t_norm, v, alpha=0.02, color="black")

    plt.xlabel("Time (UI)")
    plt.ylabel("Voltage (a.u.)")
    plt.title("Statistical SerDes Eye Diagram")
    plt.grid(True, linestyle="--", alpha=0.4)

    plt.savefig(args.out, dpi=300, bbox_inches="tight")
    print(f"[INFO] Eye diagram saved to {args.out}")

if __name__ == "__main__":
    main()
```

### What this does (for interviews)

* Wraps time into one UI
* Overlays many traces → realistic “fuzzy” eye
* Can be compared across BER/jitter conditions

---

# ✅ **`tools/plot_bathtub.py`** — Bathtub Curve (Jitter vs BER)

```python
#!/usr/bin/env python3
"""
plot_bathtub.py
---------------
Plots a bathtub curve: BER vs timing margin.

Expected input:
CSV with two columns:
timing_margin_ps, BER

Example run:
python plot_bathtub.py --input ../sim/logs/ber_vs_margin.csv
"""

import argparse
import pandas as pd
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True,
                        help="CSV with [timing_margin_ps, BER]")
    parser.add_argument("--out", default="bathtub_curve.png",
                        help="Output image file")

    args = parser.parse_args()

    df = pd.read_csv(args.input, names=["margin_ps", "ber"])

    plt.figure(figsize=(8, 5))
    plt.plot(df["margin_ps"], df["ber"], marker="o", linewidth=1)
    plt.yscale("log")
    plt.xlabel("Timing Margin (ps)")
    plt.ylabel("BER")
    plt.title("SerDes Bathtub Curve")
    plt.grid(True, which="both", linestyle="--", alpha=0.4)

    plt.savefig(args.out, dpi=300, bbox_inches="tight")
    print(f"[INFO] Bathtub curve saved to {args.out}")

if __name__ == "__main__":
    main()
```

### How to generate input CSV (example)

Your simulator or UVM monitor can dump:

```
# margin_ps, BER
5, 1e-6
10, 1e-9
15, 1e-12
20, 1e-15
```

---

# ✅ **`tools/gen_stats.py`** — Aggregate SerDes Statistics

```python
#!/usr/bin/env python3
"""
gen_stats.py
-------------
Aggregates BER, lock time, and eye-opening statistics
from simulation logs and prints a clean report.

Expected inputs (example):
- ber_log.csv: list of 0/1 errors per bit
- lock_time.txt: single number (ns)
- eye_ratio.txt: single float (0 to 1)

Example run:
python gen_stats.py \
  --ber ../sim/logs/ber_log.csv \
  --lock ../sim/logs/lock_time.txt \
  --eye ../sim/logs/eye_ratio.txt
"""

import argparse
import numpy as np

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ber", required=True,
                        help="CSV of 0/1 bit errors")
    parser.add_argument("--lock", required=True,
                        help="Text file with lock time (ns)")
    parser.add_argument("--eye", required=True,
                        help="Text file with eye opening ratio")

    args = parser.parse_args()

    # Load BER log
    errors = np.loadtxt(args.ber, delimiter=",")
    total_bits = len(errors)
    error_bits = np.sum(errors)
    ber = error_bits / max(total_bits, 1)

    # Load lock time
    with open(args.lock, "r") as f:
        lock_time = float(f.read().strip())

    # Load eye ratio
    with open(args.eye, "r") as f:
        eye_ratio = float(f.read().strip())

    print("\n========== SerDes STATISTICS REPORT ==========")
    print(f"Total bits observed   : {total_bits}")
    print(f"Error bits            : {error_bits}")
    print(f"Computed BER          : {ber:.3e}")
    print(f"CDR Lock Time (ns)    : {lock_time:.2f}")
    print(f"Eye Opening Ratio     : {eye_ratio:.3f}")
    print("==============================================\n")

if __name__ == "__main__":
    main()
```

---

# How these tie to your project (folder mapping)

| Tool              | Uses data from       | Produced in                  |
| ----------------- | -------------------- | ---------------------------- |
| `plot_eye.py`     | Serial samples       | `sim/logs/serial_trace.csv`  |
| `plot_bathtub.py` | Margin vs BER sweep  | `sim/logs/ber_vs_margin.csv` |
| `gen_stats.py`    | BER, lock, eye stats | `sim/logs/*.txt / *.csv`     |

---

Below are **ready-to-use, detailed versions of all four files** **plus the exact formats your UVM monitor/simulator should write** so that your tools (`plot_eye.py`, `plot_bathtub.py`, `gen_stats.py`) will work out-of-the-box.

You can copy these directly into your repo under:

```
serdes_gpu_project/
└── sim/
    └── logs/
        ├── serial_trace.csv
        ├── ber_log.csv
        ├── lock_time.txt
        └── eye_ratio.txt
```

---

# ✅ **1) `serial_trace.csv` — raw serial waveform**

### **Purpose**

Used by `plot_eye.py` to build the statistical eye diagram.

### **Format (two columns, no header)**

```
time_ns, voltage
```

### **Example contents**

```csv
0.00,0
0.01,0
0.02,1
0.03,1
0.04,1
0.05,0
0.06,0
0.07,1
0.08,1
0.09,0
0.10,1
0.11,1
0.12,0
0.13,0
0.14,1
0.15,1
0.16,0
0.17,0
0.18,1
0.19,1
0.20,0
```

### **How your UVM monitor should write this (concept)**

```systemverilog
int fd;
initial fd = $fopen("sim/logs/serial_trace.csv","w");

always @(posedge clk) begin
   $fwrite(fd, "%0.3f,%0d\n", $time/1ns, serial_corrupt);
end
```

---

# ✅ **2) `ber_log.csv` — bit-error log**

### **Purpose**

Used by `gen_stats.py` to compute BER.

### **Format (single column: 0 = clean bit, 1 = error)**

```csv
0
0
1
0
0
0
1
0
0
0
0
1
0
0
0
```

### **Example meaning**

* Total bits observed = 15
* Error bits = 3
* BER ≈ 3/15 = 2×10⁻¹

### **How your UVM monitor should write this**

```systemverilog
int fd_ber;
initial fd_ber = $fopen("sim/logs/ber_log.csv","w");

always @(posedge clk) begin
   if (bit_error) $fwrite(fd_ber, "1\n");
   else           $fwrite(fd_ber, "0\n");
end
```

---

# ✅ **3) `lock_time.txt` — CDR lock time**

### **Purpose**

Used by `gen_stats.py` to report how fast your CDR locked.

### **Format (single number, in ns)**

```txt
125.40
```

### **How your UVM monitor should write this**

```systemverilog
time lock_start, lock_end;
int fd_lock;

initial fd_lock = $fopen("sim/logs/lock_time.txt","w");

always @(posedge clk) begin
   if (!lock && cdr_lock) begin
      lock_start = $time;
   end
   if (lock && !cdr_lock) begin
      lock_end = $time;
      $fwrite(fd_lock, "%0.2f\n", (lock_end - lock_start)/1ns);
      $fclose(fd_lock);
   end
end
```

---

# ✅ **4) `eye_ratio.txt` — eye-opening metric**

### **Purpose**

Used by `gen_stats.py` as a simple “eye quality” metric.

### **Format (single float between 0 and 1)**

```txt
0.732
```

### **Meaning**

* 0.73 → ~73% of samples had “good” margin (open eye)
* Higher = better signal integrity

### **How your RTL eye collector could write this**

```systemverilog
// From your eye_stats_collector.sv
final begin
   real ratio;
   ratio = (real'(eye_open_count) / sample_count);
   $display("Eye Opening Ratio = %f", ratio);

   int fd_eye = $fopen("sim/logs/eye_ratio.txt","w");
   $fwrite(fd_eye, "%f\n", ratio);
   $fclose(fd_eye);
end
```

---

# ✅ How everything fits together

| File               | Consumed by    | What it measures             |
| ------------------ | -------------- | ---------------------------- |
| `serial_trace.csv` | `plot_eye.py`  | Waveform shape → eye diagram |
| `ber_log.csv`      | `gen_stats.py` | Bit Error Rate               |
| `lock_time.txt`    | `gen_stats.py` | CDR lock latency             |
| `eye_ratio.txt`    | `gen_stats.py` | Eye opening quality          |

---


