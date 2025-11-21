module srl (
    input  [63:0] a,
    input  [5:0]  shamt,
    output [63:0] y
);
    assign y = a >> shamt;
endmodule
