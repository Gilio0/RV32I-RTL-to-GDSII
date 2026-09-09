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
  
endmodule
