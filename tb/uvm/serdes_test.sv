`ifndef SERDES_TEST_SV
`define SERDES_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_test extends uvm_test;

  serdes_env env;

  `uvm_component_utils(serdes_test)

  function new(string name = "serdes_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env = serdes_env::type_id::create("env", this);

    // Set default UVM verbosity
    uvm_config_db#(int)::set(this, "*", "verbosity", UVM_MEDIUM);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("SERDES_TEST", "Starting basic SerDes functional test", UVM_LOW)

    // Wait for reset deassertion and some settling time
    #100;

    // Run base traffic sequence
    begin
      serdes_base_seq base_seq;
      base_seq = serdes_base_seq::type_id::create("base_seq");
      base_seq.start(env.agent.sequencer);
    end

    // Run BER stress sequence
    begin
      ber_stress_seq ber_seq;
      ber_seq = ber_stress_seq::type_id::create("ber_seq");
      ber_seq.start(env.agent.sequencer);
    end

    // Trigger retraining sequence (LTSSM exercise)
    begin
      retrain_seq retrain_seq_i;
      retrain_seq_i = retrain_seq::type_id::create("retrain_seq");
      retrain_seq_i.start(env.agent.sequencer);
    end

    // Allow time for scoreboard + coverage collection
    #500;

    `uvm_info("SERDES_TEST", "Test completed", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass

// Top-level to launch the test
module serdes_tb_top;

  initial begin
    run_test("serdes_test");
  end

endmodule

`endif
