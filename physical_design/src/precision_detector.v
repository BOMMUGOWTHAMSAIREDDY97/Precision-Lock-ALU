
module precision_detector (
    input  signed [15:0] operand_a,
    input  signed [15:0] operand_b,
    output wire precision_8_candidate
);

    wire a_fits_8;
    wire b_fits_8;

    assign a_fits_8 = (operand_a[15:8] == {8{operand_a[7]}});
    assign b_fits_8 = (operand_b[15:8] == {8{operand_b[7]}});

    assign precision_8_candidate = a_fits_8 && b_fits_8;

endmodule
