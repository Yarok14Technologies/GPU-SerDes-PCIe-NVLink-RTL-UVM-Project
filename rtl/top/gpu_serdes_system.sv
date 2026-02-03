//============================================================
// gpu_serdes_system.sv
// Top-level DUT for the serdes_gpu_project
//============================================================

module gpu_serdes_system #(
    parameter FLIT_W = 128,
    parameter ENC_W  = 130
)(
    input  logic clk,
    input  logic rst_n,

    // Stimulus from UVM driver (TX side)
    input  logic [95:0]  tx_payload,
    input  logic [7:0]   tx_coh_bits,
    input  logic         tx_valid,

    // Control inputs (from UVM or test)
    input  logic training_req,
    input  logic idle_req,

    // Observability for UVM monitor/scoreboard
    output logic [FLIT_W-1:0] rx_flit,
    output logic              link_up,
    output logic              cdr_lock,
    output logic              rd_error,
    output logic              seq_error
);

    // --------------------------------------------------
    // Internal wires
    // --------------------------------------------------

    // NVLink framing
    logic [FLIT_W-1:0] nvlink_flit_tx;
    logic [FLIT_W-1:0] nvlink_flit_rx;

    // PCS layer
    logic [ENC_W-1:0] pcs_encoded;
    logic [FLIT_W-1:0] pcs_decoded;

    // PHY layer
    logic serial_tx;
    logic serial_rx;
    logic [ENC_W-1:0] rx_parallel;

    // Channel effects
    logic serial_corrupt;

    // LTSSM state
    logic [3:0] ltssm_state;

    // --------------------------------------------------
    // NVLINK FRAMING (TX)
    // --------------------------------------------------
    nvlink_framing_encode u_nvlink_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .payload  (tx_payload),
        .coh_bits (tx_coh_bits),
        .flit_out (nvlink_flit_tx)
    );

    // --------------------------------------------------
    // PCS LAYER: 128b/130b + Scrambler + RD
    // --------------------------------------------------
    pcie_128b130b_encode u_pcs_enc (
        .clk         (clk),
        .rst_n       (rst_n),
        .data_in     (nvlink_flit_tx),
        .encoded_out (pcs_encoded)
    );

    // --------------------------------------------------
    // PHY TX PIPELINE (Serializer abstraction)
    // --------------------------------------------------
    serdes_tx_pipeline #(
        .P_WIDTH(ENC_W)
    ) u_tx_phy (
        .clk          (clk),
        .rst_n        (rst_n),
        .parallel_in  (pcs_encoded),
        .serial_out   (serial_tx)
    );

    // --------------------------------------------------
    // CHANNEL MODEL (BER + Jitter)
    // --------------------------------------------------
    ber_channel u_ber (
        .clk        (clk),
        .rst_n      (rst_n),
        .serial_in  (serial_tx),
        .serial_out (serial_corrupt)
    );

    jitter_channel u_jitter (
        .clk        (clk),
        .rst_n      (rst_n),
        .serial_in  (serial_corrupt),
        .serial_out (serial_rx)
    );

    // --------------------------------------------------
    // CDR MODEL (behavioral lock)
    // --------------------------------------------------
    cdr_model u_cdr (
        .clk          (clk),
        .rst_n        (rst_n),
        .serial_in    (serial_rx),
        .recovered_clk(),   // not used explicitly in this model
        .lock         (cdr_lock)
    );

    // --------------------------------------------------
    // PHY RX PIPELINE (Deserializer + deskew abstraction)
    // --------------------------------------------------
    serdes_rx_pipeline #(
        .P_WIDTH(ENC_W)
    ) u_rx_phy (
        .clk          (clk),
        .rst_n        (rst_n),
        .serial_in    (serial_rx),
        .parallel_out (rx_parallel),
        .lock         ()   // optional per-lane lock if extended
    );

    // --------------------------------------------------
    // PCS DECODE: 128b/130b + RD check
    // --------------------------------------------------
    pcie_128b130b_decode u_pcs_dec (
        .encoded_in (rx_parallel),
        .data_out   (pcs_decoded),
        .rd_error   (rd_error)
    );

    // --------------------------------------------------
    // NVLINK DECODE (RX)
    // --------------------------------------------------
    nvlink_framing_decode u_nvlink_rx (
        .flit_in   (pcs_decoded),
        .payload   (),           // can be connected to monitor
        .coh_bits  (),           // can be connected to monitor
        .seq       (),           // can be connected to monitor
        .seq_error (seq_error)
    );

    assign rx_flit = pcs_decoded;

    // --------------------------------------------------
    // PCIe LTSSM (Full version: L0/L0s/L1/L2/L3/Recovery)
    // --------------------------------------------------
    pcie_ltssm_full u_ltssm (
        .clk            (clk),
        .rst_n          (rst_n),
        .training_req   (training_req),
        .idle_req       (idle_req),
        .error_detected (rd_error | seq_error),
        .link_up        (link_up),
        .state          (ltssm_state)
    );

    // --------------------------------------------------
    // Eye statistics collector (analysis)
    // --------------------------------------------------
    eye_stats_collector u_eye (
        .clk       (clk),
        .rst_n     (rst_n),
        .serial_in (serial_rx)
    );

endmodule
