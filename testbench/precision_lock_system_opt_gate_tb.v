`timescale 1ns/1ps

module precision_lock_system_opt_gate_tb;

    reg clk;
    reg reset;
    reg operation_valid;

    reg signed [15:0] operand_a;
    reg signed [15:0] operand_b;
    reg [1:0] operation;

    wire [15:0] result;
    wire precision_8_candidate;
    wire precision_mode;

    wire [15:0] total_count;
    wire [15:0] count_8bit;
    wire [15:0] count_16bit;
    wire [15:0] transition_count;

    integer pass_count;
    integer fail_count;

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

    // 20 ns clock period, matching the physical design SDC.
    always #10 clk = ~clk;

    task run_operation;
        input signed [15:0] a;
        input signed [15:0] b;
        input [1:0] op;
        begin
            @(negedge clk);

            operand_a = a;
            operand_b = b;
            operation = op;
            operation_valid = 1'b1;

            @(posedge clk);
            #1;

            $display(
                "A=%0d B=%0d Result=%0d Precision=%0d",
                a, b, $signed(result), precision_mode
            );

            operation_valid = 1'b0;
        end
    endtask

    task check_value;
        input [15:0] actual;
        input [15:0] expected;
        input [200*8:1] message;
        begin
            if (actual === expected) begin
                $display("PASS: %0s", message);
                pass_count = pass_count + 1;
            end
            else begin
                $display(
                    "FAIL: %0s Expected=%0d Actual=%0d",
                    message, expected, actual
                );
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("simulation/waveforms/system_opt_gate.vcd");
        $dumpvars(0, precision_lock_system_opt_gate_tb);

        clk = 0;
        reset = 1;
        operation_valid = 0;
        operand_a = 0;
        operand_b = 0;
        operation = 0;

        pass_count = 0;
        fail_count = 0;

        repeat (2) @(posedge clk);
        #1 reset = 0;

        run_operation(25, 50, 2'b00);
        run_operation(100, 50, 2'b00);
        run_operation(20, 10, 2'b00);
        run_operation(300, 100, 2'b00);
        run_operation(80, 20, 2'b01);

        #2;

        check_value(total_count, 5, "Total operations");
        check_value(count_8bit, 3, "8-bit operations");
        check_value(count_16bit, 2, "16-bit operations");
        check_value(transition_count, 4, "Precision transitions");

        $display("--------------------------------");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("--------------------------------");

        if (fail_count == 0)
            $display("GATE-LEVEL SYSTEM TEST PASSED");
        else
            $display("GATE-LEVEL SYSTEM TEST FAILED");

        $finish;
    end

endmodule
