`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_coverage extends uvm_component;
  `uvm_component_utils(serdes_coverage)

  // Handles to signals sampled from DUT (via monitor or virtual interface)
  virtual interface serdes_if vif;

  // Coverage knobs (can be overridden via UVM config DB)
  int SAMPLE_WINDOW = 2000;

  // ---------------- COVERGROUP ----------------
  covergroup cg_serdes @(posedge vif.clk);

    // 1) LTSSM State Coverage (full PCIe-like LTSSM)
    coverpoint vif.ltssm_state {
      bins DETECT   = {0};
      bins POLLING  = {1};
      bins CONFIG   = {2};
      bins L0       = {3};
      bins L0s      = {4};
      bins L1       = {5};
      bins L2       = {6};
      bins L3       = {7};
      bins RECOVERY = {8};
      bins RETRAIN  = {9};
    }

    // 2) Link Lock Coverage
    coverpoint vif.link_lock {
      bins locked   = {1};
      bins unlocked = {0};
    }

    // 3) BER Event Coverage
    coverpoint vif.ber_event {
      bins clean_cycle = {0};
      bins error_cycle = {1};
    }

    // 4) Lock Time Bins (performance-oriented coverage)
    coverpoint vif.lock_time_ns {
      bins fast_lock   = {[0:100]};
      bins medium_lock = {[101:500]};
      bins slow_lock   = {[501:1000]};
      bins timeout     = {[1001:$]};
    }

    // 5) Deskew Status Coverage (multi-lane alignment)
    coverpoint vif.deskew_ok {
      bins aligned   = {1};
      bins misaligned = {0};
    }

    // 6) Cross Coverage: LTSSM x BER (important corner cases)
    cross vif.ltssm_state, vif.ber_event;

    // 7) Cross Coverage: Lock x BER
    cross vif.link_lock, vif.ber_event;

  endgroup

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_serdes = new();
  endfunction

  // Build phase: get virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual serdes_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("COVCFG", "Virtual interface serdes_if not set for serdes_coverage")
    end
  endfunction

  // Run phase: sample coverage over a window
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    repeat (SAMPLE_WINDOW) begin
      @(posedge vif.clk);
      cg_serdes.sample();
    end

    `uvm_info("COVERAGE",
      $sformatf("Coverage window completed: %0d cycles", SAMPLE_WINDOW),
      UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass
