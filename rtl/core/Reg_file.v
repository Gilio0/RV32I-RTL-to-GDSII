`define DATA_WIDTH 32
`define NUM_REGISTER 32

module Reg_file (
	// INPUT
    input wire i_clk,
    input wire i_rst,
    input wire i_we,
	input wire [`DATA_WIDTH-1:0] i_rd,
    input wire [$clog2(`NUM_REGISTER)-1:0] i_rd_addr,
    input wire [$clog2(`NUM_REGISTER)-1:0] i_rs1_addr,     
    input wire [$clog2(`NUM_REGISTER)-1:0] i_rs2_addr,
	// OUTPUT
    output reg [`DATA_WIDTH-1:0] o_rs1,     
    output reg [`DATA_WIDTH-1:0] o_rs2
);
    reg [`DATA_WIDTH-1:0] registers [0:`NUM_REGISTER-1];
    integer index;

    always @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            for (index = 0; index < `NUM_REGISTER; index = index + 1) begin
                registers[index] <= {`DATA_WIDTH{1'b0}};
            end
        end
        else begin
            if (i_we && (i_rd_addr != 0)) begin
                registers[i_rd_addr] <= i_rd;
            end
        end
    end

    always @(*) begin
        o_rs1 = (i_rs1_addr == 0) ? 32'b0 : registers[i_rs1_addr];
        o_rs2 = (i_rs2_addr == 0) ? 32'b0 : registers[i_rs2_addr];
    end
endmodule