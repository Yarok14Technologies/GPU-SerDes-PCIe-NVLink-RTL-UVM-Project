// ============================================================
//  PCIe-style 128b/130b Encoder with Scrambler + Running Disparity
//  Path: rtl/pcs/pcie_128b130b_encode.sv
// ============================================================

module pcie_128b130b_encode (
    input  logic         clk,
    input  logic         rst_n,

    input  logic [127:0] data_in,      // 128-bit payload
    input  logic         data_valid,

    output logic [129:0] encoded_out,  // 130-bit encoded word
    output logic         rd_out,       // running disparity (for debug)
    output logic         enc_valid
);

    // ------------------------------
    // Internal signals
    // ------------------------------
    logic [127:0] scrambled_data;
    logic rd;                // running disparity (1 = positive, 0 = negative)
    logic [1:0]  header;     // 2-bit header for 128b/130b

    // ============================================================
    // 1) PCIe-like Self-Synchronizing Scrambler
    // ============================================================

    logic [15:0] lfsr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr <= 16'hFFFF;   // standard PCIe seed
        else if (data_valid)
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[12]}; // x^16 + x^12 + 1
    end

    // Scramble 128-bit word
    assign scrambled_data = data_in ^ {8{lfsr}};

    // ============================================================
    // 2) Count ones for Running Disparity decision
    // ============================================================

    function automatic int count_ones(input logic [127:0] d);
        integer i;
        begin
            count_ones = 0;
            for (i = 0; i < 128; i = i + 1)
                if (d[i]) count_ones++;
        end
    endfunction

    // ============================================================
    // 3) Running Disparity Control
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd <= 1'b0;   // start with negative disparity
        end
        else if (data_valid) begin
            if (count_ones(scrambled_data) > 64)
                rd <= 1'b0;   // too many 1s → go negative
            else if (count_ones(scrambled_data) < 64)
                rd <= 1'b1;   // too many 0s → go positive
            else
                rd <= rd;     // keep previous if balanced
        end
    end

    // ============================================================
    // 4) 128b/130b Header Selection (simplified but realistic)
    // ============================================================

    always_comb begin
        if (rd)
            header = 2'b01;   // positive disparity code
        else
            header = 2'b10;   // negative disparity code
    end

    // ============================================================
    // 5) Final 130-bit Encoded Output
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            encoded_out <= 130'b0;
            enc_valid   <= 1'b0;
        end
        else begin
            encoded_out <= {header, scrambled_data};
            enc_valid   <= data_valid;
        end
    end

    assign rd_out = rd;

endmodule
