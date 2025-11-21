// Simple instruction memory: 8KB, 32-bit word, 64-bit address
module instruction_memory(
    input  [63:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:2047]; // 8KB / 4B = 2048 words
    wire [10:0] word_addr = addr[12:2];
    assign instr = mem[word_addr];
    // Optionally preload instructions here or via $readmemh
endmodule
