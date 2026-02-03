//============================================================
// File: tb/sequences/serdes_base_seq.sv
// Description: Base sequence for GPU SerDes verification
//============================================================

`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_base_seq extends uvm_sequence #(serdes_item);

  `uvm_object_utils(serdes_base_seq)

  // -----------------------------
  // Knobs you can override in child sequences
  // -----------------------------
  rand int unsigned num_transactions = 100;
  rand bit enable_ber_injection = 0;
  rand bit enable_retrain = 0;

  // Constraint to keep test reasonable
  constraint c_num_tx {
    num_transactions inside {[10:1000]};
  }

  function new(string name = "serdes_base_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    uvm_info(get_type_name(),
      $sformatf("Starting %s: num_tx=%0d, BER=%0b, retrain=%0b",
                get_name(), num_transactions,
                enable_ber_injection, enable_retrain),
      UVM_MEDIUM);
  endtask

  virtual task body();
    serdes_item item;

    // Optional: request link retrain before traffic
    if (enable_retrain) begin
      uvm_info(get_type_name(), "Requesting link retrain...", UVM_LOW);
      // You can hook this to your LTSSM stimulus later
      #100;
    end

    repeat (num_transactions) begin
      item = serdes_item::type_id::create("item");

      // Randomize the transaction
      if (!item.randomize()) begin
        uvm_error(get_type_name(), "Randomization failed for serdes_item");
      end

      // (Optional) mark item as error-prone if BER injection enabled
      if (enable_ber_injection)
        item.serial_bit = $urandom_range(0,1);

      start_item(item);
      finish_item(item);

      // Small gap between transactions (can be tuned)
      #10;
    end
  endtask

  virtual task post_body();
    uvm_info(get_type_name(),
      $sformatf("Completed %0d transactions", num_transactions),
      UVM_MEDIUM);
  endtask

endclass
