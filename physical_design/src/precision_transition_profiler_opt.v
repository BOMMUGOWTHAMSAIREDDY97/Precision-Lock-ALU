
module precision_transition_profiler_opt (
    input wire clk,
    input wire reset,
    input wire operation_valid,
    input wire precision_mode,

    output reg [15:0] total_count,
    output reg [15:0] count_8bit,
    output reg [15:0] count_16bit,
    output reg [15:0] transition_count
);

    reg previous_mode;
    reg previous_mode_valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            total_count         <= 16'd0;
            count_8bit          <= 16'd0;
            count_16bit         <= 16'd0;
            transition_count    <= 16'd0;
            previous_mode       <= 1'b0;
            previous_mode_valid <= 1'b0;
        end
        else if (operation_valid) begin

            // Count total operations.
            if (total_count != 16'hFFFF)
                total_count <= total_count + 1'b1;

            // Count 8-bit or 16-bit operations.
            if (precision_mode) begin
                if (count_8bit != 16'hFFFF)
                    count_8bit <= count_8bit + 1'b1;
            end
            else begin
                if (count_16bit != 16'hFFFF)
                    count_16bit <= count_16bit + 1'b1;
            end

            // Count transitions between consecutive operations.
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
