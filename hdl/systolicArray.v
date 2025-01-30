
// Verilog Module project1_lib.systolic_array
//
// Created:
//          by - 97252.UNKNOWN (LAPTOP-787PJRJU)
//          at - 16:14:53 16/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`resetall 
`timescale 1ns/10ps
`include "pe.v"
module systolic_array #(
    parameter data_width = 32,
	parameter bus_width = 64
)
(clk,done_paddign,reset,mode_bit,done,start_bit,pwdata_from_sp,A,B,result, pwdata_to_sp,overflow_o,finsh_calculte_to_sp);
localparam max_dim = bus_width/data_width ;
    input wire clk;
	input wire done_paddign;
	input wire reset;
	input wire mode_bit;
	input wire done;
	input wire start_bit;
	input wire [max_dim*max_dim*bus_width -1 : 0] pwdata_from_sp;
  	input wire [max_dim*data_width-1:0] A; // Flatten the input array A
        input wire [max_dim*data_width-1:0] B; // Flatten the input array B
        output reg [max_dim*max_dim*bus_width-1:0] result; // Flatten the output array result
	output reg [max_dim*max_dim*bus_width-1:0] pwdata_to_sp;
	output wire [max_dim*max_dim-1:0] overflow_o;
	output wire finsh_calculte_to_sp;
	

// Internal wire arrays for communication between PEs
wire [data_width-1:0] continue_A [max_dim*max_dim-1:0];
wire [data_width-1:0] continue_B [max_dim*max_dim-1:0];

// Internal wire arrays to store intermediate results between PEs
wire [bus_width-1:0] intermediate_result [max_dim*max_dim-1:0];
wire [max_dim*max_dim-1:0] overflow;
reg finsh_calculte;

reg [max_dim*max_dim-1:0] counter ;

	
assign finsh_calculte_to_sp = finsh_calculte;
assign overflow_o = overflow;	
// for write to sp 
genvar p; 
generate for(p = 0 ; p < max_dim*max_dim ; p = p +1) begin
	always @(posedge clk )begin
		if(reset)begin
			pwdata_to_sp<=0;
			counter<=0;
		end
		else if (finsh_calculte) begin 
			pwdata_to_sp[bus_width*(p+1) - 1 :bus_width*p] <=intermediate_result[p];
			
		end 
	end
end
endgenerate
		



// PE instances
genvar i, j;
generate
    for (i = 0; i < max_dim; i = i + 1) begin : row_loop
        for (j = 0; j < max_dim; j = j + 1) begin : col_loop
            if (i == 0 && j == 0) begin
                pe #( // this is for PE0 that need to get all the input from row 0 in matrix a and all input from cloume 0 from matrix b 
                    .data_width(data_width),
					.bus_width(bus_width)
					) pe_inst (
                    .clk(clk),
                    .reset(reset),
                    .a(A[data_width-1:0]), //7:0 if data_width = 8 , max_dim = 4 
                    .b(B[data_width-1:0]),// 7:0  if data_width = 8 , max_dim = 4 
					.c(pwdata_from_sp[bus_width*(i*max_dim+j+1)-1:bus_width*(i*max_dim+j)]),
					.done(done),
                    .continue_a(continue_A[0]),
                    .continue_b(continue_B[0]),
                    .result(intermediate_result[0]),
					.overflow(overflow[0]),
					.mode_bit(mode_bit)
					
                );
            end else if (i == 0) begin
              pe #(
        .data_width(data_width),
		.bus_width(bus_width)
    ) pe_inst (
        .clk(clk),
        .reset(reset),
        .a(continue_A[j-1]),
        .b(B[(data_width*(1+j))-1: data_width*j]), // Corrected line
		.c(pwdata_from_sp[bus_width*(i*max_dim+j+1)-1:bus_width*(i*max_dim+j)]),
		.done(done),
        .continue_a(continue_A[i*max_dim+j]),
        .continue_b(continue_B[i*max_dim+j]),
        .result(intermediate_result[i*max_dim+j]),
		.overflow(overflow[i*max_dim+j]),
		.mode_bit(mode_bit)
    );
            end else if (j == 0) begin
                pe #(
                    .data_width(data_width),
					.bus_width(bus_width)
                  ) pe_inst (
                    .clk(clk),
                    .reset(reset),
                    .a(A[(((data_width)*(i+1)) -1):(data_width)*(i)]), //j==0 i =1 
                    .b(continue_B[(i-1)*max_dim]),
					.c(pwdata_from_sp[bus_width*(i*max_dim+j+1)-1:bus_width*(i*max_dim+j)]),
					.done(done),
                    .continue_a(continue_A[i*max_dim+j]),
                    .continue_b(continue_B[i*max_dim+j]),
                    .result(intermediate_result[i*max_dim+j]),
					.overflow(overflow[i*max_dim+j]),
					.mode_bit(mode_bit)
                );
            end else begin
                pe #(
                    .data_width(data_width),
					.bus_width(bus_width)
                ) pe_inst (
                    .clk(clk),
                    .reset(reset),
                    .a(continue_A[i*max_dim+j-1]),
                    .b(continue_B[(i-1)*max_dim+j]),
                    .continue_a(continue_A[i*max_dim+j]),
					.done(done),
                    .continue_b(continue_B[i*max_dim+j]),
					.c(pwdata_from_sp[bus_width*(i*max_dim+j+1)-1:bus_width*(i*max_dim+j)]),
                    .result(intermediate_result[i*max_dim+j]),
					.overflow(overflow[i*max_dim+j]),
					.mode_bit(mode_bit)
                );
            end
        end
    end
endgenerate 

always @(posedge clk) begin
	if ((counter < 3*max_dim - 1) && done_paddign && start_bit ) begin
		counter <= counter + 1 ; 
	end 
	
	else if (counter == 3*max_dim - 1) begin
		finsh_calculte <= 1;
		counter <= 0;
	end
	else begin
		finsh_calculte<=0;
		counter <= 0;

	end
end
		
endmodule
	
