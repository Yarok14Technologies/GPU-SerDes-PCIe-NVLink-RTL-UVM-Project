
# GPU SerDes (PCIe/NVLink) – RTL & UVM Project

<!-- ======== DYNAMIC GITHUB BADGES ======== -->
[![GitHub stars](https://img.shields.io/github/stars/Yarok14Technologies/serdes_gpu)](https://github.com/Yarok14Technologies/serdes_gpu/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Yarok14Technologies/serdes_gpu)](https://github.com/Yarok14Technologies/serdes_gpu/network/members)
[![GitHub issues](https://img.shields.io/github/issues/Yarok14Technologies/serdes_gpu)](https://github.com/Yarok14Technologies/serdes_gpu/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/Yarok14Technologies/serdes_gpu)](https://github.com/Yarok14Technologies/serdes_gpu/commits)
[![GitHub license](https://img.shields.io/github/license/Yarok14Technologies/serdes_gpu)](https://github.com/Yarok14Technologies/serdes_gpu/blob/main/LICENSE)

<!-- ======== PROJECT FEATURES ======== -->
![RTL](https://img.shields.io/badge/Language-SystemVerilog-blue)
![UVM](https://img.shields.io/badge/Verification-UVM-purple)
![Simulators](https://img.shields.io/badge/Simulators-Icarus%20%7C%20Questa%20%7C%20VCS-orange)
![Protocols](https://img.shields.io/badge/Protocols-PCIe%20%2F%20NVLink-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)


# **GPU SerDes (PCIe/NVLink) – RTL & UVM Project**

## **Overview**

This repository contains a **behavioral-to-architectural RTL model of a GPU-style SerDes subsystem**, including:

* Pipelined **TX/RX SerDes** model
* **128b/130b encoding/decoding** with scrambling and running disparity
* **PCIe-like LTSSM (Link Training and Status State Machine)**
* **BER + Jitter channel model** (RJ/DJ + UI sampling abstraction)
* **Full UVM verification environment** with scoreboard
* Multi-lane, multi-stage pipeline structure (GPU-like)

This project is suitable for:

* Interviews (NVIDIA / Qualcomm / AMD / Intel)
* Advanced VLSI/RTL coursework
* SystemVerilog + UVM learning
* High-speed interconnect research demos

---

## **Directory Structure**

```
serdes_gpu/
│
├── README.md
├── Makefile
│
├── rtl/
│   ├── gpu_serdes_system.sv
│   ├── serdes_tx_pipeline.sv
│   ├── serdes_rx_pipeline.sv
│   ├── pcie_128b130b_encode.sv
│   ├── pcie_128b130b_decode.sv
│   ├── pcie_scrambler.sv
│   ├── jitter_channel.sv
│   └── pcie_ltssm.sv
│
├── tb/
│   ├── serdes_tb_top.sv
│   ├── uvm_env.sv
│   ├── serdes_driver.sv
│   ├── serdes_monitor.sv
│   ├── serdes_agent.sv
│   └── serdes_scoreboard.sv
│
├── scripts/
│   ├── run_iverilog.sh
│   └── run_questa.tcl
│
└── docs/
    ├── architecture_diagram.png
    └── eye_diagram.png
```

---

## **Key Features**

### ✅ 1) GPU-Style Pipelined SerDes

* Multi-stage TX/RX pipeline
* Gearbox abstraction
* Clock/Data Recovery (CDR) behavioral model
* Lane lock detection

### ✅ 2) Realistic 128b/130b PCS Layer

* Self-synchronizing scrambler
* Running disparity control
* Header-based encoding
* Basic disparity error detection

### ✅ 3) PCIe-Like LTSSM (Link Training FSM)

States implemented:

* DETECT
* POLLING
* CONFIG
* **L0 (Active)**
* L0s (Low power idle)
* L1 (Sleep)
* RETRAIN

### ✅ 4) BER + Jitter Channel Model

* Bit Error Rate (BER) injector
* Random Jitter (RJ) model
* Deterministic Jitter (DJ) model
* UI-based sampling abstraction

### ✅ 5) UVM Verification Environment

Includes:

* Sequence Item
* Driver
* Monitor
* Agent
* Environment
* Test
* **Scoreboard tracking:**

  * BER errors
  * Lock time
  * Deskew status

---

## **How to Run (Quick Start)**

### Using Icarus Verilog:

```bash
bash scripts/run_iverilog.sh
```

### Using Questa/ModelSim:

```tcl
do scripts/run_questa.tcl
```

---

## **What This Models (and What It Does NOT)**

### ✔️ Modeled (Behavioral/Architectural)

* PCS layer behavior
* Link training states
* Pipeline timing
* Error injection and monitoring
* Functional verification flow

### ❌ Not Modeled (Analog/Device Level)

* True PLL/CDR analog circuits
* Transistor-level TX driver / RX front-end
* Real channel impedance modeling
* True clock recovery loop dynamics

---

## **Interview Relevance**

If asked, you can say:

> “This project models a GPU-style SerDes with a realistic PCS (128b/130b + scrambler + disparity), a PCIe-like LTSSM, and a UVM verification environment including BER and jitter injection. It demonstrates end-to-end understanding from protocol to PHY abstraction and verification.”

---

## **Future Extensions (Optional)**

You can extend this with:

* Full PCIe LTSSM (L2, L3, Recovery)
* Realistic CDR loop model
* NVLink-style coherent framing
* Statistical eye diagram generation
* Coverage-driven UVM test suite

---

## **Author**

Bibin N. B.
High-Speed Interconnect & RTL Enthusiast



## **Installation & Setup (New Section ✅)**

### **1) Prerequisites**

You need **one** of the following simulators:

#### Option A — Open-source (Recommended for students)

* **Icarus Verilog + GTKWave**

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

Verify:

```bash
iverilog -V
gtkwave -V
```

#### Option B — Industry simulators (if available)

* **Questa/ModelSim** or **VCS**
* Ensure `vsim` or `vcs` is in your `$PATH`.

---

### **2) Clone the Repository**

```bash
git clone https://github.com/your-username/serdes_gpu.git
cd serdes_gpu
```

*(Replace `your-username` with your actual GitHub handle when you create the repo.)*

---

### **3) Compile & Run with Icarus (Quick Start)**

Make the script executable (first time only):

```bash
chmod +x scripts/run_iverilog.sh
```

Run simulation:

```bash
bash scripts/run_iverilog.sh
```

This will:

* Compile all RTL + UVM files
* Run the `serdes_test`
* Generate a VCD waveform (`serdes.vcd`)

To view waveforms:

```bash
gtkwave serdes.vcd
```

---

### **4) Run with Questa/ModelSim**

From project root:

```tcl
vsim -do scripts/run_questa.tcl
```

Inside Questa:

```
run -all
```

---

### **5) (Optional) Add UVM Path (if simulator can’t find UVM)**

If you see errors like `cannot find uvm_pkg`, set your UVM path:

```bash
export UVM_HOME=/path/to/uvm
export UVM_DPI_HOME=$UVM_HOME/lib
```

Or in Questa, add:

```tcl
vlib work
vlog +incdir+$UVM_HOME/src $UVM_HOME/src/uvm_pkg.sv
```

---

### **6) Running Specific Tests**

To run a different UVM test (example):

```bash
iverilog -g2012 -DUVM_NO_DPI -s top -o simv \
  rtl/*.sv tb/*.sv +UVM_TESTNAME=serdes_my_custom_test
```

---

## **Key Features**

### ✅ 1) GPU-Style Pipelined SerDes

* Multi-stage TX/RX pipeline
* Gearbox abstraction
* Clock/Data Recovery (CDR) behavioral model
* Lane lock detection

### ✅ 2) Realistic 128b/130b PCS Layer

* Self-synchronizing scrambler
* Running disparity control
* Header-based encoding
* Basic disparity error detection

### ✅ 3) PCIe-Like LTSSM (Link Training FSM)

States implemented:

* DETECT
* POLLING
* CONFIG
* **L0 (Active)**
* L0s (Low power idle)
* L1 (Sleep)
* RETRAIN

### ✅ 4) BER + Jitter Channel Model

* Bit Error Rate (BER) injector
* Random Jitter (RJ) model
* Deterministic Jitter (DJ) model
* UI-based sampling abstraction

### ✅ 5) UVM Verification Environment

Includes:

* Sequence Item
* Driver
* Monitor
* Agent
* Environment
* Test
* **Scoreboard tracking:**

  * BER errors
  * Lock time
  * Deskew status

---

## **What This Models (and What It Does NOT)**

### ✔️ Modeled (Behavioral/Architectural)

* PCS layer behavior
* Link training states
* Pipeline timing
* Error injection and monitoring
* Functional verification flow

### ❌ Not Modeled (Analog/Device Level)

* True PLL/CDR analog circuits
* Transistor-level TX driver / RX front-end
* Real channel impedance modeling
* True clock recovery loop dynamics

---

## **Interview Relevance**

If asked, you can say:

> “This project models a GPU-style SerDes with a realistic PCS (128b/130b + scrambler + disparity), a PCIe-like LTSSM, and a UVM verification environment including BER and jitter injection. It demonstrates end-to-end understanding from protocol to PHY abstraction and verification.”

---

