module rv32i_regfile #(
  parameter int XLEN = 32
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic [4:0]       rs1_addr,
  input  logic [4:0]       rs2_addr,
  output logic [XLEN-1:0]  rs1_rdata,
  output logic [XLEN-1:0]  rs2_rdata,
  input  logic             rd_we,
  input  logic [4:0]       rd_addr,
  input  logic [XLEN-1:0]  rd_wdata
);
  logic [XLEN-1:0] regs [0:31];
  integer i;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i++) regs[i] <= '0;
    end else if (rd_we && (rd_addr != 5'd0)) begin
      regs[rd_addr] <= rd_wdata;
    end
  end

  always_comb begin
    rs1_rdata = (rs1_addr == 5'd0) ? '0 : regs[rs1_addr];
    rs2_rdata = (rs2_addr == 5'd0) ? '0 : regs[rs2_addr];
  end
endmodule
