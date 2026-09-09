`define INST_WIDTH 32

// RISC-V Base Instruction Set Opcodes
`define OPCODE 7
`define OP_LUI     7'b0110111 // Load Upper Immediate - U-Type
`define OP_AUIPC   7'b0010111 // Add Upper Immediate to PC - U-Type
`define OP_JAL     7'b1101111 // Jump and Link - J-Type 
`define OP_BRANCH  7'b1100011 // Branch Instructions (BEQ, BNE, BLT, etc.)- B-Type
`define OP_STORE   7'b0100011 // Store Instructions (SB, SH, SW) - S-Type
`define OP_ALU     7'b0110011 // ALU Instructions (ADD, SUB, AND, OR, XOR, etc.) - R-Type
`define OP_JALR    7'b1100111 // Jump and Link Register - I-Type
`define OP_LOAD    7'b0000011 // Load Instructions (LB, LH, LW, LBU, LHU) - I-Type
`define OP_ALUI    7'b0010011 // ALU Immediate Instructions (ADDI, ANDI, ORI, XORI, etc.) - I-Type

module sign_extension (
    input wire [`INST_WIDTH-1:0]    i_inst,       
    input wire [`OPCODE-1:0]        i_opcode,
    output reg [`INST_WIDTH-1:0]    o_immediate_extended
);
    case (i_opcode)
        `OP_LUI: begin
            o_immediate_extended = {i_inst[31:12], 12'b0}; // U-Type
        end
        `OP_AUIPC: begin
            o_immediate_extended = {i_inst[31:12], 12'b0}; // U-Type
        end
        `OP_JAL: begin
            o_immediate_extended = {{11{i_inst[31]}}, i_inst[31], i_inst[19:12], i_inst[20], i_inst[30:21], 1'b0}; // J-Type
        end
        `OP_BRANCH: begin
            o_immediate_extended = {{19{i_inst[31]}}, i_inst[31], i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0}; // B-Type
        end
        `OP_STORE: begin
            o_immediate_extended = {{20{i_inst[31]}}, i_inst[31:25], i_inst[11:7]}; // S-Type
        end
        `OP_ALU: begin
            o_immediate_extended = 32'b0; // R-Type has no immediate
        end
        `OP_JALR: begin
            o_immediate_extended = {{20{i_inst[31]}}, i_inst[31:20]}; // I-Type
        end
        `OP_LOAD: begin
            o_immediate_extended = {{20{i_inst[31]}}, i_inst[31:20]}; // I-Type
        end
        `OP_ALUI: begin
            o_immediate_extended = {{20{i_inst[31]}}, i_inst[31:20]}; // I-Type
        end
        default: begin
            o_immediate_extended = 32'b0; // Default case
        end
    endcase
endmodule