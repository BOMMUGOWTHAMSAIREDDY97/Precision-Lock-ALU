
module precision_lock_alu (
    input  signed [15:0] operand_a,
    input  signed [15:0] operand_b,
    input         [1:0]  operation,

    output reg signed [15:0] result,
    output reg               precision_mode
);

    reg signed [16:0] full_result;
    reg signed [8:0]  reduced_result;

    wire a_fits_8;
    wire b_fits_8;
    wire operands_fit_8;

    // Check signed 8-bit operand ranges.
    assign a_fits_8 = (operand_a[15:8] == {8{operand_a[7]}});
    assign b_fits_8 = (operand_b[15:8] == {8{operand_b[7]}});
    assign operands_fit_8 = a_fits_8 && b_fits_8;

    always @(*) begin

        result = 16'sd0;
        precision_mode = 1'b0;
        full_result = 17'sd0;
        reduced_result = 9'sd0;

        case (operation)

            // Operation 00: Addition
            2'b00: begin
                reduced_result = $signed(operand_a[7:0])
                               + $signed(operand_b[7:0]);

                full_result = operand_a + operand_b;

                if (operands_fit_8 &&
                    (reduced_result >= -128) &&
                    (reduced_result <= 127)) begin

                    result = {{8{reduced_result[7]}},
                              reduced_result[7:0]};
                    precision_mode = 1'b1;

                end else begin
                    result = full_result[15:0];
                    precision_mode = 1'b0;
                end
            end

            // Operation 01: Subtraction
            2'b01: begin
                reduced_result = $signed(operand_a[7:0])
                               - $signed(operand_b[7:0]);

                full_result = operand_a - operand_b;

                if (operands_fit_8 &&
                    (reduced_result >= -128) &&
                    (reduced_result <= 127)) begin

                    result = {{8{reduced_result[7]}},
                              reduced_result[7:0]};
                    precision_mode = 1'b1;

                end else begin
                    result = full_result[15:0];
                    precision_mode = 1'b0;
                end
            end

            // Invalid operation
            default: begin
                result = 16'sd0;
                precision_mode = 1'b0;
            end

        endcase
    end

endmodule
