//=============================================================
// NVLink-style Framing Encoder (Behavioral Model)
// Location: rtl/protocol/nvlink_framing_encode.sv
//=============================================================

module nvlink_framing_encode #(
    parameter PAYLOAD_W = 96,   // Data payload width
    parameter COH_W     = 8,    // Coherence bits width
    parameter SEQ_W     = 24    // Sequence ID width
)(
    input  logic clk,
    input  logic rst_n,

    // Input interface from upper layer
    input  logic              valid_in,
    input  logic [PAYLOAD_W-1:0] payload_in,
    input  logic [COH_W-1:0]     coh_bits_in,

    // Encoded NVLink flit output
    output logic                valid_out,
    output logic [PAYLOAD_W+COH_W+SEQ_W-1:0] flit_out
);

    // Internal sequence counter (monotonic)
    logic [SEQ_W-1:0] seq_id;

    //=============================================================
    // Sequence ID generation (wrap-around)
    //=============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            seq_id <= '0;
        else if (valid_in)
            seq_id <= seq_id + 1'b1;
    end

    //=============================================================
    // NVLink-like flit format:
    //
    // [PAYLOAD_W+COH_W+SEQ_W-1 : PAYLOAD_W+SEQ_W] = COHERENCE BITS
    // [PAYLOAD_W+SEQ_W-1      : PAYLOAD_W]        = SEQUENCE ID
    // [PAYLOAD_W-1            : 0]                = PAYLOAD
    //=============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flit_out  <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;

            if (valid_in) begin
                flit_out <= {
                    coh_bits_in,   // Coherence / protocol metadata
                    seq_id,        // Ordering information
                    payload_in     // Actual data
                };
            end
        end
    end

endmodule
