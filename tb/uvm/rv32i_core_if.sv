`timescale 1ns/1ps

interface rv32i_core_if(input logic clk);
  logic rst_n;

  logic        imem_valid;
  logic [31:0] imem_addr;
  logic [31:0] imem_rdata;
  logic        imem_ready;

  logic        dmem_valid;
  logic        dmem_we;
  logic [31:0] dmem_addr;
  logic [31:0] dmem_wdata;
  logic [3:0]  dmem_wstrb;
  logic [31:0] dmem_rdata;
  logic        dmem_ready;
endinterface
