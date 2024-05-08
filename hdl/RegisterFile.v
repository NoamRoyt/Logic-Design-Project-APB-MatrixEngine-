`resetall 
`timescale 1ns/10ps


/*In this module we had oprand a and oprand b. 
This module include 2 take he can do read from oprands and write to oprands.
Also every time this module oprate he first clean the oprands from previous elements 

*/

module RegisterFile #(
	parameter data_width  = 16, // Number of bits in a data unit
	parameter addr_width = 4, // Number of bits in an address, means the're 16 registers in the RF
	parameter bus_width = 64

	
) 
	 
(clk,reset,start_bit,writeEn_reg,done,row, pstrb,Addr,write_data,readData,dim_n,dim_k,dim_m,readData_for_matrix_a,readData_for_matrix_b,write_enable_A,write_enable_B,check_write);
	localparam max_dim = bus_width/data_width ;
	input  wire                	clk;
	input  wire                	reset;
	input  wire 				start_bit;
	input  wire                	writeEn_reg;
	input wire					done;
	input wire 	[1:0]			dim_n;
	input wire 	[1:0]			dim_k;
	input wire 	[1:0]			dim_m;
	input  wire [$clog2(max_dim) -1: 0] row; 
	input  wire [max_dim -1 : 0] pstrb;
	input  wire [4:0]	Addr;
	input  wire [bus_width-1:0]	write_data;
	output reg [bus_width-1:0]	readData;
	output reg [bus_width-1:0]	readData_for_matrix_a;
	output reg [bus_width-1:0]	readData_for_matrix_b;
	output reg write_enable_A;
	output reg write_enable_B;
	// for test
	output reg  [bus_width-1:0] check_write;
	reg radyA;
	reg radyB;
	reg [bus_width-1:0] RegFile[15:0];
	reg [4:0]pointer_matrix_a ;
	reg [4:0]pointer_matrix_b ;
	
	integer i ;
	
	always @( posedge clk) begin
		if (reset) begin
			radyA<=1;
			radyB<=1;
			pointer_matrix_a<=4;
			pointer_matrix_b<=8;
			for(i = 0 ; i< 16; i = i +1 ) begin 
				RegFile[i] <= 0;
			end
		end
		else if (done) begin
			radyA<=1;
			radyB<=1;
			pointer_matrix_a<=4;
			pointer_matrix_b<=8;
		end
	end 
	// clean oprand matrix A
	genvar row_delet,col_delet;
	generate
	for (row_delet = 0 ; row_delet < max_dim ; row_delet = row_delet +1 ) begin
		for(col_delet = 0; col_delet < max_dim ; col_delet = col_delet + 1) begin
			always @(*) begin
				if (writeEn_reg && Addr == 4) begin
					if (row_delet > dim_n) begin
						RegFile[Addr+ row_delet] <= 0;
					end
					else if (col_delet > dim_k)begin
						RegFile[Addr+ col_delet][(col_delet+1)*data_width - 1 : col_delet*data_width] <=0;
					end
				end 
			end

		end
	end
	endgenerate
		// clean oprand matrix B 
	genvar row_delet_b,col_delet_b;
	generate
	for (row_delet_b = 0 ; row_delet_b < max_dim ; row_delet_b = row_delet_b +1 ) begin
		for(col_delet_b = 0; col_delet_b < max_dim ; col_delet_b = col_delet_b + 1) begin
			always @(*) begin
				if (writeEn_reg && Addr == 8) begin
					if (row_delet_b > dim_k) begin
						RegFile[Addr+ row_delet_b] <= 0;
					end
					else if (col_delet_b > dim_k)begin
						RegFile[Addr+ col_delet_b][(col_delet_b+1)*data_width - 1 : col_delet_b*data_width] <=0;
					end
				end 
			end

		end
	end
	endgenerate
	

	// read and write to matrix A
	genvar k;
	generate for (k = 0 ; k < max_dim ; k = k +1 ) begin
		always @(*) begin
			if (writeEn_reg && Addr == 4) begin
				if(row<=dim_n && k <= dim_k) begin
					if (pstrb[k]) begin
						RegFile[Addr+ row][(k+1)*data_width - 1 : k*data_width] <= write_data[(k+1)*data_width - 1 : k*data_width];
						check_write[(k+1)*data_width - 1 : k*data_width] <= write_data[(k+1)*data_width - 1 : k*data_width];
					end 
					else begin
						RegFile[Addr+ row][(k+1)*data_width - 1 : k*data_width] <= RegFile[Addr+ row][(k+1)*data_width - 1 : k*data_width];
					end
				end 
				else begin
					RegFile[Addr+ row][(k+1)*data_width - 1 : k*data_width]<=0;
				end
			end
			else begin
				readData <= RegFile[Addr + row];
			end
		end
	end
	endgenerate
	
	
	// read and write to matrix B 
	genvar j;
	generate for (j = 0 ; j < max_dim ; j = j +1 ) begin
		always @(*) begin
			if (writeEn_reg && Addr == 8) begin
				if(row<=dim_k && j <= dim_m) begin
					if (pstrb[j]) begin
						RegFile[Addr+ row][(j+1)*data_width - 1 : j*data_width] <= write_data[(j+1)*data_width - 1 : j*data_width];
						check_write[(j+1)*data_width - 1 : j*data_width] <= write_data[(j+1)*data_width - 1 : j*data_width];
					end 
					else begin
						RegFile[Addr+ row][(j+1)*data_width - 1 : j*data_width] <= RegFile[Addr+ row][(j+1)*data_width - 1 : j*data_width];
					end
				end 
				else begin
					RegFile[Addr+ row][(j+1)*data_width - 1 : j*data_width]<=0;
				end
			end
			else begin
				readData <= RegFile[Addr + row];
			end
		end
	end
	endgenerate
	

	
	// transfer the Matrix A to padding  
	always @(posedge clk) begin
		if ( start_bit) begin
			if ((pointer_matrix_a >= 4 && pointer_matrix_a<= 7) && radyB) begin // need to  4 + N 
				write_enable_A<=1;
				readData_for_matrix_a<=RegFile[pointer_matrix_a];
				pointer_matrix_a <= pointer_matrix_a + 1;
			end
			else begin
				readData_for_matrix_a<=0;
				pointer_matrix_a <= 4;
				write_enable_A<=0;
				radyB<=0;
			end 
		end
	end
	
	
		// transfer the Matrix B  to padding  
	always @(posedge clk) begin
		if ( start_bit) begin
			if ((pointer_matrix_b >= 8 && pointer_matrix_b<= 11) && radyA) begin //need to do 8 + c
				write_enable_B<=1;
				readData_for_matrix_b<=RegFile[pointer_matrix_b];
				pointer_matrix_b<= pointer_matrix_b +1;
			end
			else begin
				readData_for_matrix_b<=0;
				pointer_matrix_b <= 8;
				write_enable_B<=0;
				radyA<=0;
			end 
		end
	end
			
		

			
	
	
	
	
		
endmodule