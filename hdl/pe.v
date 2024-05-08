`resetall
`timescale 1ns / 10ps

module pe #(
    parameter data_width = 8,                            // Width of the data inputs/outputs
    parameter bus_width = 64                             // Width of the bus for the result
)
(
    input wire clk,                                      // Clock signal
    input wire reset,               				     // Reset signal
    input wire mode_bit,           						 // Mode bit to control operation behavior
    input wire done,                					 // Signal to indicate completion of a process
    input wire signed [data_width-1:0] a, 				 // First input operand
    input wire signed [data_width-1:0] b,  				 // Second input operand
    input wire signed [bus_width-1 : 0] c, 				 // Initial value for result accumulation or adjustment
    output reg signed [data_width-1:0] continue_a, 		 // Output to continue operation with operand a
    output reg signed [data_width-1:0] continue_b, 		 // Output to continue operation with operand b
    output reg signed [bus_width-1:0] result, 			 // Result of the operation
    output wire overflow           						 // Overflow indicator
);

// Internal Declarations
wire signed [2*data_width-1:0] result_mult; // Intermediate result of the multiplication of 'a' and 'b'
reg signed [bus_width:0] temp_result_with_overflow; // Temporary result to include potential overflow bit
reg first_iteration; // Flag to manage the initial state or iteration

// Perform signed multiplication of 'a' and 'b'
assign result_mult = a * b;

// Overflow detection and result update logic
always @(posedge clk) begin
    if (reset || done) begin
        // Reset or initialization block
        result <= 0;
        continue_a <= 0;
        continue_b <= 0;
        temp_result_with_overflow <= 0;
        first_iteration <= 1; // Set first_iteration flag for initial condition handling
    end else begin
        if (mode_bit && first_iteration && c != 0) begin
            // On the first iteration and when mode_bit is set, initialize temp_result_with_overflow with 'c'
            temp_result_with_overflow <= c;
            first_iteration <= 0; // Clear the first_iteration flag after the initial setup
        end else begin
            // Regular operation: accumulate multiplication result
            temp_result_with_overflow <= temp_result_with_overflow + result_mult;
            result <= temp_result_with_overflow[bus_width-1:0]; // Update result, discarding overflow bit
            // Continue signals for chaining or iterative operations
            continue_a <= a;
            continue_b <= b;
        end
    end
end

// Overflow Detection
// Checks if the sign bit of the accumulated result differs from the next higher bit (potential overflow)
assign overflow = temp_result_with_overflow[bus_width] ^ temp_result_with_overflow[bus_width-1];

endmodule