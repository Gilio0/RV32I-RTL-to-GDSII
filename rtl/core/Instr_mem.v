`define INST_WIDTH 32

module instruction_memory #(
    parameter MEM_SIZE = 1024 
) (
    // INPUT
    input wire clk,
    input wire [$clog2(MEM_SIZE)-1:0] addr,
    // OUTPUT
    output reg [`INST_WIDTH-1:0] inst
);

  reg [31:0] RAM[MEM_SIZE-1:0];
  // initial
  // $readmemh("memfile.dat", RAM);
  assign inst = RAM[addr]; // word aligned

endmodule