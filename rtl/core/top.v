`include "definitions.vh"
`default_nettype none
`timescale 1ns/1ns

module top (
    input wire clk,
    input wire rst,    
    output wire [`DATA_WIDTH-1:0] debug
);
	
  	wire [`INST_WIDTH-1:0] immediate;
  	wire branch;
    wire [1:0] result_mux;
    wire [5:0] alu_op;
    wire [2:0] branch_op;
    wire mem_write;
    wire alu_src_a;
    wire alu_src_b;
    wire reg_write;
  	wire take;
    wire [`OPCODE-1:0] opcode;
    wire [$clog2(`NUM_REGISTER) - 1: 0] rs1_addr;
    wire [$clog2(`NUM_REGISTER) - 1: 0] rs2_addr;
  	wire [$clog2(`NUM_REGISTER) - 1: 0] rd_addr;
  	wire [`DATA_WIDTH-1:0] rs1;     
    wire [`DATA_WIDTH-1:0] rs2;
    wire [`DATA_WIDTH-1:0] rd;
  	wire [`DATA_WIDTH-1:0] sel_alu_src_a;
    wire [`DATA_WIDTH-1:0] sel_alu_src_b;  	
  	wire [`INST_WIDTH-1:0] inst;
  	wire [`DATA_WIDTH-1:0] data;  	
  
    reg [`DATA_WIDTH-1:0] pc;
  	reg [`DATA_WIDTH-1:0] result;

    always@(posedge clk or posedge rst) begin 
        if(rst) begin
            pc <= 0;
        end else begin
            if(take) begin 
                pc <= rd;
            end else begin
                pc <= pc + 4;
            end
        end
    end
    
    instruction_memory imem (
        .addr(pc),
        .inst(inst)
    );        
    
    data_memory dmem (
        .i_clk(clk),
        .i_we(mem_write),
        .i_addr(rd),
        .i_data(rs2),
        .o_data(data)
    );        

    always @* begin
        case (result_mux)
            2'b00: result = rd;
            2'b01: result = pc + 4;
            2'b10: result = data;
        default: result = 32'b0;
        endcase
    end

    assign debug = result;

    sign_extension sign_ext (
        .i_inst(inst),
        .i_opcode(opcode),
        .immediate_extended(immediate)
    );          

    decoder dec (
        .i_inst(inst),
        .o_branch(branch),
        .o_result_mux(result_mux),
        .o_alu_op(alu_op),
        .o_branch_op(branch_op),
        .o_mem_write(mem_write),
        .o_alu_src_a(alu_src_a),
        .o_alu_src_b(alu_src_b),
        .o_reg_write(reg_write),
        .o_opcode(opcode),
        .o_rs1_addr(rs1_addr),
        .o_rs2_addr(rs2_addr),
        .o_rd_addr(rd_addr)
    );    
    
    register_file reg_file (
        .i_clk(clk),
        .i_rst(rst),
        .i_we(reg_write),
        .i_rd_addr(rd_addr),
        .i_rd(result),
        .i_rs1_addr(rs1_addr),
        .i_rs2_addr(rs2_addr),
        .o_rs1(rs1),
        .o_rs2(rs2)
    );
   
    assign sel_alu_src_a = (alu_src_a == 0) ? rs1 : pc;
    assign sel_alu_src_b = (alu_src_b == 0) ? rs2 : immediate;
    
    alu_unit alu (
        .i_alu_op(alu_op),
        .i_a(sel_alu_src_a),
        .i_b(sel_alu_src_b),
        .o_c(rd)
    );
       
    branch_unit b (
        .i_branch(branch),
        .i_branch_op(branch_op),
        .i_a(rs1),
        .i_b(rs2),
        .o_take(take)
    );

endmodule

module register_file (
    input wire i_clk,
    input wire i_rst,
    input wire i_we,
    input wire [$clog2(`NUM_REGISTER)-1:0] i_rd_addr,
    input wire [`DATA_WIDTH-1:0] i_rd,
    input wire [$clog2(`NUM_REGISTER)-1:0] i_rs1_addr,     
    input wire [$clog2(`NUM_REGISTER)-1:0] i_rs2_addr,
    output wire [`DATA_WIDTH-1:0] o_rs1,     
    output wire [`DATA_WIDTH-1:0] o_rs2
);
  
    reg [`NUM_REGISTER-1:0] registers [`DATA_WIDTH-1:0];
    integer i;

    initial begin
        for (i = 0; i < `NUM_REGISTER; i = i + 1) begin
            registers[i] = 0;  // Initialize each memory location to 0
        end
    end

    always @(posedge i_clk or posedge i_rst) begin        
        if(i_rst) begin        
            for (i = 0; i < `NUM_REGISTER; i = i + 1) begin
                registers[i] <= 0;
        end            
        end else begin
            if(i_we && i_rd_addr != 0) begin
                registers[i_rd_addr] <= i_rd;
            end
        end
    end
  
    // We read every cycle
    assign o_rs1 = registers[i_rs1_addr];
    assign o_rs2 = registers[i_rs2_addr];    
  
endmodule


module branch_unit (
    input wire i_branch,
    input wire [2:0] i_branch_op,
    input wire [`DATA_WIDTH-1:0] i_a,
    input wire [`DATA_WIDTH-1:0] i_b,
    output reg o_take
);
    always @* begin
        o_take = 0;
        if(i_branch) begin
            case (i_branch_op)
                `BRANCH_BEQ: begin //BEQ
                    if(i_a == i_b) begin 
                        o_take = 1;
                    end
                end 
                `BRANCH_BNE : begin //BNE
                    if(i_a != i_b) begin 
                        o_take = 1;
                    end
                end 
                `BRANCH_BLT: begin //BLT
                    if($signed(i_a) < $signed(i_b)) begin 
                        o_take = 1;
                    end
                end 
                `BRANCH_BGE: begin //BGE
                    if($signed(i_a) >= $signed(i_b)) begin 
                        o_take = 1;
                    end
                end 
                `BRANCH_BLTU: begin //BLTU
                    if(i_a < i_b) begin 
                        o_take = 1;
                    end    
                end
                `BRANCH_BGEU: begin //BGEU
                    if(i_a >= i_b) begin 
                        o_take = 1;
                    end
                end 
                `BRANCH_JAL_JALR: begin 
                    o_take = 1;
                end
                default: o_take = 0; 
            endcase
        end
    end
endmodule

module alu_unit (
    input wire [5:0] i_alu_op,
    input wire [`DATA_WIDTH-1:0] i_a,
    input wire [`DATA_WIDTH-1:0] i_b,
    output reg [`DATA_WIDTH-1:0] o_c
);
    always @* begin
        case (i_alu_op)
            `OP_ALU_ADD:    o_c = i_a + i_b;             
            `OP_ALU_SUB:    o_c = i_a - i_b;
            `OP_ALU_AND:    o_c = i_a & i_b;
            `OP_ALU_OR:     o_c = i_a | i_b;
            `OP_ALU_XOR:    o_c = i_a ^ i_b;
            `OP_ALU_SLT:  begin 
                if(i_a < i_b) begin 
                    o_c = 1;
                end else begin
                    o_c = 0;                    
                end
            end
            `OP_ALU_SLTU:  begin 
                if($signed(i_a) < $signed(i_b)) begin 
                    o_c = 1;
                end else begin
                    o_c = 0;
                end
            end
            `OP_ALU_SLL:    o_c = i_a << i_b[4:0];
            `OP_ALU_SRL:    o_c = i_a >> i_b[4:0];
            `OP_ALU_SRA:    o_c = $signed(i_a) >>> i_b[4:0];
            default: o_c = 0;
        endcase
    end
  
endmodule

module sign_extension (
    input wire [`INST_WIDTH-1:0]    i_inst,        
    input wire [`OPCODE-1:0]        i_opcode,
    output reg [`INST_WIDTH-1:0]    immediate_extended    
);
    always @* begin
        case (i_opcode)
            `OP_ALUI, `OP_LOAD, `OP_JALR: begin
                if (i_inst[31] == 1'b1) begin
                    immediate_extended = {20'hFFFFF, i_inst[31:20]};
                end else begin
                    immediate_extended = {20'h00000, i_inst[31:20]};
                end
            end
            `OP_STORE: begin
                if (i_inst[31] == 1'b1) begin
                    immediate_extended = {20'hFFFFF, i_inst[31:25], i_inst[11:7]};
                end else begin
                    immediate_extended = {20'h00000, i_inst[31:25], i_inst[11:7]};
                end
            end
            `OP_LUI, `OP_AUIPC: immediate_extended = {i_inst[31:12], 12'h000};   
            `OP_JAL: begin 
                if (i_inst[31] == 1'b1) begin 
                    immediate_extended = {20'hFFF, i_inst[31], i_inst[19:12],  i_inst[20], i_inst[30:21], 1'b0};
                end else begin
                    immediate_extended = {20'h000, i_inst[31], i_inst[19:12],  i_inst[20], i_inst[30:21], 1'b0};
                end
            end
            `OP_BRANCH: begin 
                if (i_inst[31] == 1'b1) begin 
                    immediate_extended = {20'hFFFFF, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
                end else begin
                    immediate_extended = {20'h00000, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};
                end
            end
            default: immediate_extended = 32'hFFFF_FFFF;
        endcase
    end

endmodule

module decoder (
    input wire [`INST_WIDTH-1:0] i_inst,    
    output wire [`OPCODE-1:0] o_opcode,
    output reg o_branch,
    output reg [1:0] o_result_mux,
    output reg [2:0] o_branch_op,
    output reg o_mem_write,
    output reg o_alu_src_a,
    output reg o_alu_src_b,
    output reg o_reg_write,    
    output reg [5:0] o_alu_op,
    output wire [$clog2(`NUM_REGISTER) - 1: 0] o_rs1_addr,
    output wire [$clog2(`NUM_REGISTER) - 1: 0] o_rs2_addr,
    output wire [$clog2(`NUM_REGISTER) - 1: 0] o_rd_addr    
);

    wire [`OPCODE-1:0] opcode = i_inst[`OPCODE-1:0];
    wire [`FUNCT_7-1:0] funct_7 = i_inst[`INST_WIDTH-1:`INST_WIDTH-`FUNCT_7];
    wire [2:0] funct_3 = i_inst[14:12];

      always @* begin
        o_branch = 0;
        o_result_mux = 2'b00;
        o_alu_op = `OP_ALU_ADD;
        o_branch_op = `BRANCH_BEQ;
        o_mem_write = 0;
        o_alu_src_a = 0;
        o_alu_src_b = 0;
        o_reg_write = 0;
        
        case (opcode)
            `OP_LUI: begin  // LUI
                o_alu_src_b = 1; 
                o_reg_write = 1;
            end
            `OP_AUIPC: begin  // AUIPC
                o_alu_src_a = 1; 
                o_alu_src_b = 1; 
                o_reg_write = 1;
            end
            `OP_JAL: begin  // JAL
                o_reg_write = 1;
                o_branch = 1;
                o_result_mux = 2'b01;
                o_alu_src_a = 1; 
                o_alu_src_b = 1; 
                o_branch_op = `BRANCH_JAL_JALR;
            end
            `OP_JALR : begin  // JALR
                o_reg_write = 1;
                o_branch = 1;
                o_result_mux = 2'b01;
                o_alu_src_b = 1; 
                o_branch_op = `BRANCH_JAL_JALR;
            end
            `OP_BRANCH: begin  // Branch Instructions
                o_branch = 1;
                o_alu_src_a = 1; 
                o_alu_src_b = 1; 
                case (funct_3)
                    `BRANCH_BEQ:    o_branch_op = `BRANCH_BEQ;
                    `BRANCH_BNE:    o_branch_op = `BRANCH_BNE;
                    `BRANCH_BLT:    o_branch_op = `BRANCH_BLT;
                    `BRANCH_BGE:    o_branch_op = `BRANCH_BGE;
                    `BRANCH_BLTU:   o_branch_op = `BRANCH_BLTU;
                    `BRANCH_BGEU:   o_branch_op = `BRANCH_BGEU;
                    default:        o_branch_op = `BRANCH_BEQ;
                endcase
            end
            `OP_LOAD: begin  // Load Instructions
                o_reg_write = 1;
                o_result_mux = 2'b10;
                o_alu_src_b = 1; 
            end
            `OP_STORE: begin  // Store Instructions
                o_mem_write = 1;
                o_alu_src_b = 1; 
            end
            `OP_ALU: begin  // ALU Instructions
                // Implement ADD, SUB, AND, OR, XOR, etc.
                o_reg_write = 1;
                case (funct_3)
                    3'b000: begin
                        if (i_inst[30]) 
                            o_alu_op = `OP_ALU_SUB;
                        else 
                            o_alu_op = `OP_ALU_ADD;
                    end
                    3'b111:    o_alu_op = `OP_ALU_AND;
                    3'b110:     o_alu_op = `OP_ALU_OR;                    
                    3'b100:    o_alu_op = `OP_ALU_XOR;
                    3'b010:    o_alu_op = `OP_ALU_SLT;
                    3'b011:   o_alu_op = `OP_ALU_SLTU;
                    3'b001:    o_alu_op = `OP_ALU_SLL;                    
                    3'b101:  begin 
                        if(i_inst[30])
                            o_alu_op = `OP_ALU_SRA;
                        else
                            o_alu_op = `OP_ALU_SRL;
                    end
                    default:        o_alu_op = `OP_ALU_NOP;                    
                endcase
            end
            `OP_ALUI: begin // Implement ADDI, ANDI, ORI, XORI, etc.                
                //Take IMME. as a source
                o_alu_src_b = 1;
                o_reg_write = 1;
                case (funct_3)
                    3'b000: o_alu_op = `OP_ALU_ADD;     // ADDI operation
                    3'b110: o_alu_op = `OP_ALU_OR;      // ORI operation
                    3'b111: o_alu_op = `OP_ALU_AND;     // ANDI operation                                        
                    3'b100: o_alu_op = `OP_ALU_XOR;     // XORI operation
                    3'b001: o_alu_op = `OP_ALU_SLL;    	// SLLI operation
                    3'b010: o_alu_op = `OP_ALU_SLT;    	// SLTI operation
                    3'b011: o_alu_op = `OP_ALU_SLTU;	// SLTIU operation
                    3'b101: begin
                        if (i_inst[30])
                            o_alu_op = `OP_ALU_SRA;  	// SRAI
                        else
                            o_alu_op = `OP_ALU_SRL;  	// SRLI
                    end
                    default: o_alu_op = `OP_ALU_NOP;
                endcase
            end
            `OP_FENCE: begin  // Fence
                // Implement fence instruction
            end
            `OP_SYSTEM: begin  // System Instructions
                // Implement ECALL, EBREAK, etc.
            end
            default: begin
                // Handle unrecognized opcodes
            end
        endcase
    end
    assign o_opcode = opcode;
    assign o_rd_addr = i_inst[11:7];
    assign o_rs1_addr = `OP_LUI == opcode ? 5'b00000 : i_inst[19:15];
    assign o_rs2_addr = i_inst[24:20];

endmodule

module data_memory #(
    parameter MEM_SIZE = 1024
) (
    input wire i_clk,
    input wire i_we,
    input wire [`DATA_WIDTH-1:0] i_data,
    input wire [$clog2(MEM_SIZE)-1:0] i_addr,
    output wire [`DATA_WIDTH-1:0] o_data
);
    
    reg [`DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            memory[i] = 0;  // Initialize each memory location to 0
        end
          memory[0] = 32'h6c6c6548;
          memory[1] = 32'h6f77206f;
          memory[2] = 32'h21646c72;
          memory[3] = 32'h00000a0d;
          memory[4] = 32'h61686320;
          memory[5] = 32'h74636172;
          memory[6] = 32'h20737265;
          memory[7] = 32'h676e6f6c;
          memory[8] = 32'h00000a0d;
          memory[9] = 32'h00000014;
          memory[10] = 32'h74786554;
          memory[11] = 32'h00000020;
          memory[12] = 32'he0000000;
          memory[13] = 32'he0000004;
          memory[14] = 32'he0000008;
          memory[15] = 32'he000000c;
          memory[16] = 32'he0000010;
          memory[17] = 32'he0000014;
    end

    always @(posedge i_clk) begin
        if (i_we) begin
            memory[i_addr >> 2] <= i_data;
        end
    end
    assign o_data = memory[i_addr >> 2];

endmodule

module instruction_memory #(
    // MEM_SIZE in Words
    parameter MEM_SIZE = 1024
)  (
    input wire [$clog2(MEM_SIZE)-1:0] addr,
    output reg [`INST_WIDTH-1:0] inst
);

    reg [`INST_WIDTH-1:0] memory [0:MEM_SIZE-1];

        initial begin
          memory[0] = 32'hf0000137;
          memory[1] = 32'h00010113;
          memory[2] = 32'h250000ef;
          memory[3] = 32'h00100073;
          memory[4] = 32'hff1ff06f;
          memory[5] = 32'hfe010113;
          memory[6] = 32'h00812e23;
          memory[7] = 32'h02010413;
          memory[8] = 32'hfea42623;
          memory[9] = 32'hfec42783;
          memory[10] = 32'h00179793;
          memory[11] = 32'h00078513;
          memory[12] = 32'h01c12403;
          memory[13] = 32'h02010113;
          memory[14] = 32'h00008067;
          memory[15] = 32'hfd010113;
          memory[16] = 32'h02112623;
          memory[17] = 32'h02812423;
          memory[18] = 32'h03010413;
          memory[19] = 32'h00a00793;
          memory[20] = 32'hfef42623;
          memory[21] = 32'h01400793;
          memory[22] = 32'hfef42423;
          memory[23] = 32'hfec42703;
          memory[24] = 32'hfe842783;
          memory[25] = 32'h00f707b3;
          memory[26] = 32'hfef42223;
          memory[27] = 32'hfec42703;
          memory[28] = 32'hfe842783;
          memory[29] = 32'h40f707b3;
          memory[30] = 32'hfef42023;
          memory[31] = 32'hfe842583;
          memory[32] = 32'hfec42503;
          memory[33] = 32'h208000ef;
          memory[34] = 32'h00050793;
          memory[35] = 32'hfcf42e23;
          memory[36] = 32'hfec42583;
          memory[37] = 32'hfe842503;
          memory[38] = 32'h218000ef;
          memory[39] = 32'h00050793;
          memory[40] = 32'hfcf42c23;
          memory[41] = 32'hfe842783;
          memory[42] = 32'hfec42583;
          memory[43] = 32'h00078513;
          memory[44] = 32'h284000ef;
          memory[45] = 32'h00050793;
          memory[46] = 32'hfcf42a23;
          memory[47] = 32'h00000013;
          memory[48] = 32'h00078513;
          memory[49] = 32'h02c12083;
          memory[50] = 32'h02812403;
          memory[51] = 32'h03010113;
          memory[52] = 32'h00008067;
          memory[53] = 32'hfe010113;
          memory[54] = 32'h00812e23;
          memory[55] = 32'h02010413;
          memory[56] = 32'hfe042623;
          memory[57] = 32'hfe042423;
          memory[58] = 32'h0200006f;
          memory[59] = 32'hfec42703;
          memory[60] = 32'hfe842783;
          memory[61] = 32'h00f707b3;
          memory[62] = 32'hfef42623;
          memory[63] = 32'hfe842783;
          memory[64] = 32'h00178793;
          memory[65] = 32'hfef42423;
          memory[66] = 32'hfe842703;
          memory[67] = 32'h00900793;
          memory[68] = 32'hfce7dee3;
          memory[69] = 32'hfec42703;
          memory[70] = 32'h02800793;
          memory[71] = 32'h00e7da63;
          memory[72] = 32'hfec42783;
          memory[73] = 32'h01478793;
          memory[74] = 32'hfef42623;
          memory[75] = 32'h0100006f;
          memory[76] = 32'hfec42783;
          memory[77] = 32'hfec78793;
          memory[78] = 32'hfef42623;
          memory[79] = 32'h00000013;
          memory[80] = 32'h00078513;
          memory[81] = 32'h01c12403;
          memory[82] = 32'h02010113;
          memory[83] = 32'h00008067;
          memory[84] = 32'hfc010113;
          memory[85] = 32'h02812e23;
          memory[86] = 32'h04010413;
          memory[87] = 32'hfca42623;
          memory[88] = 32'hfcc42783;
          memory[89] = 32'h00279793;
          memory[90] = 32'hfef42623;
          memory[91] = 32'hfcc42783;
          memory[92] = 32'h0027d793;
          memory[93] = 32'hfef42423;
          memory[94] = 32'h00f00793;
          memory[95] = 32'hfef42223;
          memory[96] = 32'hfcc42703;
          memory[97] = 32'hfe442783;
          memory[98] = 32'h00f777b3;
          memory[99] = 32'hfef42023;
          memory[100] = 32'hfcc42783;
          memory[101] = 32'hfff7c793;
          memory[102] = 32'hfcf42e23;
          memory[103] = 32'hfcc42783;
          memory[104] = 32'h00179713;
          memory[105] = 32'hfcc42783;
          memory[106] = 32'h0017d793;
          memory[107] = 32'h00f707b3;
          memory[108] = 32'hfcf42c23;
          memory[109] = 32'hfcc42783;
          memory[110] = 32'h0a57c793;
          memory[111] = 32'hfcf42a23;
          memory[112] = 32'h00000013;
          memory[113] = 32'h03c12403;
          memory[114] = 32'h04010113;
          memory[115] = 32'h00008067;
          memory[116] = 32'hfd010113;
          memory[117] = 32'h02812623;
          memory[118] = 32'h03010413;
          memory[119] = 32'hfca42e23;
          memory[120] = 32'hfdc42783;
          memory[121] = 32'h04f05e63;
          memory[122] = 32'hfe042623;
          memory[123] = 32'h00100793;
          memory[124] = 32'hfef42423;
          memory[125] = 32'h00100793;
          memory[126] = 32'hfef42223;
          memory[127] = 32'h0300006f;
          memory[128] = 32'hfec42703;
          memory[129] = 32'hfe842783;
          memory[130] = 32'h00f707b3;
          memory[131] = 32'hfef42023;
          memory[132] = 32'hfe842783;
          memory[133] = 32'hfef42623;
          memory[134] = 32'hfe042783;
          memory[135] = 32'hfef42423;
          memory[136] = 32'hfe442783;
          memory[137] = 32'h00178793;
          memory[138] = 32'hfef42223;
          memory[139] = 32'hfe442703;
          memory[140] = 32'hfdc42783;
          memory[141] = 32'hfcf746e3;
          memory[142] = 32'hfec42783;
          memory[143] = 32'h00c0006f;
          memory[144] = 32'h00000013;
          memory[145] = 32'h00000013;
          memory[146] = 32'h00078513;
          memory[147] = 32'h02c12403;
          memory[148] = 32'h03010113;
          memory[149] = 32'h00008067;
          memory[150] = 32'hfe010113;
          memory[151] = 32'h00112e23;
          memory[152] = 32'h00812c23;
          memory[153] = 32'h02010413;
          memory[154] = 32'h00500513;
          memory[155] = 32'hf65ff0ef;
          memory[156] = 32'hfea42623;
          memory[157] = 32'h00000793;
          memory[158] = 32'h00078513;
          memory[159] = 32'h01c12083;
          memory[160] = 32'h01812403;
          memory[161] = 32'h02010113;
          memory[162] = 32'h00008067;
          memory[163] = 32'h00050613;
          memory[164] = 32'h00000513;
          memory[165] = 32'h0015f693;
          memory[166] = 32'h00068463;
          memory[167] = 32'h00c50533;
          memory[168] = 32'h0015d593;
          memory[169] = 32'h00161613;
          memory[170] = 32'hfe0596e3;
          memory[171] = 32'h00008067;
          memory[172] = 32'h06054063;
          memory[173] = 32'h0605c663;
          memory[174] = 32'h00058613;
          memory[175] = 32'h00050593;
          memory[176] = 32'hfff00513;
          memory[177] = 32'h02060c63;
          memory[178] = 32'h00100693;
          memory[179] = 32'h00b67a63;
          memory[180] = 32'h00c05863;
          memory[181] = 32'h00161613;
          memory[182] = 32'h00169693;
          memory[183] = 32'hfeb66ae3;
          memory[184] = 32'h00000513;
          memory[185] = 32'h00c5e663;
          memory[186] = 32'h40c585b3;
          memory[187] = 32'h00d56533;
          memory[188] = 32'h0016d693;
          memory[189] = 32'h00165613;
          memory[190] = 32'hfe0696e3;
          memory[191] = 32'h00008067;
          memory[192] = 32'h00008293;
          memory[193] = 32'hfb5ff0ef;
          memory[194] = 32'h00058513;
          memory[195] = 32'h00028067;
          memory[196] = 32'h40a00533;
          memory[197] = 32'h00b04863;
          memory[198] = 32'h40b005b3;
          memory[199] = 32'hf9dff06f;
          memory[200] = 32'h40b005b3;
          memory[201] = 32'h00008293;
          memory[202] = 32'hf91ff0ef;
          memory[203] = 32'h40a00533;
          memory[204] = 32'h00028067;
          memory[205] = 32'h00008293;
          memory[206] = 32'h0005ca63;
          memory[207] = 32'h00054c63;
          memory[208] = 32'hf79ff0ef;
          memory[209] = 32'h00058513;
          memory[210] = 32'h00028067;
          memory[211] = 32'h40b005b3;
          memory[212] = 32'hfe0558e3;
          memory[213] = 32'h40a00533;
          memory[214] = 32'hf61ff0ef;
          memory[215] = 32'h40b00533;
          memory[216] = 32'h00028067;
        end

    always @(addr) begin
        inst = memory[addr >> 2];
    end

endmodule 