`timescale 1ms/10us
`include "ALU/source/or2.v"
module or2_tb;
    reg [63:0] a, b;
    wire [63:0] y;

    // Instantiate the DUT (Device Under Test)
    or2 dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("or2_tb.vcd");
        $dumpvars(0, or2_tb);
        $display("a b | y");
        $display("------------------------------------------------------------");
        a = 64'h0123456789ABCDEF; b = 64'hFEDCBA9876543210; #1; $display("%h %h | %h", a, b, y); if (y !== (a | b)) $fatal(1, "Test 1 failed: %h | %h != %h", a, b, y);
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'h0000000000000000; #1; $display("%h %h | %h", a, b, y); if (y !== (a | b)) $fatal(1, "Test 2 failed: %h | %h != %h", a, b, y);
        a = 64'h1234567890ABCDEF; b = 64'h0F0F0F0F0F0F0F0F; #1; $display("%h %h | %h", a, b, y); if (y !== (a | b)) $fatal(1, "Test 3 failed: %h | %h != %h", a, b, y);
        a = 64'hAAAAAAAAAAAAAAAA; b = 64'h5555555555555555; #1; $display("%h %h | %h", a, b, y); if (y !== (a | b)) $fatal(1, "Test 4 failed: %h | %h != %h", a, b, y);
        $display("All OR tests passed.");
        $finish;
    end
endmodule