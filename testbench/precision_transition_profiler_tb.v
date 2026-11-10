
`timescale 1ns/1ps

module precision_transition_profiler_tb;

    reg clk;
    reg reset;
    reg operation_valid;
    reg precision_mode;

    wire [15:0] total_count;
    wire [15:0] count_8bit;
    wire [15:0] count_16bit;
    wire [15:0] transition_count;

    wire [6:0] percentage_8bit;
    wire [6:0] percentage_16bit;

    integer pass_count;
    integer fail_count;

    precision_transition_profiler dut (
        .clk(clk),
        .reset(reset),
        .operation_valid(operation_valid),
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

    // Apply one valid operation.
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

        $dumpfile("simulation/waveforms/precision_profiler.vcd");
        $dumpvars(0, precision_transition_profiler_tb);

        $display("PRECISION TRANSITION PROFILER TEST STARTED");

        // Release reset.
        #12;
        reset = 0;

        // Sequence: 8, 8, 16, 16, 8.
        apply_operation(1'b1);
        apply_operation(1'b1);
        apply_operation(1'b0);
        apply_operation(1'b0);
        apply_operation(1'b1);

        #2;

        $display("--------------------------------");
        $display("Total operations       = %0d", total_count);
        $display("8-bit operations       = %0d", count_8bit);
        $display("16-bit operations      = %0d", count_16bit);
        $display("Precision transitions  = %0d", transition_count);
        $display("8-bit percentage       = %0d%%", percentage_8bit);
        $display("16-bit percentage      = %0d%%", percentage_16bit);
        $display("--------------------------------");

        // Verify counters.
        if (total_count == 5 &&
            count_8bit == 3 &&
            count_16bit == 2 &&
            transition_count == 2) begin
            $display("PASS: Counter verification");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Counter verification");
            fail_count = fail_count + 1;
        end

        // Verify percentages.
        if (percentage_8bit == 60 &&
            percentage_16bit == 40) begin
            $display("PASS: Percentage verification");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Percentage verification");
            fail_count = fail_count + 1;
        end

        // Verify that an invalid operation is ignored.
        @(negedge clk);
        precision_mode = 1'b0;
        operation_valid = 1'b0;

        @(posedge clk);
        #1;

        if (total_count == 5 &&
            transition_count == 2) begin
            $display("PASS: Invalid operation ignored");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Invalid operation handling");
            fail_count = fail_count + 1;
        end

        $display("--------------------------------");
        $display("TOTAL PASS = %0d", pass_count);
        $display("TOTAL FAIL = %0d", fail_count);
        $display("--------------------------------");

        $finish;
    end

endmodule
