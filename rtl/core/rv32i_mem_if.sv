interface rv32i_mem_if #(parameter int XLEN = 32) (input logic clk);
  logic              valid;
  logic              we;
  logic [XLEN-1:0]   addr;
  logic [XLEN-1:0]   wdata;
  logic [XLEN/8-1:0] wstrb;
  logic [XLEN-1:0]   rdata;
  logic              ready;
endinterface
