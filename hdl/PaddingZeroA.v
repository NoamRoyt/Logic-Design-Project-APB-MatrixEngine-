
`resetall 
`timescale 1ns/10ps


module PaddingZeroA #(
    parameter data_width = 32,
    parameter bus_width = 64,
    parameter size_new_matrix = 2*max_dim
	//parameter N = 2 // row
	//parameter K = 3 // col
)

	(
clk,
start_bit,
reset,
done,
write_enable_A,
bus, // for red from the memory 
done_paddignB,
vectorA ,
done_paddign_A,

    
);
	localparam max_dim = bus_width/data_width ;
	input wire clk;
	input wire start_bit;
    	input wire reset;
	input wire done;
	input wire write_enable_A;
    	input wire [max_dim*data_width-1:0] bus; // for red from the memory 
	input wire done_paddignB;
	output reg [data_width*max_dim -1 : 0] vectorA ;
	output wire done_paddign_A;

	
	
// signal for matrixA
reg [data_width-1:0] matrixA [max_dim*max_dim-1:0];
reg done_read_matrixA; // tell when finsh to read from the memory 
reg [data_width -1 :0] current_row;
reg internal_write_enable;
// signal for padding matrixA
reg [data_width-1:0] matrixA_padded [max_dim*(2*max_dim-1):0];
reg done_paddignA;
// siganl for move foward the element from paddign matrixA to systolic array 
reg [2*max_dim : 0 ] iteration_count_fowaord;
reg finsh_foword_a;

//---------------- first read from the memore to oprand B -------------------


genvar k;
generate
    for (k = 0; k < max_dim; k = k + 1) begin : gen_blk // Label the block for clarity
        always @(posedge clk) begin
            if (write_enable_A && internal_write_enable) begin
                matrixA[(current_row-1) * max_dim + k] <= bus[data_width * (k + 1) - 1 : data_width * k];
	    end
        end
    end
endgenerate

integer m ;
always @(posedge clk) begin
	if (reset || done) begin
			done_paddignA<=0;
			current_row <= 0;
			done_read_matrixA <= 0; 
			internal_write_enable <= 1;
			for ( m = 0 ; m < max_dim*max_dim ; m = m + 1) begin
				matrixA[m] <= 0 ;
			end
			
	end else if ((current_row < max_dim ) && start_bit) begin
		current_row <= current_row +1 ; 
	end else if (current_row == max_dim) begin
		current_row <= 0 ; 
		done_read_matrixA <= 1;
	end else begin
		current_row <= 0 ;
	end 
end
      
    

//-------- for padding matrixA

integer row, col;

always @(posedge clk) begin
    if (done_read_matrixA) begin // Assuming a start signal triggers the padding operation
        for (row = 0; row < max_dim; row = row + 1) begin
            for (col = 0; col < (size_new_matrix - 1); col = col + 1) begin
                if (col >= row && col < row + max_dim) begin
                    matrixA_padded[row*(size_new_matrix-1) + col] <= matrixA[row*max_dim + col - row];
                end else begin
                    matrixA_padded[row*(size_new_matrix-1) + col] <= 0;
                end
            end
        end
		done_paddignA <= 1; // Indicate padding operation is complete
		done_read_matrixA <= 0 ; // dont want to get inside this loop again
    end
end
//-------- move foword vector A  


genvar  j; 

generate for ( j = 0 ; j < max_dim ; j = j + 1 ) begin
	always @(posedge clk) begin
		if (done_paddignB && done_paddignA && !(finsh_foword_a)) begin
			vectorA[data_width*(j+1) - 1 : data_width*j] <= matrixA_padded[(2*max_dim - 1)*j + iteration_count_fowaord];
		end
		else begin
			vectorA[data_width*(j+1) - 1 : data_width*j] <=0;
		end
	end
end
endgenerate

always @(posedge clk) begin
	if (reset || done) begin
		
		iteration_count_fowaord<=0;
		finsh_foword_a<=0;
	end
	else if ((iteration_count_fowaord< (size_new_matrix) - 2 ) && !finsh_foword_a && done_paddignB && done_paddignA) begin
		iteration_count_fowaord <= (iteration_count_fowaord + 1);
	end
	else if (iteration_count_fowaord == ((size_new_matrix) - 2) && !finsh_foword_a ) begin
		finsh_foword_a<= 1;
		iteration_count_fowaord<=0;
	end
	else begin 
		
		iteration_count_fowaord<=0;
	end
end
		
		


assign done_paddign_A = done_paddignA;


endmodule
