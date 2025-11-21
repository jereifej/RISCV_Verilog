`timescale 1ms/10us
`include "ALU/source/srl.v"
module srl_tb;
    reg  [63:0] a;
    reg  [5:0]  shamt;
    wire [63:0] y;

    srl dut (
        .a(a),
        .shamt(shamt),
        .y(y)
    );

    initial begin
        $dumpfile("srl_tb.vcd");
        $dumpvars(0, srl_tb);
        $display("a shamt | y");
        $display("------------------------------------------------------------");
        a = 64'h0123456789ABCDEF; shamt = 4; #1; $display("%h %0d | %h", a, shamt, y); if (y !== (a >> shamt)) $fatal(1, "Test 1 failed: %h >> %0d != %h", a, shamt, y);
        a = 64'hFFFFFFFFFFFFFFFF; shamt = 8; #1; $display("%h %0d | %h", a, shamt, y); if (y !== (a >> shamt)) $fatal(1, "Test 2 failed: %h >> %0d != %h", a, shamt, y);
        a = 64'h1234567890ABCDEF; shamt = 16; #1; $display("%h %0d | %h", a, shamt, y); if (y !== (a >> shamt)) $fatal(1, "Test 3 failed: %h >> %0d != %h", a, shamt, y);
        a = 64'hAAAAAAAAAAAAAAAA; shamt = 32; #1; $display("%h %0d | %h", a, shamt, y); if (y !== (a >> shamt)) $fatal(1, "Test 4 failed: %h >> %0d != %h", a, shamt, y);
        $display("All SRL tests passed.");
        $finish;
    end
endmodule
