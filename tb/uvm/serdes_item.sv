`ifndef SERDES_ITEM_SV
`define SERDES_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_item extends uvm_sequence_item;

  // ---------- CORE DATA FIELDS ----------
  rand logic [127:0] payload;        // NVLink / PCIe data payload
  rand logic [7:0]   coh_bits;       // NVLink coherence metadata
  rand logic [23:0]  seq_id;         // NVLink sequence ID

  // ---------- PCS / PHY RELATED ----------
  rand logic inject_ber;             // Enable BER injection
  rand real  ber_rate;               // e.g., 1e-6, 1e-9, etc.

  rand logic inject_jitter;          // Enable jitter model
  rand real  rj_sigma;               // Random jitter (UI)
  rand real  dj_peak;                // Deterministic jitter (UI)

  // ---------- LINK CONTROL (LTSSM) ----------
  rand logic training_req;           // Request retrain
  rand logic idle_req;               // Request L0s / L1 / L2
  rand logic force_recovery;         // Force RECOVERY state

  // ---------- EXPECTED OUTPUT (for scoreboard) ----------
  logic [127:0] expected_payload;
  logic rd_error_expected;
  logic seq_error_expected;

  // UVM factory registration
  `uvm_object_utils_begin(serdes_item)
    `uvm_field_int(payload,          UVM_ALL_ON)
    `uvm_field_int(coh_bits,         UVM_ALL_ON)
    `uvm_field_int(seq_id,           UVM_ALL_ON)
    `uvm_field_int(inject_ber,       UVM_ALL_ON)
    `uvm_field_real(ber_rate,        UVM_ALL_ON)
    `uvm_field_int(inject_jitter,    UVM_ALL_ON)
    `uvm_field_real(rj_sigma,        UVM_ALL_ON)
    `uvm_field_real(dj_peak,         UVM_ALL_ON)
    `uvm_field_int(training_req,     UVM_ALL_ON)
    `uvm_field_int(idle_req,         UVM_ALL_ON)
    `uvm_field_int(force_recovery,   UVM_ALL_ON)
    `uvm_field_int(expected_payload, UVM_ALL_ON)
    `uvm_field_int(rd_error_expected,UVM_ALL_ON)
    `uvm_field_int(seq_error_expected,UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "serdes_item");
    super.new(name);
  endfunction

  // ---------- CONSTRAINTS ----------
  constraint valid_defaults {
    ber_rate inside {1e-6, 1e-9, 1e-12};
    rj_sigma inside {0.01, 0.02, 0.05};
    dj_peak  inside {0.02, 0.05};
  }

  constraint link_ctrl {
    !(training_req && idle_req); // can't request both at same time
  }

  // ---------- HELPER METHODS ----------
  function void set_clean_transaction();
    inject_ber      = 0;
    inject_jitter   = 0;
    training_req    = 0;
    idle_req        = 0;
    force_recovery  = 0;
    ber_rate        = 1e-12;
    rj_sigma        = 0.02;
    dj_peak         = 0.05;
  endfunction

  function void set_ber_stress(real rate = 1e-6);
    inject_ber = 1;
    ber_rate   = rate;
  endfunction

  function void set_jitter_stress(real rj = 0.02, real dj = 0.05);
    inject_jitter = 1;
    rj_sigma      = rj;
    dj_peak       = dj;
  endfunction

  function void request_retrain();
    training_req = 1;
    idle_req     = 0;
  endfunction

  function void request_idle();
    idle_req     = 1;
    training_req = 0;
  endfunction

endclass

`endif
