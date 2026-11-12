`timescale 1ns/1ps

module precision_lock_alu_compare_top (
    input  wire               clk,
    input  wire signed [15:0] operand_a,
    input  wire signed [15:0] operand_b,
    input  wire        [1:0]  operation,
    output reg  signed [15:0] result
);

    reg signed [15:0] operand_a_reg;
    reg signed [15:0] operand_b_reg;
    reg        [1:0]  operation_reg;

    wire signed [15:0] alu_result;
    wire               unused_precision_mode;

    precision_lock_alu u_alu (
        .operand_a     (operand_a_reg),
        .operand_b     (operand_b_reg),
        .operation     (operation_reg),
        .result        (alu_result),
        .precision_mode(unused_precision_mode)
    );

    always @(posedge clk) begin
        operand_a_reg <= operand_a;
        operand_b_reg <= operand_b;
        operation_reg <= operation;
        result         <= alu_result;
    end

endmodule
