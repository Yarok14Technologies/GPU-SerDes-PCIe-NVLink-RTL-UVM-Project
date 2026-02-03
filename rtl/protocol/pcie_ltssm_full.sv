// ===============================================================
// File: rtl/protocol/pcie_ltssm_full.sv
// Description: Behavioral PCIe-like LTSSM (Link Training and
//              Status State Machine) with L0/L0s/L1/L2/L3,
//              RECOVERY and RETRAIN.
// ===============================================================

module pcie_ltssm_full (
    input  logic clk,
    input  logic rst_n,

    // Control inputs from PHY/PCS or testbench
    input  logic training_req,     // request to retrain link
    input  logic idle_req,         // request to enter low power
    input  logic error_detected,   // CRC/BER/link error indication
    input  logic wake_req,         // wake from L2/L3

    // Status outputs
    output logic link_up,          // true when in L0
    output logic [3:0] state       // current LTSSM state
);

    // -----------------------------------------------------------
    // LTSSM State Encoding (PCIe-like)
    // -----------------------------------------------------------
    typedef enum logic [3:0] {
        DETECT   = 4'b0000,
        POLLING  = 4'b0001,
        CONFIG   = 4'b0010,
        L0       = 4'b0011,
        L0s      = 4'b0100,
        L1       = 4'b0101,
        L2       = 4'b0110,
        L3       = 4'b0111,
        RECOVERY = 4'b1000,
        RETRAIN  = 4'b1001
    } ltssm_t;

    ltssm_t curr_state, next_state;

    // -----------------------------------------------------------
    // State Register
    // -----------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= DETECT;
        else
            curr_state <= next_state;
    end

    // -----------------------------------------------------------
    // Next-State Logic (Behavioral PCIe LTSSM)
    // -----------------------------------------------------------
    always_comb begin
        next_state = curr_state;

        case (curr_state)

            // ----------------------------
            DETECT:
            // ----------------------------
            // Link presence detection
            begin
                next_state = POLLING;
            end

            // ----------------------------
            POLLING:
            // ----------------------------
            // Basic link initialization
            begin
                next_state = CONFIG;
            end

            // ----------------------------
            CONFIG:
            // ----------------------------
            // Negotiation of link parameters
            begin
                next_state = L0;
            end

            // ----------------------------
            L0 (Active State):
            // ----------------------------
            begin
                if (idle_req)
                    next_state = L0s;
                else if (training_req)
                    next_state = RETRAIN;
                else if (error_detected)
                    next_state = RECOVERY;
            end

            // ----------------------------
            L0s (Low Power Idle - Fast Exit):
            // ----------------------------
            begin
                if (!idle_req)
                    next_state = L0;
                else if (error_detected)
                    next_state = RECOVERY;
            end

            // ----------------------------
            L1 (Sleep - Medium Exit Latency):
            // ----------------------------
            begin
                if (training_req)
                    next_state = RETRAIN;
                else if (error_detected)
                    next_state = RECOVERY;
                else if (wake_req)
                    next_state = L0;
            end

            // ----------------------------
            L2 (Deep Power Save):
            // ----------------------------
            begin
                if (wake_req)
                    next_state = L0;
            end

            // ----------------------------
            L3 (Off State):
            // ----------------------------
            begin
                if (wake_req)
                    next_state = DETECT;
            end

            // ----------------------------
            RECOVERY:
            // ----------------------------
            // Handle errors, then restart training
            begin
                next_state = POLLING;
            end

            // ----------------------------
            RETRAIN:
            // ----------------------------
            // Explicit retraining request
            begin
                next_state = POLLING;
            end

            default: next_state = DETECT;
        endcase
    end

    // -----------------------------------------------------------
    // Outputs
    // -----------------------------------------------------------

    // Expose state as 4-bit code (useful for UVM coverage)
    assign state = curr_state;

    // Link is considered "up" only in L0
    assign link_up = (curr_state == L0);

endmodule
