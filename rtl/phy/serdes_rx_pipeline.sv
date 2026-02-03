module serdes_rx_pipeline #(
    parameter P_WIDTH = 130      // 130-bit after 128b/130b encoding
)(
    input  logic clk,
    input  logic rst_n,

    // Serial input from channel
    input  logic serial_in,

    // Parallel output to PCS
    output logic [P_WIDTH-1:0] parallel_out,

    // Status
    output logic lock,           // CDR lock indication
    output logic deskew_done     // multi-lane deskew abstraction
);

    // ------------------------------
    // Stage 1: Deserializer (Shift Register)
    // ------------------------------
    logic [P_WIDTH-1:0] stage1_shift;
    integer bit_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1_shift <= '0;
            bit_count    <= 0;
            lock         <= 0;
        end else begin
            // Shift in serial bit
            stage1_shift <= {stage1_shift[P_WIDTH-2:0], serial_in};

            // Simple CDR lock abstraction:
            // Assume lock achieved after one full word received
            if (bit_count == P_WIDTH-1) begin
                lock      <= 1;
                bit_count <= 0;
            end else begin
                bit_count <= bit_count + 1;
            end
        end
    end

    // ------------------------------
    // Stage 2: Register + Deskew (timing alignment)
    // ------------------------------
    logic [P_WIDTH-1:0] stage2_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage2_reg  <= '0;
            deskew_done <= 0;
        end else begin
            // Capture aligned data
            stage2_reg  <= stage1_shift;

            // Deskew abstraction: assert once lock is achieved
            deskew_done <= lock;
        end
    end

    // Final parallel output
    assign parallel_out = stage2_reg;

endmodule
