```makefile
# ==========================================================
# Makefile for serdes_gpu_project
# ==========================================================

# -----------------------------
# Tool selection (default = iverilog)
# -----------------------------
SIM ?= iverilog   # options: iverilog | questa | vcs

# -----------------------------
# Directories
# -----------------------------
RTL_TOP   = rtl/top
RTL_PHY   = rtl/phy
RTL_PCS   = rtl/pcs
RTL_PROTO = rtl/protocol
RTL_ANA   = rtl/analysis

TB_TOP    = tb/top
TB_UVM    = tb/uvm
TB_SEQ    = tb/sequences

SIM_DIR   = sim
WAVE_DIR  = $(SIM_DIR)/waves
LOG_DIR   = $(SIM_DIR)/logs

# -----------------------------
# Files (automatically collect)
# -----------------------------
RTL_FILES = \
  $(wildcard $(RTL_TOP)/*.sv) \
  $(wildcard $(RTL_PHY)/*.sv) \
  $(wildcard $(RTL_PCS)/*.sv) \
  $(wildcard $(RTL_PROTO)/*.sv) \
  $(wildcard $(RTL_ANA)/*.sv)

TB_FILES = \
  $(wildcard $(TB_TOP)/*.sv) \
  $(wildcard $(TB_UVM)/*.sv) \
  $(wildcard $(TB_SEQ)/*.sv)

# -----------------------------
# Output
# -----------------------------
IV_OUT   = simv
VCD_FILE = $(WAVE_DIR)/serdes.vcd
LOG_FILE = $(LOG_DIR)/run.log

# -----------------------------
# Default target
# -----------------------------
all: prep run

# Create simulation directories
prep:
	mkdir -p $(WAVE_DIR)
	mkdir -p $(LOG_DIR)

# -----------------------------
# Run targets
# -----------------------------
run: p
```
