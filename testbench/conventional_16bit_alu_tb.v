`timescale 1ns/1ps

module conventional_16bit_alu_tb;

    reg signed [15:0] operand_a;
    reg signed [15:0] operand_b;
    reg [1:0] operation;

    wire signed [15:0] result;

    integer pass_count = 0;
    integer fail_count = 0;

    conventional_16bit_alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result(result)
    );

    task run_test;
        input signed [15:0] a;
        input signed [15:0] b;
        input [1:0] op;
        input signed [15:0] expected;
        input [200*8:1] test_name;

        begin
            operand_a = a;
            operand_b = b;
            operation = op;

            #10;

            if (result === expected) begin
                $display("PASS: %0s | A=%0d B=%0d Result=%0d",
                         test_name, a, b, result);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%0d Actual=%0d",
                         test_name, expected, result);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin

        $display("====================================");
        $display("CONVENTIONAL 16-BIT ALU TEST");
        $display("====================================");

        // Addition tests
        run_test(127, 1, 2'b00, 128, "Positive boundary addition");
        run_test(100, 50, 2'b00, 150, "Normal addition");
        run_test(32767, 1, 2'b00, -32768, "Positive overflow");
        run_test(-32768, -1, 2'b00, 32767, "Negative overflow");
        run_test(-100, 50, 2'b00, -50, "Signed addition");

        // Subtraction tests
        run_test(127, -1, 2'b01, 128, "Subtraction boundary");
        run_test(-32768, 1, 2'b01, 32767, "Subtraction overflow");
        run_test(100, 150, 2'b01, -50, "Normal subtraction");
        run_test(-100, 50, 2'b01, -150, "Signed subtraction");

        // Invalid operation
        run_test(100, 50, 2'b10, 0, "Invalid operation 10");

        $display("------------------------------------");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("------------------------------------");

        if (fail_count == 0)
            $display("CONVENTIONAL ALU TEST PASSED");
        else
            $display("CONVENTIONAL ALU TEST FAILED");

        $finish;
    end

endmodule
