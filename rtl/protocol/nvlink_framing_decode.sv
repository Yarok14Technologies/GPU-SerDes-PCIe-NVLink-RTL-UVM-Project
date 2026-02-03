module nvlink_framing_decode #(
    parameter SEQ_WIDTH = 24
)(
    input  logic        clk,
    input  logic        rst_n,

    // Encoded NVLink flit from PCS/RX side
    input  logic [127:0] flit_in,
    input  logic         flit_valid,

    // Decoded outputs
    output logic [95:0]  payload_out,
    output logic [7:0]   coh_bits_out,
    output logic [SEQ_WIDTH-1:0] seq_id_out,

    // Error/Status signals
    output logic seq_error,
    output logic flit_error,
    output logic flit_accepted
);

    // Internal tracking of last sequence ID
    logic [SEQ_WIDTH-1:0] last_seq_id;
    logic [SEQ_WIDTH-1:0] curr_seq_id;

    // Field extraction (bit-level unpacking)
    always_comb begin
        coh_bits_out = flit_in[127:120];
        curr_seq_id  = flit_in[119:96];
        payload_out  = flit_in[95:0];
    end

    // Sequence checking + acceptance logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_seq_id   <= '0;
            seq_error     <= 1'b0;
            flit_error    <= 1'b0;
            flit_accepted <= 1'b0;
        end else begin
            flit_accepted <= 1'b0;
            seq_error     <= 1'b0;
            flit_error    <= 1'b0;

            if (flit_valid) begin
                // Check for in-order delivery
                if (curr_seq_id != last_seq_id + 1'b1) begin
                    seq_error <= 1'b1;
                end

                // Basic sanity check: coherence field should not be X
                if (^coh_bits_out === 1'bx) begin
                    flit_error <= 1'b1;
                end

                // Accept flit if no fatal error
                if (!flit_error) begin
                    flit_accepted <= 1'b1;
                    last_seq_id   <= curr_seq_id;
                end
            end
        end
    end

endmodule
