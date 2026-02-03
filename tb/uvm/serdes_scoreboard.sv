// ============================================================
// File: tb/uvm/serdes_scoreboard.sv
// Description: UVM Scoreboard for GPU SerDes project
// Tracks:
//  - BER errors
//  - CDR lock time
//  - Lane deskew (basic check)
//  - LTSSM state transitions
// ============================================================

`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_scoreboard extends uvm_component;

  `uvm_component_utils(serdes_scoreboard)

  // --------- Scoreboard metrics ---------
  int unsigned ber_error_count;
  time lock_start_time;
  time lock_end_time;
  bit lock_seen;
  bit deskew_error;
  int unsigned ltssm_transition_count;

  // Analysis ports (connect from monitor)
  uvm_analysis_imp #(bit, serdes_scoreboard) ber_port;
  uvm_analysis_imp #(bit, serdes_scoreboard) lock_port;
  uvm_analysis_imp #(logic [3:0], serdes_scoreboard) ltssm_port;
  uvm_analysis_imp #(bit, serdes_scoreboard) deskew_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ber_error_count = 0;
    lock_seen = 0;
    deskew_error = 0;
    ltssm_transition_count = 0;

    ber_port    = new("ber_port", this);
    lock_port   = new("lock_port", this);
    ltssm_port  = new("ltssm_port", this);
    deskew_port = new("deskew_port", this);
  endfunction

  // --------- Write methods (called by monitor) ---------

  // BER tracking
  function void write(bit ber_error);
    if (ber_error) begin
      ber_error_count++;
      `uvm_info("SCOREBOARD", $sformatf("BER error detected! Total=%0d",
                 ber_error_count), UVM_LOW)
    end
  endfunction

  // CDR Lock tracking
  function void write_lock(bit lock);
    if (lock && !lock_seen) begin
      lock_start_time = $time;
      lock_seen = 1;
      `uvm_info("SCOREBOARD", "CDR lock asserted (start timing)", UVM_LOW)
    end
    else if (!lock && lock_seen) begin
      lock_end_time = $time;
      `uvm_info("SCOREBOARD",
        $sformatf("CDR lost lock after %0t ns", 
                   lock_end_time - lock_start_time),
        UVM_MEDIUM)
      lock_seen = 0;
    end
  endfunction

  // LTSSM state tracking
  function void write_ltssm(logic [3:0] state);
    static logic [3:0] prev_state = '0;

    if (state !== prev_state) begin
      ltssm_transition_count++;
      `uvm_info("SCOREBOARD",
        $sformatf("LTSSM transition: 0x%0h -> 0x%0h",
                   prev_state, state),
        UVM_LOW)
      prev_state = state;
    end
  endfunction

  // Deskew check (multi-lane alignment)
  function void write_deskew(bit deskew_ok);
    if (!deskew_ok) begin
      deskew_error = 1;
      `uvm_error("SCOREBOARD", "Deskew error detected!")
    end
  endfunction

  // --------- End-of-test reporting ---------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SCOREBOARD SUMMARY",
      $sformatf(
      "\n================ SERDES SCOREBOARD SUMMARY ================\n"
      "BER Error Count        : %0d\n"
      "LTSSM Transitions      : %0d\n"
      "Deskew Error Observed  : %0s\n"
      "============================================================\n",
      ber_error_count,
      ltssm_transition_count,
      (deskew_error ? "YES" : "NO")
      ), UVM_LOW)

    if (ber_error_count > 0)
      `uvm_warning("SCOREBOARD", "Non-zero BER detected!")

    if (deskew_error)
      `uvm_error("SCOREBOARD", "Deskew failure observed!")
  endfunction

endclass
