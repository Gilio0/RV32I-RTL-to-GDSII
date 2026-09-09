`define DATA_WIDTH 32

module data_memory #(
    parameter MEM_SIZE = 1024
) (
    // INPUT
    input wire i_clk,
    input wire i_we,
    input wire [`DATA_WIDTH-1:0] i_data,
    input wire [$clog2(MEM_SIZE)-1:0] i_addr,
    // OUTPUT
    output wire [`DATA_WIDTH-1:0] o_data
);
  reg [31:0] RAM[MEM_SIZE-1:0];
  assign o_data = RAM[i_addr]; // word aligned
  always @(posedge i_clk)
    if (i_we) RAM[i_addr] <= i_data;
endmodule