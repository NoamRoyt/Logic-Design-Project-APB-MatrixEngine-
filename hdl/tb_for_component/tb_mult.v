`timescale 1ns/10ps

module tb_mult;

// Testbench uses the same parameter values as the module
parameter data_width = 16;
parameter addr_width = 32;
parameter bus_width = 64;
parameter sp_ntargets = 4;

// Declare inputs as reg and outputs as wire
reg clk_i;
reg reset_ni;
reg psel_i;
reg penable_i;
reg pwrite_i;
reg [bus_width/data_width-1:0] pstrb_i;
reg [bus_width-1:0] pwdata_i;
reg [addr_width-1:0] paddr_i;

wire pready_o;
wire pslverr_o;
wire [bus_width-1:0] prdata_o;
wire busy_o;
wire done;
integer i;

// Instantiate the Unit Under Test (UUT)
abp #(
    .data_width(data_width),
    .addr_width(addr_width),
    .bus_width(bus_width),
    .sp_ntargets(sp_ntargets)
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
    .busy_o(busy_o),
	.done_o(done)
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
	//0000100
	//0001100
    // Reset the system
    #100;
    reset_ni = 0; // Release reset
	///matrix a 
    // Start a write operation
    #10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h0004; // Specify the address to write to   0-27  0 controle register 1,2,3 none 4 -7 matrix x 8 - 11 matrix b 
    pwdata_i = 64'h0004000300020001; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h0004; // Specify the address to write to   0-27  0 controle register 1,2,3 none 4 -7 matrix x 8 - 11 matrix b 
    pwdata_i = 64'h0004000300020001; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 1; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 4+32; // Specify the address to write to
    pwdata_i = 64'h0008000700060005; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 4+32; // Specify the address to write to
    pwdata_i = 64'h0008000700060005; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 1; // Enable the transaction
	pstrb_i = 4'b1111;
    // Complete the write operation
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 4+64; // Specify the address to write to
    pwdata_i = 64'h000c000b000a0009; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
	penable_i = 1; // Enable the transaction
    // Complete the write operation
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = paddr_i+32; // Specify the address to write to
    pwdata_i = 64'h0010000f000e000d; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
		#10;
	penable_i = 1; // Enable the transaction
    // Complete the write operation
	///////// matrix b 
    #10;
	    psel_i = 1; // Select the peripheral
    paddr_i = 8; // Specify the address to write to
    pwdata_i = 64'h0005000400030002; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
		#10;
	penable_i = 1; // Enable the transaction
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = paddr_i+32; // Specify the address to write to
    pwdata_i = 64'h0008000700060005; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
		#10;
	penable_i = 1; // Enable the transaction
    // Complete the write operation
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = paddr_i+32; // Specify the address to write to
    pwdata_i = 64'h000c000b000a0009; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
		#10;
	penable_i = 1; // Enable the transaction
    // Complete the write operation
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = paddr_i+32; // Specify the address to write to
    pwdata_i = 64'h0110000f000e000d; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
		#10;
	penable_i = 1; // Enable the transaction
    // Complete the write operation
	
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h000000000; // Specify the address to write to
    pwdata_i = 64'h0010000f00000005; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
	penable_i = 1;
	

	wait(done==1);
		#10;
		psel_i = 1; // Select the peripheral
		paddr_i = 4 ; // Specify the address to write to
		pwdata_i = 64'h0004000300020001; // Data to write
		pwrite_i = 1; // Enable write operation
		penable_i = 0; // Enable the transaction
		pstrb_i = 4'b1111;
		#10;
		penable_i = 1;
	for ( i = 0 ; i < 7 ; i = i + 1) begin
		#10;
		if (i == 3)begin
			paddr_i = 8;
		end
		else begin
			paddr_i = paddr_i + 32; // Specify the address to write to
		end
		psel_i = 1; // Select the peripheral
		pwdata_i[15:0]   = pwdata_i[15:0] + 1;
        pwdata_i[31:16]  = pwdata_i[31:16] + 1;
        pwdata_i[47:32]  = pwdata_i[47:32] + 1;
        pwdata_i[63:48]  = pwdata_i[63:48] + 1;
		pwrite_i = 1; // Enable write operation
		penable_i = 0; // Enable the transaction
		pstrb_i = 4'b1111;
		#10;
		penable_i = 1;
		end
	
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h000000000; // Specify the address to write to
    pwdata_i = 64'h0010000f0000001b; // Data to write
    pwrite_i = 1; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
	penable_i = 1;
	
	wait(done==1);
	#10;
    psel_i = 1; // Select the peripheral
    paddr_i = 32'h000000000; // Specify the address to write to
    pwdata_i = 64'h0010000f0000001b; // Data to write
    pwrite_i = 0; // Enable write operation
    penable_i = 0; // Enable the transaction
	pstrb_i = 4'b1111;
	#10;
	penable_i = 1;
	
    #100;
    $finish;
end

endmodule
