module regfile64 (
    input         clk,
    input         rst,
    input         we,
    input  [4:0]  Rw,   // Write register address
    input  [4:0]  Ra,   // Read register A address
    input  [4:0]  Rb,   // Read register B address
    input  [63:0] W,    // Write data
    output [63:0] A,    // Read data A
    output [63:0] B,    // Read data B
    output [63:0] debug_regs [0:31] // Debug port for all registers
);
    wire [63:0] q[31:0];
    genvar i;
    // Generate 32 registers
    generate
        for (i = 0; i < 32; i = i + 1) begin : regs
            if (i == 0) begin
                // x0 is always zero
                assign q[i] = 64'd0;
            end else begin
                reg64 u_reg (
                    .clk(clk),
                    .rst(rst),
                    .we(we && (Rw == i)),
                    .d(W),
                    .q(q[i])
                );
            end
        end
    endgenerate
    // Read ports
    assign A = q[Ra];
    assign B = q[Rb];

    // Debug port: expose all registers
    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin : debug
            assign debug_regs[j] = q[j];
        end
    endgenerate
endmodule
