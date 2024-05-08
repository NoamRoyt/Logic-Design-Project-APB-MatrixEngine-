//
// Verilog Module project1_lib.padding_zero
//
// Created:
//          by - 97252.UNKNOWN (LAPTOP-787PJRJU)
//          at - 13:46:14 16/02/2024
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//
//
//
//
//
//
//
//
`resetall 
`timescale 1ns/10ps
module PaddingZeroB #(
    parameter data_width = 32,
	parameter bus_width = 64
	//parameter N = 2 // row
	//parameter K = 3 // col
)
	(
     clk,
    reset,
	 write_enable_B,
	 start_bit,
	 done,
   	  bus, // for red from the memory 
	 done_paddignA,
	  vectorB ,
	 done_paddign_B,

    
);
localparam max_dim = bus_width/data_width ;

    input wire clk;
    input wire reset;
	input wire write_enable_B;
	input wire start_bit;
	input wire done;
    input wire [max_dim*data_width-1:0] bus; // for red from the memory 
	input wire done_paddignA;
	output reg [data_width*max_dim -1 : 0] vectorB;
	output wire done_paddign_B;


// signal for matrixB
reg [data_width-1:0] matrixB [max_dim*max_dim-1:0];
reg done_read_matrixB; // tell when finsh to read from the memory 
reg [data_width -1 :0] current_row;
reg internal_write_enable;
// signal for padding matrixB
reg [data_width-1:0] matrixB_padded [max_dim*(2*max_dim-1):0];
reg done_paddignB;
// siganl for move foward the element from paddign matrixB to systolic array 
reg [2*max_dim : 0 ] iteration_count_fowaord;
reg finsh_foword_b;

//---------------- first read from the memore to oprand B -------------------


genvar k;
generate
    for (k = 0; k < max_dim; k = k + 1) begin : gen_blk // Label the block for clarity
        always @(posedge clk) begin
            if (write_enable_B && internal_write_enable) begin
                matrixB[(current_row-1) * max_dim + k] <= bus[data_width * (k + 1) - 1 : data_width * k];
	    end
        end
    end
endgenerate

always @(posedge clk) begin
	if (reset || done) begin
			done_paddignB<=0;
			current_row <= 0;
			done_read_matrixB <= 0; 
			internal_write_enable <= 1;
	end else if ((current_row < max_dim ) && start_bit) begin
		current_row <= current_row +1 ; 
	end
	else  if (current_row == max_dim) begin
		current_row <= 0 ; 
		done_read_matrixB <= 1;
	end 
	else begin
		current_row <= 0 ;
	end
end
      
    

//-------- for padding matrixB 

integer row, col;

always @(posedge clk) begin
    if (done_read_matrixB) begin // Assuming a start signal triggers the padding operation
        for (row = 0; row < 2*max_dim - 1; row = row + 1) begin
            for (col = 0; col < max_dim ; col = col + 1) begin
                if (row >= col && row < col + max_dim) begin
                    matrixB_padded[row*max_dim + col] <= matrixB[(row-col)*max_dim + col];
                end else begin
                    matrixB_padded[row*max_dim + col] <= 0;
                end
            end
        end
		done_paddignB <= 1; // Indicate padding operation is complete
		done_read_matrixB <= 0 ; // dont want to get inside this loop again
    end
end

//-------- move foword vector B 

genvar  j; 

generate for ( j = 0 ; j < max_dim ; j = j + 1 ) begin
	always @(posedge clk) begin
		if (done_paddignB && done_paddignA && !(finsh_foword_b)) begin
			vectorB[data_width*(j+1) - 1 : data_width*j] <= matrixB_padded[iteration_count_fowaord*max_dim + j];
		end
		else begin
			vectorB[data_width*(j+1) - 1 : data_width*j] <=0;
		end
	end
end
endgenerate


always @(posedge clk) begin
	if (reset || done) begin
		
		iteration_count_fowaord<=0;
		finsh_foword_b<=0;
	end
	else if ((iteration_count_fowaord< (2*max_dim) - 2 ) && !finsh_foword_b && done_paddignB && done_paddignA) begin
		iteration_count_fowaord <= (iteration_count_fowaord + 1);
	end
	else if (iteration_count_fowaord == ((2*max_dim) - 2) && !finsh_foword_b ) begin
		finsh_foword_b<= 1;
		iteration_count_fowaord<=0;
	end
	else begin 
		
		iteration_count_fowaord<=0;
	end
end
assign done_paddign_B = done_paddignB;


endmodule
