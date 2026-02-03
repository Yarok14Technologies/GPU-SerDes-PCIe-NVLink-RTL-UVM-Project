//======================================================================
// File: rtl/pcs/pcie_scrambler.sv
// Description: PCIe-like self-synchronizing scrambler (behavioral RTL)
//======================================================================

module pcie_scrambler (
    input  logic         clk,
    input  logic         rst_n,

    input  logic [127:0] data_in,
    output logic [127:0] data_out
);

    // PCIe-like 16-bit LFSR (self-synchronizing scrambler)
    logic [15:0] lfsr;

    // Initialize LFSR to all 1's on reset (typical PCIe behavior)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr <= 16'hFFFF;
        else
            // x^16 + x^15 + x^2 + 1 (common PCIe polynomial abstraction)
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[14]};
    end

    // Expand LFSR to 128 bits and XOR with data (self-synchronizing)
    always_comb begin
        data_out = data_in ^ {
            8{lfsr}   // replicate 16-bit LFSR 8 times → 128 bits
        };
    end

endmodule
