// ScratchPad 
// in the ScratchPad can be save at most 4 matrix its depand of the size of SPN 
// her the size of the every 
//---- read form sp ------
//we have two option:
// if MODE BIT = 1 , we read from sp to systolice 
// if MODE BIT = 0 ,we write from the systolice to sp 

module ScratchPad #(
	parameter data_width  = 16, // Number of bits in a data unit
	parameter addr_width = 32, // Number of bits in an address, means the're 16 registers in the RF
	parameter bus_width = 32,
	parameter sp_ntargets = 4
	)
(clk,reset,pread_en,finsh_calc,pwdata_from_systolic,write_target_sp,read_target_sp,mode_bit,start_bit,address_for_mudule,address_for_row_RF_and_SP,address_for_element_in_SP,prdata_for_cpu,pwdata_to_systolic,done);
	
	localparam max_dim = bus_width/data_width ;	
	
	input wire clk;
	input wire reset;
	input wire pread_en;
	//input from the systolice
	input wire finsh_calc;
	input wire [max_dim*max_dim*bus_width-1:0] pwdata_from_systolic;
	// input from the control register 
	input wire [1:0] write_target_sp;
	input wire [1:0] read_target_sp;
	input wire mode_bit;
	input wire start_bit;
	//input from paddr this is for read back to the cpu 
	input wire [4:0] address_for_mudule;
	input wire [$clog2(max_dim)-1:0] address_for_row_RF_and_SP;
	input wire [$clog2(max_dim)-1:0] address_for_element_in_SP;
	// outputs
	output reg [bus_width-1:0] prdata_for_cpu;
	output reg [max_dim*max_dim*bus_width -1 : 0] pwdata_to_systolic;
	output reg done;

	
	
	
	
	
	reg finsh_fword;
	reg [max_dim*bus_width-1:0] SP[sp_ntargets*4 -1 :0];
	

// for write to sp from systolice 
genvar k ; 
generate for (k = 0 ; k < max_dim ; k = k +1) begin
	always @(posedge clk) begin 
		if (finsh_calc && start_bit) begin
			
			SP[4*write_target_sp + k ] <=pwdata_from_systolic[max_dim*bus_width*(k+1)-1:k*max_dim*bus_width];
			done <= 1;		
		end
		else begin
			done<=0;
		end
	end
end
endgenerate 

genvar j ; 
generate for (j = 0 ; j < max_dim ; j = j +1) begin
	always @(posedge clk) begin 
		if (mode_bit && start_bit && !finsh_fword) begin
			pwdata_to_systolic[max_dim*bus_width*(j+1)-1:j*max_dim*bus_width] <= SP[4*read_target_sp + j ];
			finsh_fword<=1;
		end
		else begin
			pwdata_to_systolic<=0;
		end
	end
end
endgenerate 
	
integer i,idx; 
always @(posedge clk) begin 
	if (reset) begin
		finsh_fword<= 0;
		pwdata_to_systolic <=0;
		prdata_for_cpu<=0;
		done<=0;
		for ( i=0; i < sp_ntargets*4; i =i +1) begin
			SP[i] <= 0;
		end
	end
	if (done) begin
		finsh_fword<= 0;
		pwdata_to_systolic <=0;
		prdata_for_cpu<=0;
	end
	else if (pread_en) begin
		// Read operation: Refactored to use a loop for dynamic access
        for (idx = 0; idx < max_dim; idx = idx + 1) begin
            if (idx == address_for_element_in_SP) begin
                prdata_for_cpu <= SP[address_for_mudule - 16 + address_for_row_RF_and_SP][idx*bus_width +: bus_width];
                // Using '+:' for ascending range selection which requires a constant width
			end
		end
	end
	else begin
		prdata_for_cpu<=0;
	end
end
	
				
					
		
	
			
endmodule		
			