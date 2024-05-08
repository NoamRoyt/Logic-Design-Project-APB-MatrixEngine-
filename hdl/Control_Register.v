`resetall 
`timescale 1ns/10ps
module Control_register #(
    parameter data_width = 32,
    parameter bus_width = 64
)
(
	input wire [15:0] ctrl_write_i, 
	input wire clk , 
	input wire reset_ni,
	input wire done_i,
	output wire start_bit,
	output wire mode_bit,
	output wire [1:0] write_target,
	output wire [1:0] read_target,
	output wire [1:0] data_flow,
	output wire [1:0] Dim_N, //row dimension of matrix A and matrix C  
	output wire [1:0] Dim_kk, // column  of matrix A and row of matrix B 
	output wire [1:0] Dim_M, // column  of matrix B and column  of matrix C 
	output wire reload_operand_A,
	output wire reload_operand_B,
	output wire [15:0] ctrl_reg_o
);
	localparam max_dim = bus_width/data_width ;
reg [15:0] mem;

always @(posedge clk or negedge reset_ni) begin
    if (reset_ni) begin
        mem <= 0;
    end else begin
		if(done_i)
			mem <= 0;
		else
			mem <= ctrl_write_i;
    end
end

assign ctrl_reg_o = mem;
assign  start_bit = ctrl_write_i[0];
assign  mode_bit = ctrl_write_i[1];
assign  write_target = ctrl_write_i[3:2];
assign  read_target = ctrl_write_i[5:4];
assign  data_flow = ctrl_write_i[7:6];
assign  Dim_N = ctrl_write_i[9:8];
assign  Dim_kk = ctrl_write_i[11:10];
assign  Dim_M = ctrl_write_i[13:12];
assign  reload_operand_A = ctrl_write_i[14];
assign  reload_operand_B = ctrl_write_i[15];

endmodule
