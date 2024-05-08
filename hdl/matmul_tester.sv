//
// Test Bench Module lab2_lib.eqn_impl_tester.eqn_impl_tester
//
// Created:
//          by - mikepi.grad (eesgi4)
//          at - 18:40:18 01/23/24

`include "headers.vh"

module matmul_tester #(
    parameter string RESOURCE_BASE = ""
) (
    interface_matmul intf
);
import matmul_pkg::*;
// Local declarations
//wire [31:0] out_width, out_height;
//logic img_done, stim_done, golden_done;
logic stim_done;
wire rst_i = intf.rst;

Stimulus #(
    .INSTRUCTIONS_FILE($sformatf("%s/instrections.txt",RESOURCE_BASE))
) u_stim (
    .intf(intf),
    // TB Status
    //.out_width_o(out_width),
   // .out_height_o(out_height),
    //.img_done_o(img_done),
    .stim_done_o(stim_done)
);





//Golden-Model module
matrix_reader #(

) u_golden (
//    // TB Status
.intf(intf)

);


initial begin: TB_INIT
    wait(rst_i); wait(!rst_i);
    wait(stim_done);
    $display("[%0t] Stim Done.", $time);
    //wait(golden_done);
    //$display("[%0t] Check Done.", $time);
    $finish;
end

endmodule // eqn_impl_tester


