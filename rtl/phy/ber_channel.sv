// ============================================================
// BER Channel Model (Bit Error Rate Injector)
// File: rtl/phy/ber_channel.sv
// ============================================================
// - Inserts random bit flips based on a programmable BER
// - Can be controlled from UVM via configuration
// - Suitable for stress testing and scoreboard checking
// ============================================================

module ber_channel #(
    parameter real DEFAULT_BER = 1e-6   // default (exaggerated for sim)
)(
    input  logic clk,
    input  logic rst_n,

    // Configuration interface (can be driven by UVM)
    input  logic ber_enable,
    input  real  ber_value,   // e.g., 1e-12, 1e-9, 1e-6, etc.

    // Serial data interface
    input  logic serial_in,
    output logic serial_out,

    // Status for scoreboard/coverage
    output logic error_injected
);

    // Internal BER register
    real active_ber;

    // --------------------------------------------------
    // BER configuration
    // --------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            active_ber <= DEFAULT_BER;
        else if (ber_enable)
            active_ber <= ber_value;
    end

    // --------------------------------------------------
    // BER Injection Logic
    // --------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            serial_out     <= 1'b0;
            error_injected <= 1'b0;
        end else begin

            error_injected <= 1'b0;

            // If BER disabled, pass through
            if (!ber_enable) begin
                serial_out <= serial_in;
            end else begin
                // Random bit flip based on BER probability
                if ($urandom_real() < active_ber) begin
                    serial_out     <= ~serial_in; // inject error
                    error_injected <= 1'b1;
                end else begin
                    serial_out <= serial_in;      // clean bit
                end
            end
        end
    end

endmodule
