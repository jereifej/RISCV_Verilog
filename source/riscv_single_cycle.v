module riscv_single_cycle (
    input clk,
    input rst
);
    // Program Counter
    wire [63:0] pc_next;
    reg [63:0] pc;
    wire [31:0] instr;

    // Instruction Memory
    instruction_memory imem (
        .addr(pc),
        .instr(instr)
    );

    // Control signals
    wire RegWrite, MemToReg, ALUsrc, branch, jump, memWrite, memRead;
    wire [2:0] alu_sel;

    // Main Control
    control_fsm control (
        .instr(instr),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .ALUsrc(ALUsrc),
        .branch(branch),
        .jump(jump),
        .memWrite(memWrite),
        .memRead(memRead),
        .alu_sel(alu_sel)
    );

    // Register File
    wire [63:0] regA, regB, regW;
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];

    regfile64 rf (
        .clk(clk),
        .rst(rst),
        .we(RegWrite),
        .Rw(rd),
        .Ra(rs1),
        .Rb(rs2),
        .W(regW),
        .A(regA),
        .B(regB)
    );

    // Immediate Generator and decoded fields
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [63:0] imm;
    immediate_generator imm_gen (
        .instr(instr),
        .imm(imm)
    );

    // ALU
    wire [63:0] alu_in2 = ALUsrc ? imm : regB;
    wire [63:0] alu_result;
    wire alu_zero;

    ALU alu (
        .A(regA),
        .B(alu_in2),
        .ALUop(alu_sel),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Data Memory
    wire [63:0] mem_out;
    data_mem64 dmem (
        .clk(clk),
        .memread(memRead),
        .memwrite(memWrite),
        .funct3(funct3),
        .addr(alu_result),
        .wdata(regB),
        .rdata(mem_out)
    );

    // Writeback Mux
    wire is_jal   = (opcode == 7'b1101111);
    wire is_jalr  = (opcode == 7'b1100111);
    wire is_lui   = (opcode == 7'b0110111);
    wire is_auipc = (opcode == 7'b0010111);
    wire [63:0] pc_plus4 = pc + 64'd4;
    wire [63:0] auipc_val = pc + imm;
    assign regW = (is_jal | is_jalr) ? pc_plus4 :
                  is_lui             ? imm :
                  is_auipc           ? auipc_val :
                  (MemToReg ? mem_out : alu_result);

    // PC update logic
    // Branch decision logic
    reg branch_taken;
    always @* begin
        branch_taken = 1'b0;
        if (branch) begin
            case (funct3)
                3'b000: branch_taken = (regA == regB); // BEQ
                3'b001: branch_taken = (regA != regB); // BNE
                3'b100: branch_taken = ($signed(regA) < $signed(regB)); // BLT
                3'b101: branch_taken = ($signed(regA) >= $signed(regB)); // BGE
                3'b110: branch_taken = (regA < regB); // BLTU
                3'b111: branch_taken = (regA >= regB); // BGEU
            endcase
        end
    end

    // Jump target selection
    wire [63:0] branch_target = pc + imm;
    wire [63:0] jalr_target   = (regA + imm) & ~64'd1;
    wire [63:0] jump_target   = is_jalr ? jalr_target : branch_target;

    pc_update pc_upd (
        .clk(clk),
        .rst(rst),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_in(pc),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .pc_out(pc_next)
    );

    // PC register update
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 64'b0;
        else
            pc <= pc_next;
    end

endmodule
