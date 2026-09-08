module rv32i_core #(
  parameter int XLEN = 32
) (
  input  logic          clk,
  input  logic          rst_n,

  output logic          imem_valid,
  output logic [XLEN-1:0] imem_addr,
  input  logic [XLEN-1:0] imem_rdata,
  input  logic          imem_ready,

  output logic          dmem_valid,
  output logic          dmem_we,
  output logic [XLEN-1:0] dmem_addr,
  output logic [XLEN-1:0] dmem_wdata,
  output logic [XLEN/8-1:0] dmem_wstrb,
  input  logic [XLEN-1:0] dmem_rdata,
  input  logic          dmem_ready
);

  // Phase-0 architectural shell. Functional pipeline implementation is tracked
  // as incremental milestones in GitHub Issues.
  logic [XLEN-1:0] pc_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      pc_q <= '0;
    else if (imem_ready)
      pc_q <= pc_q + XLEN'(4);
  end

  assign imem_valid = rst_n;
  assign imem_addr  = pc_q;

  assign dmem_valid = 1'b0;
  assign dmem_we    = 1'b0;
  assign dmem_addr  = '0;
  assign dmem_wdata = '0;
  assign dmem_wstrb = '0;

endmodule
