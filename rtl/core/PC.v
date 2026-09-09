module PC(
    input wire clk,
    input wire rst,
    input wire [31:0] next_pc,
    output reg [31:0] pc
);
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            pc <= 32'b0; // Reset PC to 0 on reset
        end else begin
            pc <= next_pc; // Update PC with next_pc on clock edge
        end
    end
endmodule