module reg64 (
    input         clk,
    input         rst,
    input         we,
    input  [63:0] d,
    output reg [63:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 64'd0;
        else if (we)
            q <= d;
    end
endmodule