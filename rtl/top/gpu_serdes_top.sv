//============================================================
// gpu_serdes_top.sv
// Top-level wrapper integrating all SerDes components
//============================================================

module gpu_serdes_top #(
    parameter LANES = 1
)(
    input  logic clk,
    input  logic rst_n,

    // Stimulus from UVM Driver
    input  logic        tx_valid,
    input  logic [95:0] tx_payload,      // NVLink payload
    input  logic [7:0]  tx_coh_bits,     // NVLink coherence bits

    // Outputs observed by UVM Monitor
    output logic [95:0] rx_payload,
    output logic        rx_valid,
    output logic        link_up,
    output logic        rd_error,
    output logic        seq_error
);

    //========================================================
    // NVLink Framing (TX side)
    //========================================================
    logic [127:0] nvlink_flit;

    nvlink_framing_encode u_nvlink_enc (
        .clk      (clk),
        .rst_n    (rst_n),
        .payload  (tx_payload),
        .coh_bits (tx_coh_bits),
        .flit_out (nvlink_flit)
    );

    //========================================================
    // PCS Layer (128b/130b Encode)
    //========================================================
    logic [129:0] pcs_encoded;

    pcie_128b130b_encode u_pcs_enc (
        .clk         (clk),
        .rst_n       (rst_n),
        .data_in     (nvlink_flit),
        .encoded_out (pcs_encoded)
    );

    //========================================================
    // PHY TX Pipeline
    //========================================================
    logic serial_wire;

    serdes_tx_pipeline #(.P_WIDTH(130)) u_tx_phy (
        .clk         (clk),
        .rst_n       (rst_n),
        .parallel_in (pcs_encoded),
        .serial_out  (serial_wire)
    );

    //========================================================
    // Channel Model (BER + Jitter)
    //========================================================
    logic serial_corrupt;

    ber_channel u_ber (
        .clk        (clk),
        .rst_n      (rst_n),
        .serial_in  (serial_wire),
        .serial_out (serial_corrupt)
    );

    jitter_channel u_jitter (
        .clk        (clk),
        .rst_n      (rst_n),
        .serial_in  (serial_corrupt),
        .serial_out (serial_corrupt) // in-place model
    );

    //========================================================
    // PHY RX Pipeline + CDR
    //========================================================
    logic [129:0] rx_parallel;
    logic cdr_lock;

    cdr_model u_cdr (
        .clk          (clk),
        .rst_n        (rst_n),
        .serial_in    (serial_corrupt),
        .recovered_clk(),   // abstracted
        .lock         (cdr_lock)
    );

    serdes_rx_pipeline #(.P_WIDTH(130)) u_rx_phy (
        .clk         (clk),
        .rst_n       (rst_n),
        .serial_in   (serial_corrupt),
        .parallel_out(rx_parallel),
        .lock        ()
    );

    //========================================================
    // PCS Layer (128b/130b Decode)
    //========================================================
    logic [127:0] pcs_decoded;

    pcie_128b130b_decode u_pcs_dec (
        .encoded_in (rx_parallel),
        .data_out   (pcs_decoded),
        .rd_error   (rd_error)
    );

    //========================================================
    // NVLink Decode (RX side)
    //========================================================
    logic [7:0]  rx_coh_bits;
    logic [23:0] rx_seq;

    nvlink_framing_decode u_nvlink_dec (
        .flit_in   (pcs_decoded),
        .payload   (rx_payload),
        .coh_bits  (rx_coh_bits),
        .seq       (rx_seq),
        .seq_error (seq_error)
    );

    assign rx_valid = cdr_lock;

    //========================================================
    // PCIe LTSSM (Link Training & State)
    //========================================================
    logic [3:0] ltssm_state;

    pcie_ltssm_full u_ltssm (
        .clk           (clk),
        .rst_n         (rst_n),
        .training_req  (1'b0),   // can be driven from UVM later
        .idle_req      (1'b0),
        .error_detected(rd_error | seq_error),
        .link_up       (link_up),
        .state         (ltssm_state)
    );

    //========================================================
    // Eye Statistics (Analysis Hook)
    //========================================================
    eye_stats_collector u_eye (
        .clk       (clk),
        .rst_n     (rst_n),
        .serial_in (serial_corrupt)
    );

endmodule
