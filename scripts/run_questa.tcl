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
