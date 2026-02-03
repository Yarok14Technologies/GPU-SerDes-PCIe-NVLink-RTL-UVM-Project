`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_monitor extends uvm_monitor;

  `uvm_component_utils(serdes_monitor)

  // Analysis ports to scoreboard/coverage
  uvm_analysis_port #(serdes_item)  mon_ap;      // Data path
  uvm_analysis_port #(bit)          ber_ap;      // BER events
  uvm_analysis_port #(bit)          lock_ap;     // CDR lock status
  uvm_analysis_port #(int)          ltssm_ap;    // LTSSM state

  // Virtual interface (you should define this in your tb/top)
  virtual serdes_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap  = new("mon_ap", this);
    ber_ap  = new("ber_ap", this);
    lock_ap = new("lock_ap", this);
    ltssm_ap = new("ltssm_ap", this);
  endfunction

  // Build phase: get virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual serdes_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "serdes_monitor: virtual interface not set")
    end
  endfunction

  // Main monitor process
  task run_phase(uvm_phase phase);
    serdes_item item;

    forever begin
      @(posedge vif.clk);

      // Capture only when DUT is active (L0)
      if (vif.link_up) begin
        item = serdes_item::type_id::create("item");

        // Sample received parallel data
        item.rx_data = vif.rx_data;

        // Capture CDR lock
        item.cdr_lock = vif.cdr_lock;
        lock_ap.write(vif.cdr_lock);

        // Capture BER event
        item.ber_error = vif.ber_error;
        ber_ap.write(vif.ber_error);

        // Capture LTSSM state
        item.ltssm_state = vif.ltssm_state;
        ltssm_ap.write(vif.ltssm_state);

        // Send to scoreboard
        mon_ap.write(item);

        `uvm_info("MON",
          $sformatf("RX Data=0x%h | Lock=%0b | BER=%0b | LTSSM=%0d",
                     vif.rx_data, vif.cdr_lock, vif.ber_error, vif.ltssm_state),
          UVM_MEDIUM)
      end
    end
  endtask

endclass
