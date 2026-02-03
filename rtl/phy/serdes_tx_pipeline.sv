module serdes_tx_pipeline #(
    parameter P_WIDTH = 130   // 130-bit after 128b/130b encoding
)(
    input  logic              clk,
    input  logic              rst_n,

    // From PCS (128b/130b encoded)
    input  logic [P_WIDTH-1:0] parallel_in,
    input  logic               tx_valid,

    // To channel (1-bit serial stream)
    output logic               serial_out,
    output logic               tx_busy
);

    // -------------------------------
    // Stage 1: Gearbox / Register stage
    // -------------------------------
    logic [P_WIDTH-1:0] stage1_reg;
    logic               stage1_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1_reg   <= '0;
            stage1_valid <= 1'b0;
        end else begin
            stage1_reg   <= parallel_in;
            stage1_valid <= tx_valid;
        end
    end

    // -------------------------------
    // Stage 2: Serializer (Shift Register)
    // -------------------------------
    logic [P_WIDTH-1:0] shift_reg;
    integer bit_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= '0;
            bit_count <= 0;
        end else begin
            if (stage1_valid) begin
                // Load new word when starting transmission
                if (bit_count == 0)
                    shift_reg <= stage1_reg;
                else
                    shift_reg <= {shift_reg[P_WIDTH-2:0], 1'b0};

                // Increment bit counter
                if (bit_count == P_WIDTH-1)
                    bit_count <= 0;
                else
                    bit_count <= bit_count + 1;
            end
        end
    end

    // -------------------------------
    // Outputs
    // -------------------------------
    assign serial_out = shift_reg[P_WIDTH-1];
    assign tx_busy    = stage1_valid;

endmodule
