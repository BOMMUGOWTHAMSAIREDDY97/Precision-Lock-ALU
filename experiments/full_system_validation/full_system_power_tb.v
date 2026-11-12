`timescale 1ns/1ps

module power_tb;

    reg clk;
    reg reset;
    reg operation_valid;

    reg signed [15:0] operand_a;
    reg signed [15:0] operand_b;
    reg [1:0] operation;

    wire signed [15:0] result;
    wire precision_8_candidate;
    wire precision_mode;

    wire [15:0] total_count;
    wire [15:0] count_8bit;
    wire [15:0] count_16bit;
    wire [15:0] transition_count;

    integer operations_tested = 0;
    integer arithmetic_errors = 0;

    integer expected_total = 0;
    integer expected_8bit = 0;
    integer expected_16bit = 0;
    integer expected_transitions = 0;

    integer i;

    reg previous_mode;
    reg previous_mode_valid;

    reg signed [16:0] calculation;
    reg signed [15:0] expected_result;
    reg expected_mode;

    precision_lock_system_opt dut (
        .clk(clk),
        .reset(reset),
        .operation_valid(operation_valid),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result(result),
        .precision_8_candidate(precision_8_candidate),
        .precision_mode(precision_mode),
        .total_count(total_count),
        .count_8bit(count_8bit),
        .count_16bit(count_16bit),
        .transition_count(transition_count)
    );

    always #10 clk = ~clk;

    task run_operation;
        input signed [15:0] a;
        input signed [15:0] b;
        input [1:0] op;

        begin
            if (op == 2'b00)
                calculation = $signed(a) + $signed(b);
            else
                calculation = $signed(a) - $signed(b);

            expected_result = calculation[15:0];

            expected_mode =
                (a >= -128 && a <= 127) &&
                (b >= -128 && b <= 127) &&
                ($signed(expected_result) >= -128 &&
                 $signed(expected_result) <= 127);

            @(negedge clk);

            operand_a = a;
            operand_b = b;
            operation = op;
            operation_valid = 1'b1;

            if (expected_mode)
                expected_8bit = expected_8bit + 1;
            else
                expected_16bit = expected_16bit + 1;

            expected_total = expected_total + 1;

            if (previous_mode_valid &&
                (expected_mode != previous_mode))
                expected_transitions = expected_transitions + 1;

            previous_mode = expected_mode;
            previous_mode_valid = 1'b1;

            @(posedge clk);
            #1;

            operations_tested = operations_tested + 1;

            if ((result !== expected_result) ||
                (precision_mode !== expected_mode)) begin

                arithmetic_errors = arithmetic_errors + 1;

                if (arithmetic_errors <= 10)
                    $display(
                        "MISMATCH %0d: A=%0d B=%0d OP=%b EXPECTED=%0d ACTUAL=%0d EXPECTED_MODE=%b ACTUAL_MODE=%b",
                        operations_tested, a, b, op,
                        expected_result, result,
                        expected_mode, precision_mode
                    );
            end

            operation_valid = 1'b0;
        end
    endtask

    initial begin

        $dumpfile("experiments/full_system_validation/full_system_power.vcd");
        $dumpvars(0, power_tb);

        clk = 0;
        reset = 0;
        operation_valid = 0;
        operand_a = 0;
        operand_b = 0;
        operation = 0;

        previous_mode = 0;
        previous_mode_valid = 0;

        #1 reset = 1;
        repeat (2) @(posedge clk);
        #1 reset = 0;

        $display("===== DIRECTED BOUNDARY TESTS =====");

        // One 8-bit operation followed by ten 16-bit operations.
        run_operation(25, 50, 2'b00);
        run_operation(100, 50, 2'b00);
        run_operation(200, 100, 2'b00);
        run_operation(-100, 50, 2'b01);
        run_operation(127, 1, 2'b00);
        run_operation(-128, -1, 2'b00);
        run_operation(-128, 1, 2'b01);
        run_operation(127, -1, 2'b01);
        run_operation(300, 100, 2'b00);
        run_operation(-300, 100, 2'b01);
        run_operation(256, -128, 2'b00);

        $display("===== SIGNED 8-BIT OPERAND TESTS =====");

        for (i = 0; i < 2048; i = i + 1) begin
            run_operation(
                (i * 37) % 256 - 128,
                (i * 53) % 256 - 128,
                i[0] ? 2'b00 : 2'b01
            );
        end

        $display("===== FULL-WIDTH OPERAND TESTS =====");

        for (i = 0; i < 2048; i = i + 1) begin
            run_operation(
                16'h0100 | ((i * 73) & 16'h7eff),
                16'h8000 | ((i * 29) & 16'h7fff),
                i[0] ? 2'b00 : 2'b01
            );
        end

        #2;

        $display("");
        $display("========================================");
        $display("FULL-SYSTEM GATE-LEVEL SUMMARY");
        $display("========================================");

        $display("Operations tested       : %0d", operations_tested);
        $display("Arithmetic mismatches   : %0d", arithmetic_errors);

        $display("");
        $display("EXPECTED PROFILER COUNTERS");
        $display("Total                   : %0d", expected_total);
        $display("8-bit                   : %0d", expected_8bit);
        $display("16-bit                  : %0d", expected_16bit);
        $display("Transitions             : %0d", expected_transitions);

        $display("");
        $display("ACTUAL PROFILER COUNTERS");
        $display("Total                   : %0d", total_count);
        $display("8-bit                   : %0d", count_8bit);
        $display("16-bit                  : %0d", count_16bit);
        $display("Transitions             : %0d", transition_count);

        if (operations_tested == 4107 &&
            arithmetic_errors == 0 &&
            total_count === 16'd4107 &&
            count_8bit === 16'd1537 &&
            count_16bit === 16'd2570 &&
            transition_count === 16'd657 &&
            expected_total == 4107 &&
            expected_8bit == 1537 &&
            expected_16bit == 2570 &&
            expected_transitions == 657) begin

            $display("");
            $display("RESULT: PASS");

        end
        else begin
            $display("");
            $display("RESULT: FAIL");
        end

        $display("========================================");

        $finish;
    end

endmodule
