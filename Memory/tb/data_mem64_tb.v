`timescale 1ms/10us
`include "Memory/source/data_mem64.v"
module data_mem64_tb;
    reg clk, memread, memwrite;
    reg [63:0] addr, wdata;
    wire [63:0] rdata;

    data_mem64 dut (
        .clk(clk),
        .memread(memread),
        .memwrite(memwrite),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    initial begin
        $dumpfile("data_mem64_tb.vcd");
        $dumpvars(1, data_mem64_tb);
        clk = 0;
        memread = 0; memwrite = 0; addr = 64'd0; wdata = 64'd0; #2;
        // Write 0xDEADBEEFCAFEBABE to address 0
        memwrite = 1; addr = 64'd0; wdata = 64'hDEADBEEFCAFEBABE; #2;
        memwrite = 0;
        // Read from address 0
        memread = 1; addr = 64'd0; #2;
        $display("Read data: %h", rdata);
        if (rdata !== 64'hDEADBEEFCAFEBABE) $fatal(1, "Read/Write failed at addr 0: %h", rdata);
        memread = 0;
        // Write 0x0123456789ABCDEF to address 8
        memwrite = 1; addr = 64'd8; wdata = 64'h0123456789ABCDEF; #2;
        memwrite = 0;
        // Read from address 8
        memread = 1; addr = 64'd8; #2;
        $display("Read data: %h", rdata);
        if (rdata !== 64'h0123456789ABCDEF) $fatal(1, "Read/Write failed at addr 8: %h", rdata);
        memread = 0;
        $display("All data_mem64 tests passed.");
        $finish;
    end

    always #1 clk = ~clk;
    initial $monitor($time, " clk=%b memread=%b memwrite=%b addr=%h wdata=%h rdata=%h", clk, memread, memwrite, addr, wdata, rdata);
endmodule
