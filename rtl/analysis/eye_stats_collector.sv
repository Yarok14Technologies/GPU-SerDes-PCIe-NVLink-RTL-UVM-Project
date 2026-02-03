module eye_stats_collector #(
    parameter SAMPLE_WINDOW = 100_000   // Number of UI samples per report
)(
    input  logic clk,
    input  logic rst_n,

    // Tap this to the serial stream AFTER channel or at RX input
    input  logic serial_in,

    // Optional: tap to CDR lock if available
    input  logic cdr_lock
);

    // Counters
    integer total_samples;
    integer high_samples;
    integer low_samples;
    integer transition_count;

    logic prev_bit;

    // Main sampling process (1 sample per clk = 1 UI abstraction)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total_samples    <= 0;
            high_samples     <= 0;
            low_samples      <= 0;
            transition_count <= 0;
            prev_bit         <= 1'b0;
        end else begin
            total_samples <= total_samples + 1;

            // Count eye vertical opening proxy (voltage margin abstraction)
            if (serial_in)
                high_samples <= high_samples + 1;
            else
                low_samples  <= low_samples + 1;

            // Count transitions (proxy for eye width / timing margin)
            if (serial_in != prev_bit)
                transition_count <= transition_count + 1;

            prev_bit <= serial_in;

            // Periodic reporting window
            if (total_samples % SAMPLE_WINDOW == 0) begin
                real eye_open_ratio;
                real transition_density;

                eye_open_ratio = real'(high_samples) / real'(total_samples);
                transition_density = real'(transition_count) / real'(total_samples);

                $display("=== EYE STATS REPORT @ %0t ===", $time);
                $display("Total Samples       = %0d", total_samples);
                $display("High Samples        = %0d", high_samples);
                $display("Low Samples         = %0d", low_samples);
                $display("Eye Open Ratio      = %f", eye_open_ratio);
                $display("Transition Density  = %f", transition_density);
                $display("CDR Lock Status     = %0b", cdr_lock);
                $display("=====================================");
            end
        end
    end

    // Final summary at end of simulation
    final begin
        real final_eye_ratio;
        real final_trans_density;

        final_eye_ratio     = real'(high_samples) / real'(total_samples);
        final_trans_density = real'(transition_count) / real'(total_samples);

        $display("\n===== FINAL EYE SUMMARY =====");
        $display("Total Samples       = %0d", total_samples);
        $display("Eye Open Ratio      = %f", final_eye_ratio);
        $display("Transition Density  = %f", final_trans_density);
        $display("=============================\n");
    end

endmodule
