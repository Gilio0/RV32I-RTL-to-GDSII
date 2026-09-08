module rv32i_sva (
  input logic        clk,
  input logic        rst_n,
  input logic [31:0] pc,
  input logic [31:0] rs1_rdata,
  input logic [4:0]  rs1_addr,
  input logic [31:0] rs2_rdata,
  input logic [4:0]  rs2_addr,
  input logic        rd_we,
  input logic [4:0]  rd_addr
);

  // Architectural zero register must always read as zero.
  a_x0_rs1: assert property (@(posedge clk) disable iff (!rst_n)
    (rs1_addr == 5'd0) |-> (rs1_rdata == 32'd0));

  a_x0_rs2: assert property (@(posedge clk) disable iff (!rst_n)
    (rs2_addr == 5'd0) |-> (rs2_rdata == 32'd0));

  // Writes to x0 are architecturally forbidden.
  a_no_x0_write: assert property (@(posedge clk) disable iff (!rst_n)
    rd_we |-> (rd_addr != 5'd0));

endmodule
