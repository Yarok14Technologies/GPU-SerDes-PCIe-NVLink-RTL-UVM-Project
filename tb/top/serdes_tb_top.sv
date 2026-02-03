`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

//------------------------------------------------------------
// Top-level Testbench Wrapper
//------------------------------------------------------------

module serdes_tb_top;

  // Clock & Reset
  logic clk;
  logic rst_n;

  // DUT signals (match gpu_serdes_system interface)
  logic [127:0] tx_data;
  logic         tx_valid;
  logic [127:0] rx_data;
  logic         link_up;

  //------------------------------------------------------------
  // Clock Generation
  //------------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;   // 100 MHz reference clock
  end

  //------------------------------------------------------------
  // Reset Sequence
  //------------------------------------------------------------
  initial begin
    rst_n = 0;
    tx_data  = '0;
    tx_valid = 0;

    #50;
    rst_n = 1;
  end

  //------------------------------------------------------------
  // DUT Instantiation
  //------------------------------------------------------------
  gpu_serdes_system dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .tx_data  (tx_data),
    .tx_valid (tx_valid),
    .rx_data  (rx_data),
    .link_up  (link_up)
  );

  //------------------------------------------------------------
  // UVM Configuration Database (if needed later)
  //------------------------------------------------------------
  initial begin
    uvm_config_db#(virtual logic)::set(null, "uvm_test_top.env.agent.drv", 
                                       "vif_clk", clk);
    uvm_config_db#(virtual logic)::set(null, "uvm_test_top.env.agent.drv", 
                                       "vif_rst", rst_n);
  end

  //------------------------------------------------------------
  // Start UVM Test
  //------------------------------------------------------------
  initial begin
    run_test();  // Default picks +UVM_TESTNAME from command line
  end

  //------------------------------------------------------------
  // Optional: Dump Waves for Debug
  //------------------------------------------------------------
  initial begin
    $dumpfile("sim/waves/serdes.vcd");
    $dumpvars(0, serdes_tb_top);
  end

endmodule
