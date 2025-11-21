// RISC-V Immediate Generator (I, S, B, U, J types)
module immediate_generator(
    input  [31:0] instr,
    output reg [63:0] imm
);
    wire [6:0] opcode = instr[6:0];
    always @* begin
        case (opcode)
            7'b0010011, // I-type (ADDI, etc)
            7'b0000011, // I-type (LOAD)
            7'b1100111: // I-type (JALR)
                imm = {{52{instr[31]}}, instr[31:20]};
            7'b0100011: // S-type (STORE)
                imm = {{52{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: // B-type (BRANCH)
                imm = {{51{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b0110111, // U-type (LUI)
            7'b0010111: // U-type (AUIPC)
                imm = {{32{instr[31]}}, instr[31:12], 12'b0};
            7'b1101111: // J-type (JAL)
                imm = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default:
                imm = 64'b0;
        endcase
    end
endmodule
