
`timescale 1ns/1ps

module precision_lock_system_tb;

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

    wire [6:0] percentage_8bit;
    wire [6:0] percentage_16bit;

    integer pass_count;
    integer fail_count;

    precision_lock_system dut (
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
        .transition_count(transition_count),

        .percentage_8bit(percentage_8bit),
        .percentage_16bit(percentage_16bit)
    );

    // 10 ns clock period.
    always #5 clk = ~clk;

    // Apply and verify one arithmetic operation.
    task run_operation;
        input signed [15:0] a;
        input signed [15:0] b;
        input [1:0] op;
        input signed [15:0] expected_result;
        input expected_mode;

        begin
            @(negedge clk);

            operand_a = a;
            operand_b = b;
            operation = op;
            operation_valid = 1'b1;

            #1;

            if ((result === expected_result) &&
                (precision_mode === expected_mode)) begin

                $display(
                    "PASS: A=%0d B=%0d OP=%b RESULT=%0d MODE=%b",
                    a, b, op, result, precision_mode
                );

                pass_count = pass_count + 1;
            end
            else begin

                $display(
                    "FAIL: A=%0d B=%0d OP=%b EXPECTED=%0d GOT=%0d MODE=%b",
                    a, b, op, expected_result, result, precision_mode
                );

                fail_count = fail_count + 1;
            end

            @(posedge clk);
            #1;
            operation_valid = 1'b0;
        end
    endtask

    initial begin

        clk = 0;
        reset = 1;
        operation_valid = 0;

        operand_a = 0;
        operand_b = 0;
        operation = 0;

        pass_count = 0;
        fail_count = 0;

        $dumpfile("simulation/waveforms/precision_lock_system.vcd");
        $dumpvars(0, precision_lock_system_tb);

        $display("INTEGRATED PRECISION-LOCK ALU TEST STARTED");

        // Release reset.
        #12;
        reset = 0;

        // Five arithmetic operations.
        run_operation(25, 50, 2'b00, 75, 1'b1);
        run_operation(100, 50, 2'b00, 150, 1'b0);
        run_operation(20, 10, 2'b00, 30, 1'b1);
        run_operation(300, 100, 2'b00, 400, 1'b0);
        run_operation(80, 20, 2'b01, 60, 1'b1);

        #2;

        $display("--------------------------------");
        $display("TOTAL OPERATIONS      = %0d", total_count);
        $display("8-BIT OPERATIONS      = %0d", count_8bit);
        $display("16-BIT OPERATIONS     = %0d", count_16bit);
        $display("PRECISION TRANSITIONS = %0d", transition_count);
        $display("8-BIT PERCENTAGE      = %0d%%", percentage_8bit);
        $display("16-BIT PERCENTAGE     = %0d%%", percentage_16bit);
        $display("--------------------------------");

        // Verify integrated telemetry.
        if ((total_count == 5) &&
            (count_8bit == 3) &&
            (count_16bit == 2) &&
            (transition_count == 4) &&
            (percentage_8bit == 60) &&
            (percentage_16bit == 40)) begin

            $display("PASS: Integrated profiler verification");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Integrated profiler verification");
            fail_count = fail_count + 1;
        end

        $display("--------------------------------");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("--------------------------------");

        $finish;
    end

endmodule
