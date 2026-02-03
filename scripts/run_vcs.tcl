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
