
`timescale 1ns/1ps

module precision_transition_profiler_opt_tb;

    reg clk;
    reg reset;
    reg operation_valid;
    reg precision_mode;

    wire [15:0] total_count;
    wire [15:0] count_8bit;
    wire [15:0] count_16bit;
    wire [15:0] transition_count;

    integer pass_count;
    integer fail_count;

    precision_transition_profiler_opt dut (
        .clk(clk),
        .reset(reset),
        .operation_valid(operation_valid),
        .precision_mode(precision_mode),
        .total_count(total_count),
        .count_8bit(count_8bit),
        .count_16bit(count_16bit),
        .transition_count(transition_count)
    );

    always #5 clk = ~clk;

    task apply_operation;
        input mode;
        begin
            @(negedge clk);
            precision_mode = mode;
            operation_valid = 1'b1;

            @(posedge clk);
            #1;
            operation_valid = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        operation_valid = 0;
        precision_mode = 0;
        pass_count = 0;
        fail_count = 0;

        $dumpfile("simulation/waveforms/profiler_opt.vcd");
        $dumpvars(0, precision_transition_profiler_opt_tb);

        #12;
        reset = 0;

        // Sequence: 8, 8, 16, 16, 8.
        apply_operation(1'b1);
        apply_operation(1'b1);
        apply_operation(1'b0);
        apply_operation(1'b0);
        apply_operation(1'b1);

        #2;

        if (total_count == 5 &&
            count_8bit == 3 &&
            count_16bit == 2 &&
            transition_count == 2) begin
            $display("PASS: Counter and transition verification");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Counter and transition verification");
            fail_count = fail_count + 1;
        end

        $display("Total operations      = %0d", total_count);
        $display("8-bit operations      = %0d", count_8bit);
        $display("16-bit operations     = %0d", count_16bit);
        $display("Transitions           = %0d", transition_count);

        // Invalid operation must not change counters.
        @(negedge clk);
        operation_valid = 0;
        precision_mode = 0;

        @(posedge clk);
        #1;

        if (total_count == 5 && transition_count == 2) begin
            $display("PASS: Invalid operation ignored");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Invalid operation handling");
            fail_count = fail_count + 1;
        end

        $display("-------------------------------");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("-------------------------------");

        $finish;
    end

endmodule
