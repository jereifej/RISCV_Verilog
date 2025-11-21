`timescale 1ms/10us
`include "ALU/source/slt.v"
module slt_tb;
    reg  signed [63:0] a, b;
    wire        [0:0] y;

    slt dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("slt_tb.vcd");
        $dumpvars(0, slt_tb);
        $display("a b | y");
        $display("------------------------------------------------------------");
        a = 64'sd10; b = 64'sd20; #1; $display("%0d %0d | %0d", a, b, y); if (y !== (a < b)) $fatal(1, "Test 1 failed: %0d < %0d != %0d", a, b, y);
        a = -64'sd5; b = 64'sd0; #1; $display("%0d %0d | %0d", a, b, y); if (y !== (a < b)) $fatal(1, "Test 2 failed: %0d < %0d != %0d", a, b, y);
        a = 64'sd100; b = 64'sd100; #1; $display("%0d %0d | %0d", a, b, y); if (y !== (a < b)) $fatal(1, "Test 3 failed: %0d < %0d != %0d", a, b, y);
        a = -64'sd1; b = -64'sd2; #1; $display("%0d %0d | %0d", a, b, y); if (y !== (a < b)) $fatal(1, "Test 4 failed: %0d < %0d != %0d", a, b, y);
        $display("All SLT tests passed.");
        $finish;
    end
endmodule
