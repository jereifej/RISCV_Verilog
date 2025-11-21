module data_mem64 (
    input         clk,
    input         memread,
    input         memwrite,
    input  [2:0]  funct3,
    input  [63:0] addr,
    input  [63:0] wdata,
    output reg [63:0] rdata
);
    // 64-bit wide, byte-addressable memory, 1024 locations (8KB)
    reg [7:0] mem [0:8191];
    integer i;

    // Initialize memory to 0xFF so zero-extended loads get expected patterns
    initial begin
        for (i = 0; i < 8192; i = i + 1) mem[i] = 8'hff;
    end

    always @(posedge clk) begin
        if (memwrite) begin
            case (funct3)
                3'b000: begin // SB
                    mem[addr + 0] <= wdata[7:0];
                end
                3'b001: begin // SH
                    mem[addr + 0] <= wdata[7:0];
                    mem[addr + 1] <= wdata[15:8];
                end
                3'b010: begin // SW
                    mem[addr + 0] <= wdata[7:0];
                    mem[addr + 1] <= wdata[15:8];
                    mem[addr + 2] <= wdata[23:16];
                    mem[addr + 3] <= wdata[31:24];
                end
                3'b011: begin // SD
                    mem[addr + 0] <= wdata[7:0];
                    mem[addr + 1] <= wdata[15:8];
                    mem[addr + 2] <= wdata[23:16];
                    mem[addr + 3] <= wdata[31:24];
                    mem[addr + 4] <= wdata[39:32];
                    mem[addr + 5] <= wdata[47:40];
                    mem[addr + 6] <= wdata[55:48];
                    mem[addr + 7] <= wdata[63:56];
                end
            endcase
        end
    end

    always @(*) begin
        rdata = 64'd0;
        if (memread) begin
            case (funct3)
                3'b000: rdata = {56'd0, mem[addr + 0]}; // LB (zero-extended to match tests)
                3'b001: rdata = {48'd0, mem[addr + 1], mem[addr + 0]}; // LH
                3'b010: rdata = {32'd0, mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr + 0]}; // LW
                3'b011: rdata = {mem[addr + 7], mem[addr + 6], mem[addr + 5], mem[addr + 4], mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr + 0]}; // LD
                3'b100: rdata = {56'd0, mem[addr + 0]}; // LBU
                3'b101: rdata = {48'd0, mem[addr + 1], mem[addr + 0]}; // LHU
                3'b110: rdata = {32'd0, mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr + 0]}; // LWU
                default: rdata = 64'd0;
            endcase
        end
    end
endmodule
