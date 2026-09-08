`timescale 1ns/1ps

module tb_rtl_smoke;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic imem_valid, imem_ready;
  logic [31:0] imem_addr, imem_rdata;
  logic dmem_valid, dmem_we, dmem_ready;
  logic [31:0] dmem_addr, dmem_wdata, dmem_rdata;
  logic [3:0] dmem_wstrb;

  always #5 clk = ~clk;

  rv32i_core dut (
    .clk(clk), .rst_n(rst_n),
    .imem_valid(imem_valid), .imem_addr(imem_addr),
    .imem_rdata(imem_rdata), .imem_ready(imem_ready),
    .dmem_valid(dmem_valid), .dmem_we(dmem_we),
    .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata),
    .dmem_wstrb(dmem_wstrb), .dmem_rdata(dmem_rdata),
    .dmem_ready(dmem_ready)
  );

  initial begin
    imem_rdata = 32'h00000013;
    imem_ready = 1'b1;
    dmem_rdata = '0;
    dmem_ready = 1'b1;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    repeat (5) @(posedge clk);
    if (imem_addr !== 32'd20) $fatal(1, "Unexpected PC: %h", imem_addr);
    $display("RTL smoke test PASSED");
    $finish;
  end
endmodule
