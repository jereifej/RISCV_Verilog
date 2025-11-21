// PC update logic for single-cycle RISC-V
module pc_update(
    input        clk,   // unused in combinational version
    input        rst,
    input        branch_taken,
    input        jump,
    input [63:0] pc_in,
    input [63:0] branch_target,
    input [63:0] jump_target,
    output reg [63:0] pc_out
);
    wire [63:0] pc_plus4 = pc_in + 64'd4;

    // Combinational next-PC logic; the register lives in the top level
    always @* begin
        if (rst)
            pc_out = 64'b0;
        else if (jump)
            pc_out = jump_target;
        else if (branch_taken)
            pc_out = branch_target;
        else
            pc_out = pc_plus4;
    end
endmodule
