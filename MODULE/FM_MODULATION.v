module fm_modulator (
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire audio_in,     // Audio input (e.g., from a microphone)
    output wire fm_out       // FM-modulated output
);
    reg [15:0] phase_accumulator = 16'h0000;  // Phase accumulator
    reg [15:0] frequency_deviation = 16'h1000; // Frequency deviation (adjust as needed)

    always @(posedge clk or posedge reset) begin
        if (reset)
            phase_accumulator <= 16'h0000;
        else
            phase_accumulator <= phase_accumulator + frequency_deviation;
    end

    assign fm_out = sin(phase_accumulator); // FM-modulated output (sine wave)
endmodule
