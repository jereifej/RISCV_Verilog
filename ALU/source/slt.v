module slt (
    input  signed [63:0] a,
    input  signed [63:0] b,
    output        [0:0] y
);
    assign y = (a < b) ? 1'b1 : 1'b0;
endmodule
