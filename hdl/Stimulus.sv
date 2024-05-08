
`include "headers.vh"

// Stimulus Module
module Stimulus #(
    parameter string INSTRUCTIONS_FILE = "",
    parameter bit     VERBOSE    = 1'b0
) ( 
    interface_matmul.STIMULUS    intf, /// interface_matmul.stimulus (after the dote the name of the port map


    output logic        stim_done_o
);
	import matmul_pkg::NUMBER_OF_CHECK;
    import matmul_pkg::data_bus_t;
    import matmul_pkg::adrr_bus_t;
    import matmul_pkg::elements_data_bus_t;
    // File descriptors
    integer instructions_fd ;
    // Dimensions
    integer n, k, m,i;
    // Operation counter
    string check = INSTRUCTIONS_FILE;
	logic [1:0] 	finsh_check;
    wire        clk    = intf.clk;
    wire        rst    = intf.rst;
	wire 		done_i = intf.done;
    // Interface signals declared internally
    logic       psel_o, penable_o, pwrite_o;
    data_bus_t        pwdata_o;
    adrr_bus_t        paddr_o;
    elements_data_bus_t        pstrb_o;
    // Interface signals connect to internal decl'
    assign intf.psel         = psel_o;
    assign intf.penable = penable_o;
    assign intf.pwrite  = pwrite_o;
    assign intf.pwdata     = pwdata_o;
	assign intf.paddr     = paddr_o;
	assign intf.pstrb     = pstrb_o;
    // TB Signals
    //assign out_width_o     = pix_width;
    //assign out_height_o  = pix_height;

    task do_reset; begin
        psel_o        = 1'b0;
		penable_o        = 1'b0;
		pwrite_o        = 1'b0;
		i = 0;
        pwdata_o        = 0;
        paddr_o        = 0;
        pstrb_o        = 0;

        //img_done_o    = 1'b0;
		intf.finsh_check_o = 0;
        stim_done_o = 1'b0;
        // Open Stimulus files
           open_files(1'b0); // Open all 2
        wait( rst ); // Wait for reset to be asserted
        wait(!rst ); // Wait for reset to be deasserted
        // Reset done.
    end endtask

    task open_files(input logic reopen); begin
        if( !reopen ) begin
            // First time
            instructions_fd = $fopen(INSTRUCTIONS_FILE, "r");
            if(instructions_fd == 0) $fatal(1, $sformatf("Failed to open %s", INSTRUCTIONS_FILE));
        end // else img_done_o = 1'b1;



    end endtask

 



initial begin: INIT_STIM
	if(INSTRUCTIONS_FILE == "") $fatal(1, "INSTRUCTIONS_FILE is not set");
	
	do_reset();
	
	while(1) begin
		@(posedge clk)
		pwrite_o = 1;
		psel_o = 1;
		penable_o = 0;
		finsh_check = $fscanf(instructions_fd, "%d,%d,%d\n", pwdata_o, paddr_o,pstrb_o);
		if(i == NUMBER_OF_CHECK)begin
                $fatal(1, "Failed to read the metadata line of IMAGE_FILE");
				@(posedge clk) stim_done_o = 1'b1;
				intf.finsh_check_o = 1;
				break;
        end
		psel_o = 1;
		if ( paddr_o == 0 && pwdata_o[0]) begin
			@(posedge clk)
			penable_o = 1;
			@(posedge clk)
			penable_o = 0;
			pwrite_o = 0;
			wait(done_i == 1);
			i = i + 1;
		end
		
		@(posedge clk)
		penable_o = 1;
	
		
	end
end

endmodule

