// ================================================================
//  File: rtl/phy/jitter_channel.sv
//  Behavioral Jitter + (optional) BER Channel Model
//  - Random Jitter (RJ): Gaussian
//  - Deterministic Jitter (DJ): data-dependent
//  - UI-based sampling abstraction
//  - Parameterized for easy tuning in UVM
// ================================================================

module jitter_channel #(
    parameter real RJ_SIGMA = 0.02,   // Random jitter (UI rms)
    parameter real DJ_PEAK  = 0.05,   // Deterministic jitter (UI peak)
    parameter real BER      = 1e-9    // Optional BER (can be set to 0)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic serial_in,

    // Optional control knobs from testbench
    input  logic enable_jitter,
    input  logic enable_ber,

    output logic serial_out
);

    // Internal modeling variables
    real ui_offset;      // combined jitter in UI
    real sample_time;    // "virtual" sampling instant (for modeling only)
    real rj;             // random jitter component
    real dj;             // deterministic jitter component

    // ---------------------------------------------
    // Jitter + BER model (cycle-accurate abstraction)
    // ---------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            serial_out <= 1'b0;
        end else begin

            // -------- Random Jitter (RJ) --------
            if (enable_jitter)
                rj = $dist_normal(0.0, RJ_SIGMA); // Gaussian noise
            else
                rj = 0.0;

            // -------- Deterministic Jitter (DJ) --------
            // Simple data-dependent model:
            //  - rising edge shifts one way
            //  - falling edge shifts the other
            if (enable_jitter) begin
                if (serial_in)
                    dj = +DJ_PEAK;
                else
                    dj = -DJ_PEAK;
            end else begin
                dj = 0.0;
            end

            // -------- Combined UI offset --------
            ui_offset = rj + dj;

            // "Virtual" sampling instant (for analysis/trace)
            sample_time = $time + ui_offset;

            // -------- BER injector (optional) --------
            if (enable_ber && ($urandom_real() < BER)) begin
                serial_out <= ~serial_in; // bit flip
            end else begin
                serial_out <= serial_in;
            end
        end
    end

endmodule
