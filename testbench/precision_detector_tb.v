
`timescale 1ns/1ps

module precision_detector_tb;

    reg signed [15:0] operand_a;
    reg signed [15:0] operand_b;
    wire precision_8_candidate;

    integer pass_count;
    integer fail_count;

    precision_detector dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .precision_8_candidate(precision_8_candidate)
    );

    task check;
        input signed [15:0] a;
        input signed [15:0] b;
        input expected;

        begin
            operand_a = a;
            operand_b = b;
            #10;

            if (precision_8_candidate === expected) begin
                $display("PASS: A=%0d B=%0d Mode=%b",
                         a, b, precision_8_candidate);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: A=%0d B=%0d Expected=%b Got=%b",
                         a, b, expected, precision_8_candidate);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $dumpfile("simulation/waveforms/precision_detector.vcd");
        $dumpvars(0, precision_detector_tb);

        $display("Precision Detector Test Started");

        check(25, 50, 1'b1);
        check(127, 100, 1'b1);
        check(-128, -50, 1'b1);
        check(-1, 1, 1'b1);
        check(128, 10, 1'b0);
        check(-129, 10, 1'b0);
        check(50, 300, 1'b0);
        check(-200, -300, 1'b0);

        $display("--------------------------------");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("--------------------------------");

        $finish;
    end

endmodule
