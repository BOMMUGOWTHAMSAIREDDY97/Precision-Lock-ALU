`timescale 1ns/1ps

module conventional_16bit_alu (
    input  signed [15:0] operand_a,
    input  signed [15:0] operand_b,
    input         [1:0]  operation,

    output reg signed [15:0] result
);

    reg signed [16:0] full_result;

    always @(*) begin

        result = 16'sd0;
        full_result = 17'sd0;

        case (operation)

            // Operation 00: 16-bit addition
            2'b00: begin
                full_result = operand_a + operand_b;
                result = full_result[15:0];
            end

            // Operation 01: 16-bit subtraction
            2'b01: begin
                full_result = operand_a - operand_b;
                result = full_result[15:0];
            end

            // Invalid operation
            default: begin
                result = 16'sd0;
            end

        endcase
    end

endmodule

