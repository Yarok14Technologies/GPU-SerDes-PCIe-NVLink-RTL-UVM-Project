# ✅ **serdes_gpu_project Simulation Scripts**
---

# ✅ **1) `scripts/run_iverilog.sh`**

```bash
#!/bin/bash
# ============================================================
# Run Icarus Verilog + UVM for serdes_gpu_project
# ============================================================

set -e

PROJ_ROOT=$(pwd)
RTL_DIR="$PROJ_ROOT/rtl"
TB_DIR="$PROJ_ROOT/tb"
SIM_DIR="$PROJ_ROOT/sim"
WAVE_DIR="$SIM_DIR/waves"
LOG_DIR="$SIM_DIR/logs"

# Create sim dirs if not present
mkdir -p $WAVE_DIR
mkdir -p $LOG_DIR

UVM_HOME=${UVM_HOME:-"/usr/share/iverilog/uvm"}  # change if needed

echo "Compiling RTL + TB with Icarus..."

iverilog -g2012 \
  -DUVM_NO_DPI \
  -I$UVM_HOME/src \
  -I$RTL_DIR/top \
  -I$RTL_DIR/phy \
  -I$RTL_DIR/pcs \
  -I$RTL_DIR/protocol \
  -I$RTL_DIR/analysis \
  -I$TB_DIR/top \
  -I$TB_DIR/uvm \
  -I$TB_DIR/sequences \
  $UVM_HOME/src/uvm_pkg.sv \
  $RTL_DIR/top/*.sv \
  $RTL_DIR/phy/*.sv \
  $RTL_DIR/pcs/*.sv \
  $RTL_DIR/protocol/*.sv \
  $RTL_DIR/analysis/*.sv \
  $TB_DIR/top/*.sv \
  $TB_DIR/uvm/*.sv \
  $TB_DIR/sequences/*.sv \
  -o $SIM_DIR/serdes_simv

echo "Running simulation..."
vvp $SIM_DIR/serdes_simv | tee $LOG_DIR/run.log

echo "Dumping waveform to $WAVE_DIR/serdes.vcd"
echo "$dumpfile(\"$WAVE_DIR/serdes.vcd\"); $dumpvars(0, top);" > $SIM_DIR/dump.v

echo "Done. Open waves with: gtkwave sim/waves/serdes.vcd"
```

Make executable once:

```bash
chmod +x scripts/run_iverilog.sh
```

Run:

```bash
bash scripts/run_iverilog.sh
```

---

# ✅ **2) `scripts/run_questa.tcl`**

```tcl
# ============================================================
# Questa/ModelSim script for serdes_gpu_project
# ============================================================

vlib work
vmap work work

# Set UVM path (edit if needed)
set UVM_HOME $env(UVM_HOME)

vlog +acc \
  +incdir+rtl/top \
  +incdir+rtl/phy \
  +incdir+rtl/pcs \
  +incdir+rtl/protocol \
  +incdir+rtl/analysis \
  +incdir+tb/top \
  +incdir+tb/uvm \
  +incdir+tb/sequences \
  +incdir+$UVM_HOME/src \
  $UVM_HOME/src/uvm_pkg.sv \
  rtl/top/*.sv \
  rtl/phy/*.sv \
  rtl/pcs/*.sv \
  rtl/protocol/*.sv \
  rtl/analysis/*.sv \
  tb/top/*.sv \
  tb/uvm/*.sv \
  tb/sequences/*.sv

vsim -voptargs=+acc work.top

add wave -r /*

run -all

# Save waveform
wlf2vcd vsim.wlf sim/waves/serdes.vcd

quit
```

Run:

```bash
vsim -do scripts/run_questa.tcl
```

---

# ✅ **3) `scripts/run_vcs.sh`**

```bash
#!/bin/bash
# ============================================================
# Synopsys VCS script for serdes_gpu_project
# ============================================================

set -e

PROJ_ROOT=$(pwd)
RTL_DIR="$PROJ_ROOT/rtl"
TB_DIR="$PROJ_ROOT/tb"
SIM_DIR="$PROJ_ROOT/sim"
WAVE_DIR="$SIM_DIR/waves"
LOG_DIR="$SIM_DIR/logs"

mkdir -p $WAVE_DIR
mkdir -p $LOG_DIR

UVM_HOME=${UVM_HOME:-"/path/to/uvm"}  # <-- CHANGE THIS

echo "Compiling with VCS..."

vcs -full64 -sverilog +acc \
  +incdir+$UVM_HOME/src \
  +incdir+rtl/top \
  +incdir+rtl/phy \
  +incdir+rtl/pcs \
  +incdir+rtl/protocol \
  +incdir+rtl/analysis \
  +incdir+tb/top \
  +incdir+tb/uvm \
  +incdir+tb/sequences \
  $UVM_HOME/src/uvm_pkg.sv \
  rtl/top/*.sv \
  rtl/phy/*.sv \
  rtl/pcs/*.sv \
  rtl/protocol/*.sv \
  rtl/analysis/*.sv \
  tb/top/*.sv \
  tb/uvm/*.sv \
  tb/sequences/*.sv \
  -o $SIM_DIR/serdes_simv

echo "Running simulation..."
$SIM_DIR/serdes_simv +UVM_TESTNAME=serdes_test | tee $LOG_DIR/run.log

echo "Dumping VCD..."
vcd2wlf $WAVE_DIR/serdes.vcd

echo "Done."
```

Make executable:

```bash
chmod +x scripts/run_vcs.sh
```

Run:

```bash
bash scripts/run_vcs.sh
```

---

