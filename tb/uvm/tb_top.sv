`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import rv32i_uvm_pkg::*;
  `include "uvm_macros.svh"

  logic clk = 1'b0;
  always #5 clk = ~clk;

  rv32i_core_if vif(clk);

  rv32i_core dut (
    .clk(clk),
    .rst_n(vif.rst_n),
    .imem_valid(vif.imem_valid),
    .imem_addr(vif.imem_addr),
    .imem_rdata(vif.imem_rdata),
    .imem_ready(vif.imem_ready),
    .dmem_valid(vif.dmem_valid),
    .dmem_we(vif.dmem_we),
    .dmem_addr(vif.dmem_addr),
    .dmem_wdata(vif.dmem_wdata),
    .dmem_wstrb(vif.dmem_wstrb),
    .dmem_rdata(vif.dmem_rdata),
    .dmem_ready(vif.dmem_ready)
  );

  initial begin
    vif.rst_n       = 1'b0;
    vif.imem_rdata  = 32'h00000013; // NOP (ADDI x0,x0,0)
    vif.imem_ready  = 1'b1;
    vif.dmem_rdata  = '0;
    vif.dmem_ready  = 1'b1;
    repeat (2) @(posedge clk);
    vif.rst_n = 1'b1;
    repeat (10) @(posedge clk);
    $finish;
  end

  initial begin
    uvm_config_db#(virtual rv32i_core_if)::set(null, "*", "vif", vif);
    run_test("rv32i_smoke_test");
  end
endmodule
