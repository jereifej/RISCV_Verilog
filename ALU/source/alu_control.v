// Pass-through ALU control for single-cycle RISC-V
module alu_control (
    input  [2:0] func, // already decoded 3-bit ALU select
    output [2:0] ALUoperation
);
    assign ALUoperation = func;
endmodule
