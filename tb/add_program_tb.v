`timescale 1ns/1ps

// Simple testbench to run a hex program on the single-cycle core.
module add_program_tb;
    parameter [1023:0] HEX_FILE   = "examples/add.hex";
    parameter integer   CYCLES    = 40;
    parameter integer   CHECK_A0  = 1;
    parameter [63:0]    EXPECT_A0 = 64'd5;

    reg clk = 0;
    reg rst = 1;
    integer i;
    reg [1023:0] hexfile;

    // DUT
    riscv_single_cycle dut (
        .clk(clk),
        .rst(rst)
    );

    // 10ns period clock
    always #5 clk = ~clk;

`ifdef ADD_TB_TRACE
    // Optional: trace each cycle (enable with -DADD_TB_TRACE)
    always @(posedge clk) begin
        $display("t=%0t pc=%h instr=%h x2=%h x10=%h", $time, dut.pc, dut.instr, dut.rf.debug_regs[2], dut.rf.debug_regs[10]);
    end
`endif

    initial begin
        if (!$value$plusargs("HEX=%s", hexfile)) begin
            hexfile = HEX_FILE;
        end
        $display("Loading program: %0s", hexfile);
        $readmemh(hexfile, dut.imem.mem);

        // Release reset after a short delay
        #20;
        rst = 0;

        // Run for a handful of cycles; the program is tiny
        for (i = 0; i < CYCLES; i = i + 1) @(posedge clk);

        $display("Final state: x2=%h x10=%h mem[232]=%h mem[240]=%h mem[248]=%h",
                 dut.rf.debug_regs[2],
                 dut.rf.debug_regs[10],
                 {dut.dmem.mem[239], dut.dmem.mem[238], dut.dmem.mem[237], dut.dmem.mem[236],
                  dut.dmem.mem[235], dut.dmem.mem[234], dut.dmem.mem[233], dut.dmem.mem[232]},
                 {dut.dmem.mem[247], dut.dmem.mem[246], dut.dmem.mem[245], dut.dmem.mem[244],
                  dut.dmem.mem[243], dut.dmem.mem[242], dut.dmem.mem[241], dut.dmem.mem[240]},
                 {dut.dmem.mem[255], dut.dmem.mem[254], dut.dmem.mem[253], dut.dmem.mem[252],
                  dut.dmem.mem[251], dut.dmem.mem[250], dut.dmem.mem[249], dut.dmem.mem[248]});

        // Check that x10 (a0) holds 5 (=2+3)
        if (CHECK_A0 && (dut.rf.debug_regs[10] !== EXPECT_A0)) begin
            $fatal(1, "program failed: x10 = %0d (expected %0d)", dut.rf.debug_regs[10], EXPECT_A0);
        end

        $display("Program passed: x10 = %0d", dut.rf.debug_regs[10]);
        $finish;
    end
endmodule
