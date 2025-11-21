`timescale 1ns/1ps

module riscv_single_cycle_tb;
	reg clk = 0;
	reg rst = 1;
	integer i;

	// Instantiate DUT
	riscv_single_cycle dut (
		.clk(clk),
		.rst(rst)
	);

	// Clock generation
	always #5 clk = ~clk;

	// Instruction memory preload
	initial begin
		// Wait for reset
		#20;
		rst = 0;
		// Preload instruction memory for each test
		// Example: $readmemh("test_add.hex", dut.imem.mem);
		// Add more $readmemh for other tests as needed
	end

	// Test sequence
	initial begin
		// Test 1: ADD, SUB, AND, OR, XOR (R-type)
		$display("Test 1: R-type instructions");
		$readmemh("tb/test_rtype.hex", dut.imem.mem, 0, 5);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 20; i = i + 1) @(posedge clk);
		// Check register file for expected results
		if (dut.rf.debug_regs[1] !== 64'h0000000000000002) $fatal(1, "ADD failed");
		if (dut.rf.debug_regs[2] !== 64'hfffffffffffffffe) $fatal(1, "SUB failed");
		if (dut.rf.debug_regs[3] !== 64'h0000000000000000) $fatal(1, "AND failed");
		if (dut.rf.debug_regs[4] !== 64'h0000000000000003) $fatal(1, "OR failed");
		if (dut.rf.debug_regs[5] !== 64'h0000000000000003) $fatal(1, "XOR failed");
		$display("R-type passed");

		// Test 2: ADDI, ANDI, ORI, XORI (I-type)
		$display("Test 2: I-type instructions");
		$readmemh("tb/test_itype.hex", dut.imem.mem, 0, 3);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 20; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[6] !== 64'h0000000000000004) $fatal(1, "ADDI failed");
		if (dut.rf.debug_regs[7] !== 64'h0000000000000000) $fatal(1, "ANDI failed");
		if (dut.rf.debug_regs[8] !== 64'h0000000000000004) $fatal(1, "ORI failed");
		if (dut.rf.debug_regs[9] !== 64'h0000000000000004) $fatal(1, "XORI failed");
		$display("I-type passed");

		// Test 3: SLL, SRL, SRA (R-type shifts)
		$display("Test 3: Shift instructions");
		$readmemh("tb/test_shift.hex", dut.imem.mem, 0, 5);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 20; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[10] !== 64'h0000000000000008) $fatal(1, "SLL failed");
		if (dut.rf.debug_regs[11] !== 64'h0000000000000001) $fatal(1, "SRL failed");
		if (dut.rf.debug_regs[12] !== 64'hffffffffffffffff) $fatal(1, "SRA failed");
		$display("Shift passed");

		// Test 4: LUI, AUIPC (U-type)
		$display("Test 4: U-type instructions");
		$readmemh("tb/test_utype.hex", dut.imem.mem, 0, 1);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 10; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[13] !== 64'h0000000012345000) $fatal(1, "LUI failed");
		if (dut.rf.debug_regs[14] !== 64'h0000000012345004) $fatal(1, "AUIPC failed");
		$display("U-type passed");

		// Test 5: JAL, JALR (J-type)
		$display("Test 5: J-type instructions");
		$readmemh("tb/test_jtype.hex", dut.imem.mem, 0, 2);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 20; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[15] !== 64'h0000000000000008) $fatal(1, "JAL failed");
		if (dut.rf.debug_regs[16] !== 64'h000000000000000c) $fatal(1, "JALR failed");
		$display("J-type passed");

		// Test 6: BEQ, BNE, BLT, BGE, BLTU, BGEU (B-type)
		$display("Test 6: Branch instructions");
		$readmemh("tb/test_btype.hex", dut.imem.mem, 0, 5);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 30; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[17] !== 64'h0000000000000001) $fatal(1, "BEQ failed");
		if (dut.rf.debug_regs[18] !== 64'h0000000000000002) $fatal(1, "BNE failed");
		if (dut.rf.debug_regs[19] !== 64'h0000000000000003) $fatal(1, "BLT failed");
		if (dut.rf.debug_regs[20] !== 64'h0000000000000004) $fatal(1, "BGE failed");
		if (dut.rf.debug_regs[21] !== 64'h0000000000000005) $fatal(1, "BLTU failed");
		if (dut.rf.debug_regs[22] !== 64'h0000000000000006) $fatal(1, "BGEU failed");
		$display("Branch passed");

		// Test 7: LB, LH, LW, LD, LBU, LHU, LWU (Load)
		$display("Test 7: Load instructions");
		$readmemh("tb/test_load.hex", dut.imem.mem, 0, 6);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 30; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[23] !== 64'h00000000000000ff) $fatal(1, "LB failed");
		if (dut.rf.debug_regs[24] !== 64'h000000000000ffff) $fatal(1, "LH failed");
		if (dut.rf.debug_regs[25] !== 64'h00000000ffffffff) $fatal(1, "LW failed");
		if (dut.rf.debug_regs[26] !== 64'hffffffffffffffff) $fatal(1, "LD failed");
		if (dut.rf.debug_regs[27] !== 64'h00000000000000ff) $fatal(1, "LBU failed");
		if (dut.rf.debug_regs[28] !== 64'h000000000000ffff) $fatal(1, "LHU failed");
		if (dut.rf.debug_regs[29] !== 64'h00000000ffffffff) $fatal(1, "LWU failed");
		$display("Load passed");

		// Test 8: SB, SH, SW, SD (Store)
		$display("Test 8: Store instructions");
		$readmemh("tb/test_store.hex", dut.imem.mem, 0, 3);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 30; i = i + 1) @(posedge clk);
		// Memory checks for store instructions
		if (dut.dmem.mem[0][7:0]   !== dut.rf.debug_regs[1][7:0]) $fatal(1, "SB failed");
		if ({dut.dmem.mem[1], dut.dmem.mem[0]} !== dut.rf.debug_regs[2][15:0]) $fatal(1, "SH failed");
		if ({dut.dmem.mem[3], dut.dmem.mem[2], dut.dmem.mem[1], dut.dmem.mem[0]} !== dut.rf.debug_regs[3][31:0]) $fatal(1, "SW failed");
		if ({dut.dmem.mem[7], dut.dmem.mem[6], dut.dmem.mem[5], dut.dmem.mem[4],
		     dut.dmem.mem[3], dut.dmem.mem[2], dut.dmem.mem[1], dut.dmem.mem[0]} !== dut.rf.debug_regs[4]) $fatal(1, "SD failed");
		$display("Store passed");

		// Test 9: Final integration program
		$display("Test 9: Final integration program");
		$readmemh("tb/test_final.hex", dut.imem.mem, 0, 27);
		rst = 1; #10; rst = 0;
		for (i = 0; i < 80; i = i + 1) @(posedge clk);
		if (dut.rf.debug_regs[1]  !== 64'h5)                    $fatal(1, "Final: ADDI failed");
		if (dut.rf.debug_regs[2]  !== 64'ha)                    $fatal(1, "Final: ADD failed");
		if (dut.rf.debug_regs[3]  !== 64'h5)                    $fatal(1, "Final: SUB failed");
		if (dut.rf.debug_regs[4]  !== 64'h1)                    $fatal(1, "Final: ANDI failed");
        if (dut.rf.debug_regs[5]  !== 64'h9)                    $fatal(1, "Final: ORI failed");
		if (dut.rf.debug_regs[6]  !== 64'h8)                    $fatal(1, "Final: XORI failed");
		if (dut.rf.debug_regs[7]  !== 64'h10)                   $fatal(1, "Final: SLLI failed");
		if (dut.rf.debug_regs[8]  !== 64'h4)                    $fatal(1, "Final: SRLI failed");
		if (dut.rf.debug_regs[9]  !== 64'hffffffffffffffff)     $fatal(1, "Final: SRAI failed");
		if (dut.rf.debug_regs[10] !== 64'h0)                    $fatal(1, "Final: Branch skip failed");
		if (dut.rf.debug_regs[11] !== 64'h34)                   $fatal(1, "Final: JAL failed");
		if (dut.rf.debug_regs[12] !== 64'h7)                    $fatal(1, "Final: ADDI after jump failed");
		if (dut.rf.debug_regs[13] !== 64'hffffffffabcde000)     $fatal(1, "Final: LUI failed");
		if (dut.rf.debug_regs[14] !== 64'h0000000000001040)     $fatal(1, "Final: AUIPC failed");
		if (dut.dmem.mem[0]      !== dut.rf.debug_regs[7][7:0]) $fatal(1, "Final: SB failed");
		if ({dut.dmem.mem[3], dut.dmem.mem[2]} !== dut.rf.debug_regs[2][15:0]) $fatal(1, "Final: SH failed");
		if ({dut.dmem.mem[7], dut.dmem.mem[6], dut.dmem.mem[5], dut.dmem.mem[4]} !== dut.rf.debug_regs[3][31:0]) $fatal(1, "Final: SW failed");
		if ({dut.dmem.mem[15], dut.dmem.mem[14], dut.dmem.mem[13], dut.dmem.mem[12], dut.dmem.mem[11], dut.dmem.mem[10], dut.dmem.mem[9], dut.dmem.mem[8]} !== dut.rf.debug_regs[4]) $fatal(1, "Final: SD failed");
		if (dut.rf.debug_regs[15] !== 64'h10)                   $fatal(1, "Final: LB failed");
		if (dut.rf.debug_regs[16] !== 64'ha)                    $fatal(1, "Final: LH failed");
		if (dut.rf.debug_regs[17] !== 64'h5)                    $fatal(1, "Final: LW failed");
		if (dut.rf.debug_regs[18] !== 64'h1)                    $fatal(1, "Final: LD failed");
		if (dut.rf.debug_regs[19] !== 64'h10)                   $fatal(1, "Final: LBU failed");
		if (dut.rf.debug_regs[20] !== 64'ha)                    $fatal(1, "Final: LHU failed");
		if (dut.rf.debug_regs[21] !== 64'h5)                    $fatal(1, "Final: LWU failed");
		$display("Final integration passed");

		$display("All tests passed!");
		$finish;
	end
endmodule
