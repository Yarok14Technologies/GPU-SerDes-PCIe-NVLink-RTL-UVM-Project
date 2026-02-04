<!-- ======== PROJECT TITLE & BADGES ======== -->
# GPU-SerDes-PCIe-NVLink-RTL-UVM-Project

[![GitHub stars](https://img.shields.io/github/stars/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/network/members)
[![GitHub issues](https://img.shields.io/github/issues/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/commits)
[![GitHub license](https://img.shields.io/github/license/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/blob/main/LICENSE)



[![Coverage Status](https://img.shields.io/codecov/c/github/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)](https://codecov.io/gh/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)

[![Repo Size](https://img.shields.io/github/repo-size/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)]()
[![Contributors](https://img.shields.io/github/contributors/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)]()
[![Open PRs](https://img.shields.io/github/issues-pr/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project)]()



<!-- ======== PROJECT FEATURES ======== -->
![RTL](https://img.shields.io/badge/Language-SystemVerilog-blue)
![UVM](https://img.shields.io/badge/Verification-UVM-purple)
![Simulators](https://img.shields.io/badge/Simulators-Icarus%20%7C%20Questa%20%7C%20VCS-orange)
![Protocols](https://img.shields.io/badge/Protocols-PCIe%20%2F%20NVLink-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)


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

![Architecture](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/blob/main/Docs/architecture_diagram%202.png)
## **Directory Structure**

```
serdes_gpu_project/
│
├── README.md
├── LICENSE
├── .gitignore
├── Makefile
│
├── rtl/
│   │
│   ├── top/
│   │   ├── gpu_serdes_system.sv
│   │   └── gpu_serdes_top.sv
│   │
│   ├── phy/
│   │   ├── serdes_tx_pipeline.sv
│   │   ├── serdes_rx_pipeline.sv
│   │   ├── ber_channel.sv
│   │   ├── jitter_channel.sv
│   │   └── cdr_model.sv
│   │
│   ├── pcs/
│   │   ├── pcie_scrambler.sv
│   │   ├── pcie_128b130b_encode.sv
│   │   └── pcie_128b130b_decode.sv
│   │
│   ├── protocol/
│   │   ├── pcie_ltssm_full.sv
│   │   └── nvlink_framing_encode.sv
│   │   └── nvlink_framing_decode.sv
│   │
│   └── analysis/
│       └── eye_stats_collector.sv
│
├── tb/
│   │
│   ├── top/
│   │   └── serdes_tb_top.sv
│   │
│   ├── uvm/
│   │   ├── serdes_item.sv
│   │   ├── serdes_driver.sv
│   │   ├── serdes_monitor.sv
│   │   ├── serdes_agent.sv
│   │   ├── serdes_scoreboard.sv
│   │   ├── serdes_coverage.sv
│   │   ├── serdes_env.sv
│   │   └── serdes_test.sv
│   │
│   └── sequences/
│       ├── serdes_base_seq.sv
│       ├── ber_stress_seq.sv
│       └── retrain_seq.sv
│
├── scripts/
│   ├── run_iverilog.sh
│   ├── run_questa.tcl
│   └── run_vcs.sh
│
├── sim/
│   ├── waves/
│   │   └── serdes.vcd
│   └── logs/
│       └── run.log
│
├── docs/
│   ├── architecture_diagram.png
│   ├── serdes_eye_diagram.png
│   ├── bathtub_curve.png
│   ├── ltssm_state_diagram.png
│   └── interview_slides/
│       └── serdes_nvidia_interview_deck.pptx
│
└── tools/
    ├── plot_eye.py
    ├── plot_bathtub.py
    └── gen_stats.py
```
### System Architecture

![Architecture](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/blob/main/Docs/architecture_diagram%201.png)

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

### ltssm state diagram
![Architecture](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/blob/main/Docs/ltssm%20state%20diagram.png)

![Architecture](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/blob/main/Docs/LTSSM%20Overview.png)

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

## **Clean block diagram you can draw in interviews / slides**

```
 ┌──────────────────────── GPU FABRIC ────────────────────────┐
 │                                                            │
 │   128-bit TX DATA                                          │
 │        │                                                   │
 │   ┌─────────────── PCS ───────────────┐                    │
 │   │ Scrambler → 128b/130b Encode → RD │                    │
 │   └───────────────┬──────────────────┘                     │
 │                   │ 130-bit                                │
 │           ┌────── TX PIPELINE (SerDes) ──────┐             │
 │           │ Stage-1: Gearbox/Register       │              │
 │           │ Stage-2: Serializer (Shift Reg) │              │
 │           └──────────────┬──────────────────┘              │
 │                          │ 1-bit serial                    │
 └──────────────────────────┼───────────────────────────────  ┘
                            │
                    ┌────── CHANNEL MODEL ────────┐
                    │  • BER injector             │
                    │  • Random Jitter (RJ)       │
                    │  • Deterministic Jitter     │
                    └──────────────┬──────────────┘
                                   │
 ┌──────────────────────── GPU RX SIDE ──────────────────────┐
 │                   ┌──── RX PIPELINE (SerDes) ──────┐      │
 │                   │ Stage-1: Deserializer          │      │
 │                   │ Stage-2: Register + Deskew     │      │
 │                   └──────────────┬─────────────────┘      │
 │                                  │ 130-bit                │
 │   ┌─────────────── PCS ───────────────┐                   │
 │   │ 128b/130b Decode → RD check →     │                   │
 │   │ Descrambler → 128-bit data        │                   │
 │   └──────────────┬────────────────────┘                   │
 │                  │                                        │
 │            128-bit RX DATA                                │
 └───────────────────────────────────────────────────────────┘

                ┌──────── PCIe-Like LTSSM ─────────┐
                │ DETECT → POLLING → CONFIG → L0   │
                │    ↘ L0s / L1 / RETRAIN         
                └──────────────────────────────────┘

                ┌──────────── UVM ENV ─────────────┐
                │ Driver → DUT → Monitor           │
                │        ↘ Scoreboard             
                │   • BER errors                   │
                │   • Lock time                    │
                │   • Deskew check                 │
                └──────────────────────────────────┘
```

---



---
## Future Extensions
# =========================================================

# **1) FULL PCIe LTSSM (L2, L3, RECOVERY) – RTL**

# =========================================================

This is a closer-to-spec PCIe-style LTSSM (still behavioral, but architecturally faithful).

```systemverilog
module pcie_ltssm_full (
    input  logic clk,
    input  logic rst_n,
    input  logic training_req,
    input  logic idle_req,
    input  logic error_detected,
    output logic link_up,
    output logic [3:0] state
);

    typedef enum logic [3:0] {
        DETECT   = 4'b0000,
        POLLING  = 4'b0001,
        CONFIG   = 4'b0010,
        L0       = 4'b0011,
        L0s      = 4'b0100,
        L1       = 4'b0101,
        L2       = 4'b0110,
        L3       = 4'b0111,
        RECOVERY = 4'b1000,
        RETRAIN  = 4'b1001
    } ltssm_t;

    ltssm_t curr, next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr <= DETECT;
        else
            curr <= next;
    end

    always_comb begin
        next = curr;
        case (curr)
            DETECT:   next = POLLING;
            POLLING:  next = CONFIG;
            CONFIG:   next = L0;

            L0: begin
                if (idle_req)       next = L0s;
                if (training_req)   next = RETRAIN;
                if (error_detected) next = RECOVERY;
            end

            L0s: begin
                if (!idle_req) next = L0;
                if (error_detected) next = RECOVERY;
            end

            L1: begin
                if (training_req) next = RETRAIN;
                if (error_detected) next = RECOVERY;
            end

            L2: begin
                if (!idle_req) next = L0;
            end

            L3: begin
                if (!rst_n) next = DETECT;
            end

            RECOVERY: next = POLLING;
            RETRAIN : next = POLLING;
        endcase
    end

    assign state   = curr;
    assign link_up = (curr == L0);

endmodule
```

**What this adds vs your previous FSM**

* **L2** (deep power save)
* **L3** (off state)
* **RECOVERY** state for error handling
* Clear transitions for **retrain, idle, and error**

---

# =========================================================

# **2) REALISTIC CDR LOOP MODEL (BEHAVIORAL)**

# =========================================================

This is a **control-loop style CDR model** (not analog, but conceptually correct).

```systemverilog
module cdr_model (
    input  logic clk,
    input  logic rst_n,
    input  logic serial_in,
    output logic recovered_clk,
    output logic lock
);

    real phase_error;
    real phase_adjust;
    real kp = 0.05;   // proportional gain
    real ki = 0.01;   // integral gain
    real integrator;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_adjust <= 0.0;
            integrator   <= 0.0;
            lock         <= 0;
        end else begin
            // Simple bang-bang phase detector (behavioral)
            phase_error = (serial_in) ? 0.02 : -0.02;

            integrator   <= integrator + ki * phase_error;
            phase_adjust <= kp * phase_error + integrator;

            // Lock detection (small steady-state error)
            if (abs(phase_error) < 0.005)
                lock <= 1;
        end
    end

    // Recovered clock = base clk + phase adjustment (abstracted)
    assign recovered_clk = clk;

endmodule
```

**Interview-friendly explanation:**

> “The CDR uses a phase detector + loop filter (PI control) to minimize phase error and align the sampling clock to the center of the eye.”

---

# =========================================================

# **3) NVLINK-STYLE COHERENT FRAMING (BEHAVIORAL)**

# =========================================================

NVLink uses **flits/packets** with headers, sequence numbers, and coherence bits.

## NVLink-like flit format (simplified)

```
[127:120]  Coherence/Protocol
[119: 96]  Sequence ID
[95 :  0]  Payload
```

### Encoder

```systemverilog
module nvlink_framing_encode (
    input  logic clk,
    input  logic rst_n,
    input  logic [95:0] payload,
    input  logic [7:0]  coh_bits,
    output logic [127:0] flit_out
);

    logic [23:0] seq;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            seq <= 0;
        else
            seq <= seq + 1;
    end

    always_comb begin
        flit_out = {coh_bits, seq, payload};
    end
endmodule
```

### Decoder + Coherence Check

```systemverilog
module nvlink_framing_decode (
    input  logic [127:0] flit_in,
    output logic [95:0] payload,
    output logic [7:0]  coh_bits,
    output logic [23:0] seq,
    output logic seq_error
);

    logic [23:0] last_seq;

    assign coh_bits = flit_in[127:120];
    assign seq      = flit_in[119:96];
    assign payload  = flit_in[95:0];

    always_comb begin
        seq_error = (seq != last_seq + 1);
    end

endmodule
```

**Key NVLink ideas captured:**

* Sequence tracking
* Coherence metadata
* Ordered delivery detection

---

# =========================================================

# **4) STATISTICAL EYE DIAGRAM GENERATION (SV MODEL)**

# =========================================================

Instead of plotting externally, this **collects eye statistics in RTL**.

```systemverilog
module eye_stats_collector (
    input  logic clk,
    input  logic rst_n,
    input  logic serial_in
);

    integer sample_count;
    integer eye_open_count;
    real voltage_sample;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_count   <= 0;
            eye_open_count <= 0;
        end else begin
            sample_count++;

            // Simple eye metric: assume '1' = high margin, '0' = low margin
            if (serial_in)
                eye_open_count++;
        end
    end

    final begin
        $display("Total Samples = %0d", sample_count);
        $display("Eye Opening Ratio = %f",
                 (real'(eye_open_count) / sample_count));
    end

endmodule
```

**How to use in practice:**

* Connect this to `serial_corrupt` output
* Higher **eye_open_ratio ≈ better signal integrity**

If you want, I can:

* add UI binning, or
* auto-generate a **PNG eye plot via Python**.

---

# =========================================================

# **5) COVERAGE-DRIVEN UVM TEST SUITE**

# =========================================================

## Coverage object

```systemverilog
class serdes_coverage extends uvm_component;
  `uvm_component_utils(serdes_coverage)

  covergroup cg;
    coverpoint dut_state {
        bins DETECT  = {0};
        bins POLLING = {1};
        bins CONFIG  = {2};
        bins L0      = {3};
        bins L0s     = {4};
        bins L1      = {5};
        bins L2      = {6};
        bins L3      = {7};
        bins RECOVERY= {8};
    }

    coverpoint dut_lock {
        bins locked   = {1};
        bins unlocked = {0};
    }

    coverpoint ber_event {
        bins error = {1};
        bins clean = {0};
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #1000;
    cg.sample();
    phase.drop_objection(this);
  endtask
endclass
```

## Integrate into environment

```systemverilog
class serdes_env extends uvm_env;
  serdes_agent agent;
  serdes_scoreboard sb;
  serdes_coverage  cov;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = serdes_agent::type_id::create("agent", this);
    sb    = serdes_scoreboard::type_id::create("sb", this);
    cov   = serdes_coverage::type_id::create("cov", this);
  endfunction
endclass
```

## Coverage-driven test

```systemverilog
class serdes_cov_test extends uvm_test;
  serdes_env env;
  `uvm_component_utils(serdes_cov_test)

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = serdes_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #2000;
    phase.drop_objection(this);
  endtask
endclass
```

---

# What you now have (summary)

| Feature            | What you can claim in interviews                       |
| ------------------ | ------------------------------------------------------ |
| **Full LTSSM**     | You modeled L0/L0s/L1/L2/L3 + Recovery                 |
| **CDR loop**       | You understand phase detection + PI control            |
| **NVLink framing** | You modeled coherent flits + sequence tracking         |
| **Eye stats**      | You can quantify signal quality in RTL                 |
| **Coverage UVM**   | You built functional coverage for link states + errors |

---

**clear, data-centric explanation of how data is managed in your SerDes architecture (as per your repo structure)** — from source to sink, including integrity, timing, and reliability handling.

---

## **1) Data Management — Transmitter Side (TX Path)**

### **A. Protocol & Framing Layer (PCS → Protocol)**

📂 **Your files involved:**

* `pcie_128b130b_encode.sv`
* `pcie_scrambler.sv`
* `nvlink_framing_encode.sv`
* `pcie_ltssm_full.sv`

👉 **How data is handled:**

1. **Packetization / Framing**

   * Higher-layer data (PCIe or NVLink transactions) is first framed.
   * NVLink/PCIe packets are segmented into transmission-friendly blocks.

2. **Encoding (128b/130b)**

   * Raw 128-bit payload → encoded into 130-bit symbol.
   * **Purpose:**

     * Guarantee enough transitions for clock recovery
     * Embed control characters (ordered sets, SKP, idle, etc.)
     * Enable error detection

3. **Scrambling**

   * Bit scrambling randomizes the data pattern.
   * Prevents long runs of 0s or 1s.
   * Reduces EMI and improves signal integrity.

🔹 **Data state at this point:**

> Structured, encoded, and randomized digital words ready for serialization.

---

## **2) PHY Layer — Serialization & Channel**

📂 **Your files:**

* `serdes_tx_pipeline.sv`
* `ber_channel.sv`
* `jitter_channel.sv`

### **A. Serializer (TX)**

* Converts parallel 130-bit words → high-speed serial bitstream.
* Manages:

  * Bit ordering (MSB → LSB or LSB → MSB as designed)
  * Lane alignment (if multi-lane extension is later added)

🔹 **Data state:**

> High-speed serial stream.

### **B. Channel Model (What happens to data in flight)**

You explicitly model impairments in:

* `ber_channel.sv` → **Bit Errors**
* `jitter_channel.sv` → **Timing noise**

Your channel manages:

* Random bit flips (BER stress testing)
* Timing jitter (edge uncertainty)
* Potential inter-symbol interference (if extended later)

🔹 **Key idea:**

> Data is not assumed “perfect” — your testbench can inject realistic corruption.

---

## **3) Receiver Side — Recovery & Integrity (RX Path)**

📂 **Your files:**

* `cdr_model.sv`
* `serdes_rx_pipeline.sv`
* `pcie_128b130b_decode.sv`

### **A. Clock & Data Recovery (CDR)**

The CDR:

* Reconstructs clock from incoming data transitions.
* Aligns sampling point to eye center.
* Compensates for jitter.

🔹 **Data state:**

> Cleaned-up sampled serial bits.

### **B. Deserializer**

* Converts serial stream → parallel 130-bit words.
* Maintains word boundary using alignment markers (from 128b/130b encoding).

🔹 **Data state:**

> Parallel encoded data words.

### **C. Decoding & Descrambling**

* 130b → 128b payload recovered.
* Scrambler is reversed.
* Invalid symbols can be flagged.

🔹 **Data state:**

> Original payload (with error flags if corruption occurred).

---

## **4) Buffering & Flow Control (Data Management Core)**

📂 **Likely inside:**

* `serdes_rx_pipeline.sv`
* `gpu_serdes_system.sv`

### **FIFO Buffer**

Your design includes a **FIFO at the receiver** (as shown in the architecture image).

The FIFO manages:

* Clock domain crossing (if TX and RX clocks differ)
* Burst absorption
* Backpressure handling (in future extension)
* Data rate mismatch smoothing

🔹 **Final data state:**

> Reliable, time-aligned data available for higher layers (PCIe/NVLink stack).

---

## **5) Error & Quality Management (Very important in your repo)**

📂 **Your analysis tools:**

* `eye_stats_collector.sv`
* `plot_eye.py`
* `plot_bathtub.py`

Your system manages data quality via:

* **BER tracking**
* **Eye diagram monitoring**
* **Bathtub curve analysis (timing margin vs BER)**

This means:

* You don’t just *send data* — you **measure how healthy the data path is.**
* This is exactly how real GPU SerDes (NVIDIA/AMD) systems operate.

![SERDES in GPU Architecture with BER and Jitter Noise](https://github.com/Yarok14Technologies/GPU-SerDes-PCIe-NVLink-RTL-UVM-Project/blob/main/Docs/SERDES%20in%20GPU%20Architecture%20with%20BER%20and%20Jitter%20Noise.png)


---

## **One-line summary of “How data is managed”**

> **Framed → Encoded → Scrambled → Serialized → (Noisy Channel) → Recovered (CDR) → Deserialized → Decoded → Buffered → Quality-checked.**

---

 **Heart of real SerDes design and validation.**
In your project, **BER and Jitter are not “features of the link” — they are *intentional stress models* to make your SerDes realistic and testable.**

Here is the clear technical reason, mapped to your repo.

---

# **Why BER and Jitter are used in your SerDes?**

## ✅ **Short answer**

👉 **To model real-world channel impairments and verify that your SerDes is robust, reliable, and recoverable — just like in real GPUs (NVIDIA/AMD).**

You are essentially **testing: “Will my SerDes still work under imperfect, noisy conditions?”**

---

# **1) Why BER (Bit Error Rate) is used — `ber_channel.sv`**

### **Purpose: Reliability Testing**

In the real world, bits get corrupted due to:

* Thermal noise
* Crosstalk
* Signal attenuation
* Interference
* Power supply noise
* Manufacturing variations

Your **BER model injects random bit flips** into the serial stream.

### What this allows you to validate:

Your BER model helps you test:

1. **Error tolerance of the link**

   * How many bit errors can your system tolerate?
   * Does the receiver still lock?

2. **Effectiveness of encoding (128b/130b)**

   * 128b/130b encoding helps detect errors.
   * With BER injection, you can verify:

     * Are corrupted symbols detected?
     * Are illegal codes flagged?

3. **Impact on FIFO & higher layers**

   * Does your FIFO overflow under error conditions?
   * Does the system stall or recover?

### In one line:

> **BER is used to test DATA INTEGRITY under noisy conditions.**

---

# **2) Why Jitter is used — `jitter_channel.sv`**

### **Purpose: Timing Robustness Testing**

In a real SerDes channel, edges of the signal are **never perfectly periodic** due to:

* Clock instability
* PCB trace variations
* Temperature drift
* Power noise
* Inter-symbol interference (ISI)

Your jitter model introduces **timing uncertainty** to the edges.

### What this allows you to validate:

1. **Clock and Data Recovery (CDR) performance**
   Your `cdr_model.sv` must:

* Track clock from noisy data
* Find the optimal sampling point (center of the eye)
* Adapt to changing timing conditions

Without jitter:

* CDR is trivial → not realistic
* Your design would look “perfect on paper” but fail in silicon

2. **Eye opening robustness**
   Jitter shrinks the eye diagram.
   You can analyze:

* Eye height (noise margin)
* Eye width (timing margin)
* Bathtub curve (BER vs timing offset)

### In one line:

> **Jitter is used to test TIMING RECOVERY and CDR robustness.**

---

# **3) Why BOTH together (BER + Jitter)? — This is key**

Real channels don’t have only bit errors or only jitter — they have **both simultaneously.**

Using both lets you test:

* Worst-case combined stress:

  * Bad timing + random bit flips
* Whether your SerDes:

  * Loses lock
  * Recovers gracefully
  * Needs retraining (`retrain_seq.sv` in your TB)

This is exactly why you also have:

* `ber_stress_seq.sv`
* `retrain_seq.sv`

You are not just simulating — you are **validating a resilient link.**

---

# **4) How this maps to your repo (clean mapping)**

| File                     | Why BER/Jitter matters here      |
| ------------------------ | -------------------------------- |
| `serdes_tx_pipeline.sv`  | Must produce clean transitions   |
| `ber_channel.sv`         | Injects realistic bit corruption |
| `jitter_channel.sv`      | Distorts timing of edges         |
| `cdr_model.sv`           | Must recover clock under jitter  |
| `serdes_rx_pipeline.sv`  | Must still deserialize correctly |
| `eye_stats_collector.sv` | Measures impact of BER & jitter  |
| `plot_eye.py`            | Visualizes effect of jitter      |
| `plot_bathtub.py`        | Shows BER vs timing margin       |

---

# **Interview-ready one-liner (you can say this):**

> *“BER models data corruption in the channel, while jitter models timing uncertainty. Together, they stress the SerDes so we can validate CDR performance, decoding reliability, and link robustness under realistic operating conditions.”*

---



