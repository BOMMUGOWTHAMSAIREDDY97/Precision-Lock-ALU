
`timescale 1ns/1ps

module precision_lock_alu_tb;

    reg signed [15:0] operand_a;
    reg signed [15:0] operand_b;
    reg [1:0] operation;

    wire signed [15:0] result;
    wire precision_mode;

    integer pass_count;
    integer fail_count;

    precision_lock_alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result(result),
        .precision_mode(precision_mode)
    );

    task check;
        input signed [15:0] a;
        input signed [15:0] b;
        input [1:0] op;
        input signed [15:0] expected_result;
        input expected_mode;

        begin
            operand_a = a;
            operand_b = b;
            operation = op;
            #10;

            if ((result === expected_result) &&
                (precision_mode === expected_mode)) begin

                $display("PASS: A=%0d B=%0d OP=%b RESULT=%0d MODE=%b",
                         a, b, op, result, precision_mode);

                pass_count = pass_count + 1;
            end
            else begin

                $display("FAIL: A=%0d B=%0d OP=%b EXPECTED=%0d GOT=%0d MODE=%b",
                         a, b, op, expected_result,
                         result, precision_mode);

                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin

        pass_count = 0;
        fail_count = 0;

        $dumpfile("simulation/waveforms/precision_lock_alu.vcd");
        $dumpvars(0, precision_lock_alu_tb);

        $display("PRECISION-LOCK ALU TEST STARTED");

        // Addition tests
        check(25, 50, 2'b00, 75, 1'b1);
        check(100, 20, 2'b00, 120, 1'b1);
        check(100, 50, 2'b00, 150, 1'b0);
        check(200, 100, 2'b00, 300, 1'b0);
        check(-50, 20, 2'b00, -30, 1'b1);

        // Subtraction tests
        check(100, 50, 2'b01, 50, 1'b1);
        check(50, 100, 2'b01, -50, 1'b1);
        check(-100, 50, 2'b01, -150, 1'b0);
        check(200, 100, 2'b01, 100, 1'b0);
        check(-50, -20, 2'b01, -30, 1'b1);

        // Boundary tests
        check(127, 1, 2'b00, 128, 1'b0);
        check(-128, -1, 2'b00, -129, 1'b0);
        check(-128, 1, 2'b01, -129, 1'b0);
        check(127, -1, 2'b01, 128, 1'b0);
        check(0, 0, 2'b00, 0, 1'b1);

        $display("--------------------------------");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("--------------------------------");

        $finish;
    end

endmodule
