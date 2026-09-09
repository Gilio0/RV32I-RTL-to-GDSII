`define INST_WIDTH 32

module instruction_memory #(
    // MEM_SIZE in Words
    parameter MEM_SIZE = 1024
)  (
  	input wire [$clog2(MEM_SIZE)-1:0] i_addr,
  	output reg [`INST_WIDTH-1:0] o_inst
);

    reg [`INST_WIDTH-1:0] memory [0:MEM_SIZE-1];

    initial begin
        memory[0] = 32'h00108113;
        memory[1] = 32'h00108193;
        memory[2] = 32'h00310233;
        memory[3] = 32'hfe218ae3;
        memory[4] = 32'h00000000;
    end

 	always @(i_addr) begin
    	o_inst = memory[i_addr >> 2];
    end

endmodule