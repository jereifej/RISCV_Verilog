// RISC-V single-cycle combinational control
module control_fsm (
    input  [31:0] instr,
    output reg    RegWrite,
    output reg    MemToReg,
    output reg    ALUsrc,
    output reg    branch,
    output reg    jump,
    output reg    memWrite,
    output reg    memRead,
    output reg [2:0] alu_sel
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire       funct7_5 = instr[30]; // MSB of funct7, distinguishes add/sub/srl/sra

    always @* begin
        // defaults
        RegWrite = 0;
        MemToReg = 0;
        ALUsrc   = 0;
        branch   = 0;
        jump     = 0;
        memWrite = 0;
        memRead  = 0;
        alu_sel  = 3'b010; // ADD default

        case (opcode)
            7'b0110011: begin // R-type
                RegWrite = 1;
                case (funct3)
                    3'b000: alu_sel = funct7_5 ? 3'b110 : 3'b010; // SUB/ADD
                    3'b111: alu_sel = 3'b000; // AND
                    3'b110: alu_sel = 3'b001; // OR
                    3'b100: alu_sel = 3'b100; // XOR
                    3'b001: alu_sel = 3'b011; // SLL
                    3'b101: alu_sel = funct7_5 ? 3'b101 : 3'b100; // SRA/SRL share XOR slot; override below
                    default: alu_sel = 3'b010;
                endcase
                if (funct3 == 3'b101)
                    alu_sel = funct7_5 ? 3'b101 : 3'b111; // reuse codes for SRL/SRA
            end
            7'b0010011: begin // I-type ALU (ADDI/ANDI/ORI/XORI/SLLI/SRLI/SRAI)
                RegWrite = 1;
                ALUsrc   = 1;
                case (funct3)
                    3'b000: alu_sel = 3'b010; // ADDI
                    3'b111: alu_sel = 3'b000; // ANDI
                    3'b110: alu_sel = 3'b001; // ORI
                    3'b100: alu_sel = 3'b100; // XORI
                    3'b001: alu_sel = 3'b011; // SLLI
                    3'b101: alu_sel = funct7_5 ? 3'b101 : 3'b111; // SRAI/SRLI
                    default: alu_sel = 3'b010;
                endcase
            end
            7'b0000011: begin // LOAD
                RegWrite = 1;
                MemToReg = 1;
                ALUsrc   = 1;
                memRead  = 1;
                alu_sel  = 3'b010; // address = base + imm
            end
            7'b0100011: begin // STORE
                ALUsrc   = 1;
                memWrite = 1;
                alu_sel  = 3'b010;
            end
            7'b1100011: begin // BRANCH
                branch   = 1;
                alu_sel  = 3'b110; // use subtraction for comparisons
            end
            7'b1101111: begin // JAL
                RegWrite = 1;
                jump     = 1;
                alu_sel  = 3'b010; // pc handling outside
            end
            7'b1100111: begin // JALR
                RegWrite = 1;
                jump     = 1;
                ALUsrc   = 1;
                alu_sel  = 3'b010;
            end
            7'b0110111: begin // LUI
                RegWrite = 1;
                ALUsrc   = 1;
                alu_sel  = 3'b010;
            end
            7'b0010111: begin // AUIPC
                RegWrite = 1;
                ALUsrc   = 1;
                alu_sel  = 3'b010;
            end
        endcase
    end
endmodule
