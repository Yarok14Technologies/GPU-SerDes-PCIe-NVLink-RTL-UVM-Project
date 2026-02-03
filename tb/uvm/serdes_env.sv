`include "uvm_macros.svh"
import uvm_pkg::*;

class serdes_env extends uvm_env;
  `uvm_component_utils(serdes_env)

  // UVM components in your environment
  serdes_agent       agent;
  serdes_scoreboard  sb;
  serdes_coverage    cov;

  function new(string name = "serdes_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // -------- BUILD PHASE --------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create components
    agent = serdes_agent::type_id::create("agent", this);
    sb    = serdes_scoreboard::type_id::create("sb", this);
    cov   = serdes_coverage::type_id::create("cov", this);

    // (Optional) configuration can be added here later
    // uvm_config_db#(virtual serdes_if)::set(this, "agent.drv", "vif", vif);
  endfunction

  // -------- CONNECT PHASE --------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect monitor analysis ports to scoreboard & coverage (if implemented)
    if (agent.mon != null) begin
      agent.mon.ap.connect(sb.analysis_export);
      agent.mon.ap.connect(cov.analysis_export);
    end
  endfunction

  // -------- RUN PHASE --------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);

    `uvm_info("SERDES_ENV", 
      "SerDes UVM environment running (PCS + PHY + LTSSM + BER/Jitter + Eye Stats)", 
      UVM_MEDIUM)

    #1000; // Allow time for sequences and link training

    phase.drop_objection(this);
  endtask

endclass
