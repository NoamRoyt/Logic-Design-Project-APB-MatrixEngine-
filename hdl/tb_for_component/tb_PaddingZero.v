`timescale 1ns/10ps
`include "PaddingZero.v"

module tb_PaddingZero;

// Testbench Parameters
parameter DATA_WIDTH = 32;
parameter MAX_DIM = 3; // Adjusted for a 3x3 matrix input
parameter CLOCK_PERIOD = 10; // Clock period in ns

// Testbench Signals
reg CLK_T;
reg reset;
reg write_enable_A;
reg [DATA_WIDTH-1:0] bus;
wire [DATA_WIDTH*MAX_DIM -1 : 0] vectorA ;
// Instantiate the Unit Under Test (UUT)
PaddingZero #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_DIM(MAX_DIM)
) uut (
    .clk(CLK_T),
    .reset(reset),
    .write_enable_A(write_enable_A),
    .bus(bus),
	.vectorA(vectorA)
);


// Clock generation
initial begin
    CLK_T = 0;
    forever #5 CLK_T = !CLK_T; // Generate a clock with a period of 10ps
end

// Test sequence
initial begin
    // Initialize Inputs
    reset = 1; // Start in reset state
    write_enable_A = 0; // Ensure write_enable_A is initially low
    bus = 0; // Initialize bus to a known state

    // Wait for global reset
    #(CLOCK_PERIOD*2);
    reset = 0; // Release reset
    #(CLOCK_PERIOD*2); // Wait a bit longer after releasing reset for the system to stabilize

    // Start writing matrix values
    write_enable_A = 1; // Enable writing
    bus = 32'd1; #(CLOCK_PERIOD);
    bus = 32'd2; #(CLOCK_PERIOD);
    bus = 32'd3; #(CLOCK_PERIOD);
    bus = 32'd4; #(CLOCK_PERIOD);
    bus = 32'd5; #(CLOCK_PERIOD);
    bus = 32'd6; #(CLOCK_PERIOD);
    bus = 32'd7; #(CLOCK_PERIOD);
    bus = 32'd8; #(CLOCK_PERIOD);
    bus = 32'd9; #(CLOCK_PERIOD);
    write_enable_A = 0; // Disable write after the last value

    // Wait for padding to complete
   #(CLOCK_PERIOD*20);

    // Add additional checks or operations here if needed

    $finish; // End simulation
end

endmodule