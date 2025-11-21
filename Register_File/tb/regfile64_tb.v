`timescale 1ms/10us
`include "Register File/source/regfile64.v"
module regfile64_tb;
    reg clk, rst, we;
    reg [4:0] Rw, Ra, Rb;
    reg [63:0] W;
    wire [63:0] A, B;

    regfile64 dut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .Rw(Rw),
        .Ra(Ra),
        .Rb(Rb),
        .W(W),
        .A(A),
        .B(B)
    );

    initial begin
        $dumpfile("regfile64_tb.vcd");
        $dumpvars(1, regfile64_tb);
        // Dump each register individually for GTKWave
        $dumpvars(0, regfile64_tb.dut.q[0]);
        $dumpvars(0, regfile64_tb.dut.q[1]);
        $dumpvars(0, regfile64_tb.dut.q[2]);
        $dumpvars(0, regfile64_tb.dut.q[3]);
        $dumpvars(0, regfile64_tb.dut.q[4]);
        $dumpvars(0, regfile64_tb.dut.q[5]);
        $dumpvars(0, regfile64_tb.dut.q[6]);
        $dumpvars(0, regfile64_tb.dut.q[7]);
        $dumpvars(0, regfile64_tb.dut.q[8]);
        $dumpvars(0, regfile64_tb.dut.q[9]);
        $dumpvars(0, regfile64_tb.dut.q[10]);
        $dumpvars(0, regfile64_tb.dut.q[11]);
        $dumpvars(0, regfile64_tb.dut.q[12]);
        $dumpvars(0, regfile64_tb.dut.q[13]);
        $dumpvars(0, regfile64_tb.dut.q[14]);
        $dumpvars(0, regfile64_tb.dut.q[15]);
        $dumpvars(0, regfile64_tb.dut.q[16]);
        $dumpvars(0, regfile64_tb.dut.q[17]);
        $dumpvars(0, regfile64_tb.dut.q[18]);
        $dumpvars(0, regfile64_tb.dut.q[19]);
        $dumpvars(0, regfile64_tb.dut.q[20]);
        $dumpvars(0, regfile64_tb.dut.q[21]);
        $dumpvars(0, regfile64_tb.dut.q[22]);
        $dumpvars(0, regfile64_tb.dut.q[23]);
        $dumpvars(0, regfile64_tb.dut.q[24]);
        $dumpvars(0, regfile64_tb.dut.q[25]);
        $dumpvars(0, regfile64_tb.dut.q[26]);
        $dumpvars(0, regfile64_tb.dut.q[27]);
        $dumpvars(0, regfile64_tb.dut.q[28]);
        $dumpvars(0, regfile64_tb.dut.q[29]);
        $dumpvars(0, regfile64_tb.dut.q[30]);
        $dumpvars(0, regfile64_tb.dut.q[31]);
        clk = 0;
        rst = 1; we = 0; Rw = 0; Ra = 0; Rb = 0; W = 64'd0; #2;
        rst = 0;
        // Write to x1
        we = 1; Rw = 5'd1; W = 64'h1111111111111111; #2;
        // Write to x2
        we = 1; Rw = 5'd2; W = 64'h2222222222222222; #2;
        // Write to x0 (should stay zero)
        we = 1; Rw = 5'd0; W = 64'hFFFFFFFFFFFFFFFF; #2;
        // Read x1 and x2
        we = 0; Ra = 5'd1; Rb = 5'd2; #2;
        $display("A = %h, B = %h", A, B);
        if (A !== 64'h1111111111111111 || B !== 64'h2222222222222222) $fatal(1, "Read failed: A = %h, B = %h", A, B);
        // Read x0
        Ra = 5'd0; Rb = 5'd0; #2;
        $display("A = %h, B = %h (should be 0)", A, B);
        if (A !== 64'd0 || B !== 64'd0) $fatal(1, "x0 not zero: A = %h, B = %h", A, B);
        $display("All regfile64 tests passed.");
        $finish;
    end

    always #1 clk = ~clk;
    initial $monitor($time, " clk=%b rst=%b we=%b Rw=%d Ra=%d Rb=%d W=%h | A=%h B=%h", clk, rst, we, Rw, Ra, Rb, W, A, B);
endmodule
