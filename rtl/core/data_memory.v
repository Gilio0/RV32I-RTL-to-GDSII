`define DATA_WIDTH 32

module Data_mem #(
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
    reg [`DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];
    integer i;
    assign o_data = memory[i_addr]; // word aligned
    always @(posedge i_clk)
        if (i_we) memory[i_addr] <= i_data;    

    initial begin
        memory[0] = 32'h00000000;
        memory[1] = 32'h00000001;
        memory[2] = 32'h00000002;
        memory[3] = 32'h00000003;
        memory[4] = 32'h00000004;
    end

endmodule