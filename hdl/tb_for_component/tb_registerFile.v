`timescale 1ns/10ps

module tb_registerFile;

// Testbench uses the same parameter values as the module
parameter DataWidth = 16;
parameter MAX_DIM = 4;
parameter AddrWidth = 32;
parameter BusWidth = 64;
parameter SP_NTARGETS = 4;

// Declare inputs as reg and outputs as wire
reg clk_i;
reg reset_ni;
reg psel_i;
reg penable_i;
reg pwrite_i;
reg [MAX_DIM-1:0] pstrb_i;
reg [BusWidth-1:0] pwdata_i;
reg [AddrWidth-1:0] paddr_i;

wire pready_o;
wire pslverr_o;
wire [BusWidth-1:0] prdata_o;
wire busy_o;

// Instantiate the Unit Under Test (UUT)
ABP #(
    .DataWidth(DataWidth),
    .MAX_DIM(MAX_DIM),
    .AddrWidth(AddrWidth),
    .BusWidth(BusWidth),
    .SP_NTARGETS(SP_NTARGETS)
) uut (
    .clk_i(clk_i),
    .reset_ni(reset_ni),
    .psel_i(psel_i),
    .penable_i(penable_i),
    .pwrite_i(pwrite_i),
    .pstrb_i(pstrb_i),
    .pwdata_i(pwdata_i),
    .paddr_i(paddr_i),
    .pready_o(pready_o),
    .pslverr_o(pslverr_o),
    .prdata_o(prdata_o),
    .busy_o(busy_o)
);

// Clock generation
initial begin
    clk_i = 0;
    forever #5 clk_i = ~clk_i; // 100MHz clock
end

// Test sequence
initial begin
    // Initialize Inputs
    reset_ni = 1;
    psel_i = 0;
    penable_i = 0;
    pwrite_i = 0;
    pstrb_i = 0;
    pwdata_i = 0;
    paddr_i = 0;

    // Reset the system
    #100;
    reset_ni = 0; // Release reset

    // Start a write operation
    #10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h0004; // Specify the address to write to
    pwdata_i = 64'h0004000300020001; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 1; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h0005; // Specify the address to write to
    pwdata_i = 64'h0008000700060005; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 1; // Enable the transaction
	pstrb_i = 4'b1111;
    // Complete the write operation
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h0006; // Specify the address to write to
    pwdata_i = 64'h000c000b000a0009; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 1; // Enable the transaction
	pstrb_i = 4'b1111;
    // Complete the write operation
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h00000007; // Specify the address to write to
    pwdata_i = 64'h0010000f000e000d; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 1; // Enable the transaction
	pstrb_i = 4'b1111;
    // Complete the write operation
    #10;
	
    penable_i = 0;

    // Add more operations as needed...

    // Finish the simulation
    #100;
    $finish;
end

endmodule