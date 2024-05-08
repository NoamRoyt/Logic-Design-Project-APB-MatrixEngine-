`timescale 1ns/10ps

module tb_Systolic_Mul;

// Parameters
parameter DATA_WIDTH = 8;
parameter MAX_DIM = 2;

reg clk;
reg reset;
reg [MAX_DIM*DATA_WIDTH-1:0] A;
reg [MAX_DIM*DATA_WIDTH-1:0] B;
wire [MAX_DIM*MAX_DIM*DATA_WIDTH*2-1:0] result;

// Instantiate the Unit Under Test (UUT)
systolic_array #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_DIM(MAX_DIM)
) uut (
    .clk(clk),
    .reset(reset),
    .A(A),
    .B(B),
    .result(result)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = !clk; // Generate a clock with a period of 10ps
end

// Initial block to simulate the input sequence
initial begin
    // Initial reset
    reset = 1;
    #20; // Wait for 20ps to ensure reset is properly applied
    reset = 0;

    // First input
    A = 16'b0000000000000001; // A = [0, 1]
    B = 16'b0000000000000101; // B = [0, 5]
    #10; // Wait for one clock cycle

    // Second input
    A = 16'b0000001100000010; // A = [1, 3]
    B = 16'b0000011000000111; // B = [1, 3]
    #10; // Wait for one clock cycle

    // Third input
    A = 16'b0000010000000000; // A = [2, 0]
    B = 16'b0000000000000000; // B = [3, 0]
    #10; // Wait for one clock cycle
	    // Third input
    A = 16'b0000000000000000; // A = [0, 0]
    B = 16'b0000000000000000; // B = [0, 0]
    #10; // Wait for one clock cycle

    // End of simulation
    $finish;
end

endmodule