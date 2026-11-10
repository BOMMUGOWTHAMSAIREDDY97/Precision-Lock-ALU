
module precision_lock_system (
    input wire clk,
    input wire reset,
    input wire operation_valid,

    input signed [15:0] operand_a,
    input signed [15:0] operand_b,
    input wire [1:0] operation,

    output wire signed [15:0] result,

    output wire precision_8_candidate,
    output wire precision_mode,

    output wire [15:0] total_count,
    output wire [15:0] count_8bit,
    output wire [15:0] count_16bit,
    output wire [15:0] transition_count,

    output wire [6:0] percentage_8bit,
    output wire [6:0] percentage_16bit
);

    // Module 1: Precision Detector
    precision_detector detector (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .precision_8_candidate(precision_8_candidate)
    );

    // Module 2: Precision-Lock ALU
    precision_lock_alu alu (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation(operation),
        .result(result),
        .precision_mode(precision_mode)
    );

    // Module 3: Precision Transition Profiler
    precision_transition_profiler profiler (
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

endmodule
