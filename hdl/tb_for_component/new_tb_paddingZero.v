`timescale 1ns/10ps
`include "PaddingZeroA.v"
`include "PaddingZeroB.v"
`include "systolicArray.v"
module new_tb_PaddingZero;

// Parameters
parameter DATA_WIDTH = 32;
parameter MAX_DIM = 4;

// Inputs
reg clk;
reg reset;
reg write_enable_A;
reg write_enable_B;
reg [MAX_DIM*DATA_WIDTH-1:0] bus;


// Outputs
wire [DATA_WIDTH*MAX_DIM-1:0] vectorA;
wire [DATA_WIDTH*MAX_DIM-1:0] vectorB;

// inOut
wire done_paddignB;
wire done_paddignA;
wire [DATA_WIDTH*MAX_DIM*(2*MAX_DIM-1) -1 :0] check_padding;
wire [DATA_WIDTH*MAX_DIM*MAX_DIM-1:0] check_matrix_A;
wire [DATA_WIDTH*MAX_DIM*MAX_DIM-1:0] check_matrix_B;
wire [MAX_DIM*MAX_DIM*DATA_WIDTH*2-1:0] result;
// Instantiate the Unit Under Test (UUT)
PaddingZeroA #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_DIM(MAX_DIM)
) uutA (
    .clk(clk),
    .reset(reset),
    .write_enable_A(write_enable_A),
    .bus(bus),
    .vectorA(vectorA),
    .done_paddign_A(done_paddignA),
	.done_paddignB(done_paddignB),
	//.check_padding(check_padding),
	.check_matrix_A(check_matrix_A)
);

PaddingZeroB #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_DIM(MAX_DIM)
) uutB (
    .clk(clk),
    .reset(reset),
    .write_enable_B(write_enable_B),
    .bus(bus),
    .vectorB(vectorB),
    .done_paddignA(done_paddignA),
	.done_paddign_B(done_paddignB),
	.check_padding(check_padding),
	.check_matrix_B(check_matrix_B)
);

systolic_array #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_DIM(MAX_DIM)
) uut (
    .clk(clk),
    .reset(reset),
    .A(vectorA),
    .B(vectorB),
    .result(result)
);

// Clock generation
always #5 clk = ~clk; // 100MHz clock

// Test sequence
initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    write_enable_A = 0;
	write_enable_B = 0;
    bus = 0;

    // Wait for global reset
    #100;
    reset = 0;

    // Write data into the module
    //@(posedge clk);
   // write_enable_A = 1;
    
    // Example: Writing a 4x4 matrix with arbitrary data
	write_enable_A = 1;
    bus[DATA_WIDTH*1 -1 :0] = 1;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 2;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 3;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 4;
	#10;
	bus[DATA_WIDTH*1 -1 :0] = 5;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 6;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 7;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 8;
	#10;
	bus[DATA_WIDTH*1 -1 :0] = 9;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 10;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 11;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 12;
	#10;
	bus[DATA_WIDTH*1 -1 :0] = 13;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 14;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 15;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 16;
	#10;
    // Disable write enable
    write_enable_A = 0;
	#10;
	write_enable_B = 1;
    bus[DATA_WIDTH*1 -1 :0] = 3;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 4;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 5;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 6;
	#10;
	bus[DATA_WIDTH*1 -1 :0] = 5;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 6;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 7;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 8;
	#10;
	bus[DATA_WIDTH*1 -1 :0] = 9;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 10;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 11;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 12;
	#10;
	bus[DATA_WIDTH*1 -1 :0] = 13;
	bus[DATA_WIDTH*2 -1 :DATA_WIDTH*1] = 14;
	bus[DATA_WIDTH*3 -1 :DATA_WIDTH*2]= 15;
	bus[DATA_WIDTH*4 -1 :DATA_WIDTH*3]= 16;
	#10;
    // Disable write enable
    write_enable_B = 0;



    // Wait for padding operation to complete
    wait(done_paddignB == 1 && done_paddignA == 1);
    
    // Complete the simulation
    #100;
    $finish;
end

// Optionally, add a waveform dump
/*
initial begin
    $dumpfile("new_tb_PaddingZero.vcd");
    $dumpvars(0, new_tb_PaddingZero);
end
*/
endmodule