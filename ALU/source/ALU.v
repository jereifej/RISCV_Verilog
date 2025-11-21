module ALU (
    input  [63:0] A,
    input  [63:0] B,
    input  [2:0]  ALUop,
    output reg [63:0] result,
    output zero
);
    always @* begin
        case (ALUop)
            3'b000: result = A & B;                 // AND
            3'b001: result = A | B;                 // OR
            3'b010: result = A + B;                 // ADD
            3'b110: result = A - B;                 // SUB
            3'b011: result = A << B[5:0];           // SLL
            3'b111: result = A >> B[5:0];           // SRL
            3'b101: result = $signed(A) >>> B[5:0]; // SRA
            3'b100: result = A ^ B;                 // XOR
            default: result = 64'd0;
        endcase
    end

    assign zero = (result == 64'd0);
endmodule
