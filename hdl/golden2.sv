`include "headers.vh"

module matrix_reader(
interface_matmul.GOLDEN intf
);



import matmul_pkg::*;
reg signed [BUS_WIDTH-1:0] matrix[MAX_DIM-1:0][MAX_DIM-1:0];
logic finsh_calculte;
logic done;
logic [1:0] finsh_check;
logic [MAX_DIM*MAX_DIM*BUS_WIDTH-1:0] pwdata_from_systolic_to_sp_i;
logic golden_done_o;
logic [BUS_WIDTH-1 : 0 ]temp_value;
wire        rst    = intf.rst;
wire        clk    = intf.clk;


 integer i, j, bit_index;
 integer file, test_num = 0;

assign finsh_calculte = intf.finsh_calculte;
assign finsh_check = intf.finsh_check_o;
assign pwdata_from_systolic_to_sp_i= intf.pwdata_from_systolic_to_sp_i;
assign done = intf.done;

assign intf.golden_done_o= golden_done_o;

    initial begin
        // Attempt to open the file, create if it doesn't exist
        file = $fopen("C:/Users/97252/Desktop/lab1/matrix.txt", "w");
        if (file == 0) begin
            $display("Failed to open matrix.txt for writing.");
            $finish;
        end
		golden_done_o = 0 ;
		wait(  rst );
		wait( !rst ); // Reset done
		wait(finsh_check==0);
		while(finsh_check==0) begin
			@(posedge clk)
			wait (finsh_calculte == 1 && done == 1);
			test_num = test_num + 1;
			$fwrite(file, "Mat Res in Test %0d is: \n\n", test_num);
            for (i = 0; i < MAX_DIM; i = i + 1) begin
                for (j = 0; j < MAX_DIM; j = j + 1) begin
                    bit_index = ((i * MAX_DIM) + j) * BUS_WIDTH;
					temp_value = $signed(pwdata_from_systolic_to_sp_i[bit_index +: BUS_WIDTH]);
                    matrix[i][j] = temp_value;
                    $fwrite(file, "%0d.0", matrix[i][j]); // Assuming integer values, adjust formatting as needed
                    if (j < MAX_DIM-1) $fwrite(file, ",");
                end
                $fwrite(file, "\n");
            end
            $fwrite(file, "----------------------------------------------------------------------------------------------------\n");
			wait (!finsh_calculte);
        end
		$fclose(file);
		golden_done_o = 1 ;
	end 
endmodule

