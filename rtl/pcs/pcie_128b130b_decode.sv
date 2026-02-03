module pcie_128b130b_decode (
    input  logic        clk,
    input  logic        rst_n,

    // 130-bit received codeword from PHY
    input  logic [129:0] encoded_in,

    // Outputs to higher layer
    output logic [127:0] data_out,
    output logic         rd_error,      // running disparity error
    output logic         header_error   // invalid header flag
);

    logic [1:0]  header;
    logic [127:0] payload;
    logic [15:0]  lfsr;          // for descrambler
    integer       ones_count;

    // Split header and payload
    assign header  = encoded_in[129:128];
    assign payload = encoded_in[127:0];

    // ----------------------------
    // 1) Running Disparity Check
    // ----------------------------
    always_comb begin
        ones_count = 0;
        for (int i = 0; i < 128; i++) begin
            if (payload[i])
                ones_count++;
        end

        // Valid headers are 2'b01 (positive disparity) or 2'b10 (negative disparity)
        header_error = (header != 2'b01 && header != 2'b10);

        // Check consistency between header and payload disparity
        if (header == 2'b01) begin
            // Expect more 1s than 0s
            rd_error = (ones_count < 64);
        end
        else if (header == 2'b10) begin
            // Expect more 0s than 1s
            rd_error = (ones_count > 64);
        end
        else begin
            rd_error = 1'b1; // invalid header -> flag error
        end
    end

    // ----------------------------
    // 2) Self-synchronizing descrambler (PCIe-like)
    // ----------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 16'hFFFF;
        end else begin
            // Same polynomial as encoder: x^16 + x^12 + 1
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[12]};
        end
    end

    // Descramble payload
    always_comb begin
        data_out = payload ^ {8{lfsr}};
    end

endmodule
