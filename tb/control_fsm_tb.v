`timescale 1ms/10us
`include "control_fsm.v"
module control_fsm_tb;
    reg clk, rst;
    reg [31:0] instr;
    wire RegWrite, MemToReg, RegDst, ALUsrc, branch, jump, memWrite, memRead;
    wire [1:0] ALUop;

    control_fsm dut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .RegDst(RegDst),
        .ALUsrc(ALUsrc),
        .branch(branch),
        .jump(jump),
        .memWrite(memWrite),
        .memRead(memRead),
        .ALUop(ALUop)
    );
    // Access FSM state for checking
    wire [2:0] state = dut.state;
    parameter IFETCH = 3'd0, DECODE = 3'd1, EXEC = 3'd2, MEM = 3'd3, WB = 3'd4;

    initial begin
        $dumpfile("control_fsm_tb.vcd");
        $dumpvars(1, control_fsm_tb);
        clk = 0;
        rst = 1; instr = 32'd0; #2;
        rst = 0;
        // R-type (opcode 0110011)
        instr = 32'b0000000_00010_00001_000_00011_0110011;
        wait (state == EXEC); #0.1;
        if (!(RegWrite && RegDst && (ALUop == 2'b10) && !MemToReg && !ALUsrc && !branch && !jump && !memWrite && !memRead))
            $fatal(1, "R-type control signal check failed");
        // Load (opcode 0000011)
        instr = 32'b000000000100_00001_010_00010_0000011;
        wait (state == EXEC); #0.1;
        if (!(RegWrite && MemToReg && ALUsrc && memRead && (ALUop == 2'b00) && !RegDst && !branch && !jump && !memWrite))
            $fatal(1, "Load control signal check failed");
        // Store (opcode 0100011)
        instr = 32'b0000000_00010_00001_010_00011_0100011;
        wait (state == EXEC); #0.1;
        if (!(ALUsrc && memWrite && (ALUop == 2'b00) && !RegWrite && !MemToReg && !RegDst && !branch && !jump && !memRead))
            $fatal(1, "Store control signal check failed");
        // Branch (opcode 1100011)
        instr = 32'b0000000_00010_00001_000_00011_1100011;
        wait (state == EXEC); #0.1;
        if (!(branch && (ALUop == 2'b01) && !RegWrite && !MemToReg && !RegDst && !ALUsrc && !jump && !memWrite && !memRead))
            $fatal(1, "Branch control signal check failed");
        // Jump (opcode 1101111)
        instr = 32'b00000000000000000011_00001_1101111;
        wait (state == EXEC); #0.1;
        if (!(jump && !RegWrite && !MemToReg && !RegDst && !ALUsrc && !branch && !memWrite && !memRead && (ALUop == 2'b00)))
            $fatal(1, "Jump control signal check failed");
        $display("All control_fsm tests passed.");
        $finish;
    end

    always #1 clk = ~clk;
    initial $monitor($time, " clk=%b rst=%b instr=%b | RegWrite=%b MemToReg=%b RegDst=%b ALUsrc=%b branch=%b jump=%b memWrite=%b memRead=%b ALUop=%b", clk, rst, instr, RegWrite, MemToReg, RegDst, ALUsrc, branch, jump, memWrite, memRead, ALUop);
endmodule
