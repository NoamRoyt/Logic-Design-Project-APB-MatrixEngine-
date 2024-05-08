// the address decoder 
// the first and secoend bit fo chooce row in matrix 
// 00 row = 0 ,01 row = 1 ,10 row =2 , 11 row = 3
// the threed four and five bit for choce the module we want to access 
// 001 module = matrixA , 010 module = matrixB, 011 module = matrix_flag , 100 module = SP1 ,  101 module = SP2,110 module = SP3, 111 module = SP4 
// the seven and six bit are for if we in sp need to chooce the elment  


module AddressDecoder #(
	parameter data_width  = 16, // Number of bits in a data unit
	parameter addr_width = 16, // Number of bits in an address, means the're 16 registers in the RF
	parameter bus_width = 64,
	parameter sp_ntargets = 4
) 

	(
 paddr_i,
addr_valid_o,
	// This is actually 3 bits wide.
address_for_mudule,
address_for_row_RF_and_SP,
address_for_element_in_SP
);
	localparam max_dim = bus_width/data_width ;
	input wire [addr_width-1:0] paddr_i;
	output wire addr_valid_o;
	// This is actually 3 bits wide.
	output wire[4:0] address_for_mudule;
	output wire[$clog2(max_dim)-1:0] address_for_row_RF_and_SP;
	output wire[$clog2(max_dim)-1:0] address_for_element_in_SP;
	
	
	assign addr_valid_o = ~(|paddr_i[1:0]);
	assign address_for_mudule[4:2] = paddr_i[4:2];
	assign address_for_mudule[1:0] = 0;
	assign address_for_row_RF_and_SP = paddr_i[$clog2(max_dim)+4:5];
	assign address_for_element_in_SP = paddr_i[2*$clog2(max_dim)+4:5+$clog2(max_dim)];
	

endmodule
