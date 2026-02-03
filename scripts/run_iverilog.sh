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
