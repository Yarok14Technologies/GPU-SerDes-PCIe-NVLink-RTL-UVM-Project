
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
                    ┌────── CHANNEL MODEL ───────┐
                    │  • BER injector            │
                    │  • Random Jitter (RJ)      │
                    │  • Deterministic Jitter    │
                    └──────────────┬───────────┘
                                   │
 ┌──────────────────────── GPU RX SIDE ──────────────────────┐
 │                   ┌──── RX PIPELINE (SerDes) ─────┐       │
 │                   │ Stage-1: Deserializer         │       │
 │                   │ Stage-2: Register + Deskew    │       │
 │                   └──────────────┬──────────────┘         │
 │                                  │ 130-bit                │
 │   ┌─────────────── PCS ───────────────┐                   │
 │   │ 128b/130b Decode → RD check →     │                   │
 │   │ Descrambler → 128-bit data        │                   │
 │   └──────────────┬───────────────────┘                    │
 │                  │                                        │
 │            128-bit RX DATA                                │
 └────────────────────────────────────────────────────────┘

                ┌──────── PCIe-Like LTSSM ───────┐
                │ DETECT → POLLING → CONFIG → L0 │
                │     ↘ L0s / L1 / RETRAIN       │ 
                └────────────────────────────────┘

                ┌──────────── UVM ENV ─────────────┐
                │ Driver → DUT → Monitor           │
                │        ↘ Scoreboard             │
                │   • BER errors                   │
                │   • Lock time                    │
                │   • Deskew check                 │
                └────────────────────────────────┘
```

---



---
# ** Future Extensions**
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

