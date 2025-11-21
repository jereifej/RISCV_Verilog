`timescale 1ms/10us
`include "Register File/source/reg64.v"
module reg64_tb;
    reg clk, rst, we;
    reg [63:0] d;
    wire [63:0] q;

    reg64 dut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .d(d),
        .q(q)
    );

    initial begin
        $dumpfile("reg64_tb.vcd");
        $dumpvars(1, reg64_tb);
        clk = 0;
        $monitor($time, " clk=%b rst=%b we=%b d=%h q=%h", clk, rst, we, d, q);
        rst = 1; we = 0; d = 64'hDEADBEEFDEADBEEF; #2;
        rst = 0; we = 1; d = 64'h0123456789ABCDEF; #2;
        we = 0; d = 64'hFFFFFFFFFFFFFFFF; #2;
        we = 1; d = 64'hA5A5A5A5A5A5A5A5; #2;
        $display("q = %h", q);
        if (q !== 64'hA5A5A5A5A5A5A5A5) $fatal(1, "Register write failed: %h", q);
        $display("All reg64 tests passed.");
        $finish;
    end

    always #1 clk = ~clk;
endmodule
