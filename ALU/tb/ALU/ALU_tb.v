`timescale 1ms/10us
`include "ALU/source/ALU.v"
module ALU_tb;
    reg  [63:0] A, B;
    reg  [3:0]  ALUop;
    wire [63:0] result;

    ALU dut (
        .A(A),
        .B(B),
        .ALUop(ALUop),
        .result(result)
    );

    initial begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);
        $display("A B ALUop | result");
        $display("------------------------------------------------------------");
        // AND
        A = 64'hF0F0F0F0F0F0F0F0; B = 64'h0F0F0F0F0F0F0F0F; ALUop = 4'b0000; #1;
        $display("%h %h %b | %h", A, B, ALUop, result);
        if (result !== (A & B)) $fatal(1, "AND failed: %h & %h != %h", A, B, result);
        // OR
        A = 64'hF0F0F0F0F0F0F0F0; B = 64'h0F0F0F0F0F0F0F0F; ALUop = 4'b0001; #1;
        $display("%h %h %b | %h", A, B, ALUop, result);
        if (result !== (A | B)) $fatal(1, "OR failed: %h | %h != %h", A, B, result);
        // ADD
        A = 64'd123; B = 64'd456; ALUop = 4'b0010; #1;
        $display("%d %d %b | %d", A, B, ALUop, result);
        if (result !== (A + B)) $fatal(1, "ADD failed: %d + %d != %d", A, B, result);
        // SUBTRACT
        A = 64'd1000; B = 64'd1; ALUop = 4'b0110; #1;
        $display("%d %d %b | %d", A, B, ALUop, result);
        if (result !== (A - B)) $fatal(1, "SUB failed: %d - %d != %d", A, B, result);
        // SLT
        A = -64'sd5; B = 64'sd3; ALUop = 4'b0111; #1;
        $display("%0d %0d %b | %0d", $signed(A), $signed(B), ALUop, result);
        if (result !== (($signed(A) < $signed(B)) ? 64'd1 : 64'd0)) $fatal(1, "SLT failed: %0d < %0d != %0d", $signed(A), $signed(B), result);
        $display("All ALU tests passed.");
        $finish;
    end
endmodule
