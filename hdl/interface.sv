`include "headers.vh"

interface interface_matmul (input logic clk, input logic rst);
	import matmul_pkg::*;

	logic psel, penable, pwrite;	
	logic [MAX_DIM-1:0] pstrb;
	logic [BUS_WIDTH-1:0] pwdata;
	logic [ADDR_WIDTH-1:0] paddr;
	logic pready, pslverr,busy,done;
	logic [BUS_WIDTH-1:0] prdata;
	logic finsh_calculte;
	logic [MAX_DIM*MAX_DIM*BUS_WIDTH-1:0] pwdata_from_systolic_to_sp_i;
	logic [1:0] finsh_check_o;
	logic golden_done_o;




	modport DEVICE  (input  clk, rst, psel, penable, pwrite, pstrb,
						pwdata, paddr, output finsh_calculte, pready, pslverr, prdata, busy,done,pwdata_from_systolic_to_sp_i);
	modport STIMULUS (output  clk, rst, psel, penable, pwrite, pstrb,
						pwdata, paddr, input pready, pslverr, prdata, busy,done,finsh_check_o);
	modport GOLDEN(input done, clk, rst, pwdata_from_systolic_to_sp_i, finsh_check_o, finsh_calculte, output golden_done_o);

endinterface
