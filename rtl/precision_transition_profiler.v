
module precision_transition_profiler (
    input wire clk,
    input wire reset,
    input wire operation_valid,
    input wire precision_mode,

    output reg [15:0] total_count,
    output reg [15:0] count_8bit,
    output reg [15:0] count_16bit,
    output reg [15:0] transition_count,

    output reg [6:0] percentage_8bit,
    output reg [6:0] percentage_16bit
);

    reg previous_mode;
    reg previous_mode_valid;

    wire [22:0] scaled_count_8;
    wire [22:0] scaled_count_16;
    wire [22:0] extended_total;

    // Scale counters by 100 for percentage calculation.
    assign scaled_count_8  = {7'd0, count_8bit} * 23'd100;
    assign scaled_count_16 = {7'd0, count_16bit} * 23'd100;
    assign extended_total  = {7'd0, total_count};

    // Calculate integer percentages.
    always @(*) begin
        percentage_8bit  = 7'd0;
        percentage_16bit = 7'd0;

        if (total_count != 0) begin
            percentage_8bit =
                scaled_count_8 / extended_total;

            percentage_16bit =
                scaled_count_16 / extended_total;
        end
    end

    // Collect operation statistics.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            total_count       <= 16'd0;
            count_8bit        <= 16'd0;
            count_16bit       <= 16'd0;
            transition_count  <= 16'd0;

            previous_mode       <= 1'b0;
            previous_mode_valid <= 1'b0;
        end
        else if (operation_valid) begin

            // Count total operations.
            if (total_count != 16'hFFFF)
                total_count <= total_count + 1'b1;

            // Count selected precision.
            if (precision_mode == 1'b1) begin
                if (count_8bit != 16'hFFFF)
                    count_8bit <= count_8bit + 1'b1;
            end
            else begin
                if (count_16bit != 16'hFFFF)
                    count_16bit <= count_16bit + 1'b1;
            end

            // Count changes between consecutive operations.
            // The first operation is not a transition.
            if (previous_mode_valid &&
                (precision_mode != previous_mode)) begin

                if (transition_count != 16'hFFFF)
                    transition_count <= transition_count + 1'b1;
            end

            previous_mode       <= precision_mode;
            previous_mode_valid <= 1'b1;
        end
    end

endmodule
