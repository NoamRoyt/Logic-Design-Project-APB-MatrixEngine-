`resetall 
`timescale 1ns/10ps
`define IDLE     1'b0
`define WAIT  1'b1




module matamul #(
	parameter data_width  = 16, // Number of bits in a data unit
	parameter bus_width=64,// Number of registers in the register file TODO delete if unnecessary
	parameter addr_width = 32, // Number of bits in an address, means the're 16 registers in the RF
	parameter sp_ntargets=4
	)
	(clk_i,reset_ni,psel_i,penable_i,pwrite_i,pstrb_i,pwdata_i,paddr_i,pready_o,pslverr_o,prdata_o,busy_o,done_o,pwdata_from_systolic_to_sp_o,finsh_calculte_o);
	
	
	localparam max_dim = bus_width/data_width;
	input  wire                	clk_i;	//Cloack signal for the design 
	input  wire                	reset_ni; // reset signal
	input  wire                	psel_i; // APB select
	input  wire                	penable_i; // APB enable
	input  wire                	pwrite_i; // APB wirte enable 
	input  wire[max_dim-1:0]    pstrb_i; // APB write strobe ('byte' select) 
	input  wire[bus_width-1:0] 	pwdata_i; // APB write data
	input  wire[addr_width-1:0] paddr_i; // APB address
	output reg                	pready_o; // APB slave rady  
	output reg                	pslverr_o; // APB wirte enable 
	output  reg[bus_width-1:0] 	prdata_o; // APB read data 
	output reg                	busy_o; // Busy signal. indicating the design cannot be weitten to  
	output wire 				done_o;
	output wire [max_dim*max_dim*bus_width-1:0]				pwdata_from_systolic_to_sp_o;
	output wire finsh_calculte_o;
	// signal for the Control_register
	reg [15:0] pwdata_control;
	//wire [bus_width-1:0] prdata_from_control_register; /// TO DO
	wire start_bit;
	wire mode_bit_c;
	wire [1:0] write_target;
	wire [1:0] read_target;
	wire [1:0] data_flow;
	wire [1:0] Dim_N; //row dimension of matrix A and matrix C  
	wire [1:0] Dim_k; // column  of matrix A and row of matrix B 
	wire [1:0] Dim_M; // column  of matrix B and column  of matrix C 
	wire reload_operand_A;
	wire reload_operand_B;
	wire [15:0] ctrl_reg_o;
	wire [15:0] ctrl_reg;
	
	//signal for register file
	reg [bus_width-1:0] pwdata_RF;
	wire [bus_width-1:0] prdata_from_RF;
	//signal for address decoder 
	wire [4:0] address_for_mudule;
	wire [$clog2(max_dim)-1:0] address_for_row_RF_and_SP;
	wire [$clog2(max_dim)-1:0] address_for_element_in_SP;
	wire addr_valid_o;
	wire busy;
	// signal for padding matrix 
	wire [bus_width-1:0]readData_for_matrix_A;
	wire [bus_width-1:0]readData_for_matrix_B;
	

	wire write_enable_A;
	wire done_paddignB;
	wire [bus_width -1 : 0] vectorA ;
	wire done_paddign_A;
	

	wire write_enable_B;
	wire done_paddignA;
	wire [bus_width -1 : 0] vectorB ;
	wire done_paddign_B;
	// signal for systolic array 
	wire [max_dim*max_dim*bus_width-1:0] result ;
	wire finsh_calc;
	wire [max_dim*max_dim-1:0] overflow_from_sysyolic;
	//signal for scratchpad
	wire [max_dim*max_dim*bus_width-1:0] pwdata_from_systolic_to_sp; // need to check why only duplicate by 2 
	wire [bus_width-1:0]prdata_from_SP;
	wire [max_dim*max_dim*bus_width -1 : 0] pwdata_to_systolic;
	wire done;
// Port map AddressDecoder 
assign done_o = done;
AddressDecoder #(
    .data_width(data_width),
	.sp_ntargets(sp_ntargets),
	.bus_width(bus_width)
	) AddressDecoder (
    .paddr_i(paddr_i),
	.addr_valid_o(addr_valid_o),
    .address_for_mudule(address_for_mudule),
    .address_for_row_RF_and_SP(address_for_row_RF_and_SP),
	.address_for_element_in_SP(address_for_element_in_SP)

);

	
// Port map controle registe

Control_register #(
    .data_width(data_width),
	.bus_width(bus_width)
	) Control_register1 (
    .clk(clk_i),
    .reset_ni(reset_ni),
    .ctrl_write_i(pwdata_control),
    .start_bit(start_bit),
	.mode_bit(mode_bit_c),
	.ctrl_reg_o(ctrl_reg),
	.write_target(write_target),
	.read_target(read_target),
	.data_flow(data_flow),
	.done_i(done),
	.Dim_N(Dim_N),
	.Dim_kk(Dim_k),
	.Dim_M(Dim_M),
	.reload_operand_A(reload_operand_A),
	.reload_operand_B(reload_operand_B)
);
assign busy = ctrl_reg[0];
// Port map Register File 
RegisterFile #(
    .data_width(data_width),
	.addr_width(addr_width),
	.bus_width(bus_width)
) RegisterFile (
    .clk(clk_i),
	.dim_n(Dim_N),
	.dim_k(Dim_k),
	.dim_m(Dim_M),
    .reset(reset_ni),
	.start_bit(start_bit),
    .writeEn_reg(pwrite_i),
	.done(done),
    .row(address_for_row_RF_and_SP),
	.Addr(address_for_mudule),
	.pstrb(pstrb_i),
	.write_data(pwdata_RF),
	.readData(prdata_from_RF),
	.readData_for_matrix_a(readData_for_matrix_A),
	.readData_for_matrix_b(readData_for_matrix_B),
	.write_enable_B(write_enable_B),
	.write_enable_A(write_enable_A)

);

// port mab for paddings matrix
PaddingZeroA #(
    .data_width(data_width),
	.bus_width(bus_width)
) PaddingZeroA (
    .clk(clk_i),
	.start_bit(start_bit),
    .reset(reset_ni),
	.done(done),
	.write_enable_A(write_enable_A),
    .bus(readData_for_matrix_A),
	.done_paddignB(done_paddignB),
	.vectorA(vectorA),
	.done_paddign_A(done_paddign_A)


);

PaddingZeroB #(
    .data_width(data_width),
	.bus_width(bus_width)
) PaddingZeroB (
    .clk(clk_i),
	.start_bit(start_bit),
    .reset(reset_ni),
	.done(done),
	.write_enable_B(write_enable_B),
    .bus(readData_for_matrix_B),
	.done_paddignA(done_paddign_A),
	.vectorB(vectorB),
	.done_paddign_B(done_paddignB)


);

// port map for systolic array 
systolic_array #(
    .data_width(data_width),
	.bus_width(bus_width)

) systolic_array (
    .clk(clk_i),
    .reset(reset_ni),
	.done(done),
	.A(vectorA),
    .B(vectorB),
	.start_bit(start_bit),
	.result(result),
	.finsh_calculte_to_sp(finsh_calc),
	.mode_bit(mode_bit_c),
	.done_paddign(done_paddign_A),
	.pwdata_from_sp(pwdata_to_systolic),
	.overflow_o(overflow_from_sysyolic),
	.pwdata_to_sp(pwdata_from_systolic_to_sp[max_dim*max_dim*bus_width-1:0])


);
assign pwdata_from_systolic_to_sp_o= pwdata_from_systolic_to_sp;
assign finsh_calculte_o=finsh_calc;
// port map for scratchpad
ScratchPad #(
    .data_width(data_width),
	.addr_width(addr_width),
	.bus_width(bus_width),
	.sp_ntargets(sp_ntargets)

) scratchpad (
    .clk(clk_i),
    .reset(reset_ni),
	.pread_en(!pwrite_i),
    .finsh_calc(finsh_calc),
	.pwdata_from_systolic(pwdata_from_systolic_to_sp[max_dim*max_dim*bus_width-1:0]),
	.write_target_sp(write_target),
	.read_target_sp(read_target),
	.mode_bit(mode_bit_c),
	.start_bit(start_bit),
	.address_for_mudule(address_for_mudule),
	.address_for_row_RF_and_SP(address_for_row_RF_and_SP),
	.address_for_element_in_SP(address_for_element_in_SP),
	.prdata_for_cpu(prdata_from_SP),
	.pwdata_to_systolic(pwdata_to_systolic),
	.done(done)


);
	
reg [1:0] state, next_state;

// State transition logic (sequential block)
always @(posedge clk_i or negedge reset_ni) begin
    if (reset_ni) begin
        state <= `IDLE;
		//pwdata_from_systolic_to_sp=0;
    end else begin
        state <= next_state;
    end
end

// Next state logic (combinational block)
always @* begin
    // Default assignments
    next_state = state; // Prevent inferred latches
    pready_o = 0;
    pslverr_o = 0;
    prdata_o = 0;
    busy_o = 0;
    pwdata_control = ctrl_reg; // Preserve current state unless explicitly written to
    pwdata_RF = pwdata_RF; // Preserve current state unless explicitly written to
    
    case (state)
        `IDLE: begin
            if (busy) begin
                busy_o = 1;
				pslverr_o = psel_i;
			
            end 
				else if ( psel_i ) begin
				
					next_state = `WAIT;
				
					if (pwrite_i && penable_i) begin
						//next_state = `WRITE_TO_OPERAND;
						if (address_for_mudule == 0) begin
							pwdata_control = pwdata_i[15:0];
						end 
						else begin
							pwdata_RF = pwdata_i;
						end
					end
					else if ((!pwrite_i) && penable_i) begin 
						if (paddr_i[4:2] == 0) begin
							prdata_o <= ctrl_reg;
						end
						else if ((paddr_i[4:2] == 1) || (paddr_i[4:2] == 2) || (paddr_i[4:2] == 3)) begin
							prdata_o <= prdata_from_RF;
						end 
						else if (paddr_i[4:2] >= 4 && paddr_i[4:2] <= 7) begin
							prdata_o = prdata_from_SP;
						end
						else if (paddr_i == 12) begin
							prdata_o = overflow_from_sysyolic;
						end
					end
					else begin
						next_state <=`IDLE;
					end
				end
			end 
		`WAIT: begin
			next_state = `IDLE;
			if(psel_i && penable_i) begin
				pready_o = 1'b1;
			end
			else begin 
				pready_o = 1'b0;
			end
		end
        default: begin
            next_state = `IDLE; // Default safe state
        end
    endcase
end

assign pwdata_from_systolic_to_sp_o = pwdata_from_systolic_to_sp;

endmodule