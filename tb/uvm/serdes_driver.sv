// ============================================================================
// File: tb/uvm/serdes_driver.sv
// Description: UVM Driver for GPU SerDes DUT
// ============================================================================

`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_driver extends uvm_driver #(serdes_item);

  `uvm_component_utils(serdes_driver)

  // Virtual interface to DUT (you should define this in your tb/top)
  virtual interface serdes_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: get virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual serdes_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not set for serdes_driver")
    end
  endfunction

  // Main run phase
  virtual task run_phase(uvm_phase phase);
    serdes_item item;

    // Initialize DUT signals
    vif.tx_valid   <= 0;
    vif.tx_data    <= '0;
    vif.training_req <= 0;
    vif.idle_req     <= 0;

    forever begin
      seq_item_port.get_next_item(item);

      // Drive stimulus based on item type
      case (item.kind)

        SERDES_NORMAL: begin
          drive_normal(item);
        end

        SERDES_BER_STRESS: begin
          drive_ber_stress(item);
        end

        SERDES_RETRAIN: begin
          drive_retrain(item);
        end

        default: begin
          `uvm_warning("DRV", "Unknown transaction type, defaulting to normal")
          drive_normal(item);
        end

      endcase

      seq_item_port.item_done();
    end
  endtask

  // ------------------------------------------------------------
  // Task: Normal traffic
  // ------------------------------------------------------------
  task drive_normal(serdes_item item);
    vif.tx_data  <= item.data;
    vif.tx_valid <= 1;
    vif.training_req <= 0;
    vif.idle_req <= 0;

    repeat (item.num_cycles) @(posedge vif.clk);

    vif.tx_valid <= 0;
  endtask

  // ------------------------------------------------------------
  // Task: BER stress (inject errors in channel)
  // ------------------------------------------------------------
  task drive_ber_stress(serdes_item item);
    vif.tx_valid <= 1;
    vif.tx_data  <= item.data;

    // Raise BER injection enable if your DUT exposes it
    vif.ber_enable <= 1;

    repeat (item.num_cycles) @(posedge vif.clk);

    vif.ber_enable <= 0;
    vif.tx_valid   <= 0;
  endtask

  // ------------------------------------------------------------
  // Task: Retrain link (trigger LTSSM retrain)
  // ------------------------------------------------------------
  task drive_retrain(serdes_item item);
    vif.training_req <= 1;
    @(posedge vif.clk);
    vif.training_req <= 0;

    // Send a few idle cycles after retrain request
    repeat (5) @(posedge vif.clk);
  endtask

endclass
