`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_agent extends uvm_agent;
  `uvm_component_utils(serdes_agent)

  // Handles to sub-components
  serdes_driver   drv;
  serdes_monitor  mon;
  uvm_sequencer #(serdes_item) seqr;

  // Configuration knob: active or passive agent
  bit is_active = 1;

  function new(string name = "serdes_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: create components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (is_active) begin
      seqr = uvm_sequencer #(serdes_item)::type_id::create("seqr", this);
      drv  = serdes_driver::type_id::create("drv", this);
    end

    mon = serdes_monitor::type_id::create("mon", this);
  endfunction

  // Connect phase: hook up driver to sequencer
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction

endclass
