// =====================================================================
// File: tb/sequences/retrain_seq.sv
// Description: PCIe-style retrain sequence for GPU SerDes project
// =====================================================================

`include "uvm_macros.svh"
import uvm_pkg::*;

class retrain_seq extends uvm_sequence #(serdes_item);

  `uvm_object_utils(retrain_seq)

  function new(string name = "retrain_seq");
    super.new(name);
  endfunction

  // Task to send a burst of normal traffic
  task send_normal_traffic(int num_flits = 50);
    serdes_item item;
    repeat (num_flits) begin
      item = serdes_item::type_id::create("item");
      start_item(item);
      item.serial_bit = $urandom_range(0,1);
      finish_item(item);
      #10;
    end
  endtask

  // Task to inject errors (to trigger retrain)
  task inject_errors(int num_errors = 20);
    serdes_item item;
    repeat (num_errors) begin
      item = serdes_item::type_id::create("item");
      start_item(item);

      // Force bit flip to model channel error
      item.serial_bit = ~($urandom_range(0,1));

      finish_item(item);
      #10;
    end
  endtask

  // Main sequence body
  virtual task body();
    uvm_report_info(get_type_name(),
      "===== RETRAIN SEQUENCE STARTED =====", UVM_LOW);

    // Phase 1: Normal operation
    uvm_report_info(get_type_name(),
      "Phase 1: Sending normal traffic (L0 expected)", UVM_LOW);
    send_normal_traffic(50);

    // Phase 2: Inject errors → expect LTSSM to go to RECOVERY/RETRAIN
    uvm_report_info(get_type_name(),
      "Phase 2: Injecting errors to trigger retrain", UVM_LOW);
    inject_errors(20);

    // Small wait for LTSSM to react
    #200;

    // Phase 3: Resume normal traffic after retrain
    uvm_report_info(get_type_name(),
      "Phase 3: Resume traffic after retrain", UVM_LOW);
    send_normal_traffic(50);

    uvm_report_info(get_type_name(),
      "===== RETRAIN SEQUENCE COMPLETED =====", UVM_LOW);
  endtask

endclass
