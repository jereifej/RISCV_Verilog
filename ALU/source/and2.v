module and2 (
    input [63:0] a,
    input [63:0] b,
    output [63:0] y
);
    assign y = a & b;
endmodule