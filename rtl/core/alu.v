`define DATA_WIDTH 32

// RISC-V ALU Operations
`define OP_ALU_LUI    7'b0110111 // LUI
`define OP_ALU_AUIPC  7'b0010111 // AUIPC
`define OP_ALU_JAL    7'b1101111 // JAL
`define OP_ALU_JALR   7'b1100111 // JALR
`define OP_ALU_BEQ    7'b1100011 // BEQ + BNE + BLT + BGE + BLTU + BGEU
`define OP_ALU_BNE    7'b0000011 // LB + LH + LW + LBU + LHU
`define OP_ALU_JAL    7'b0100011 // SB + SH + SW
`define OP_ALU_JAL    7'b0010011 // ADDI + SLTI + SLTIU + XORI + ORI + ANDI + SLLI + SRLI + SRAI

`define OP_ALU_ADD    7'b0110011 // Add + sub + AND + OR + XOR + SLT + SLTU + SLL + SRL + SRA
`define OP_ALU_SUB    7'b0001111 // FENCE + FENCE.TSO + PAUSE
`define OP_ALU_AND    7'b1110011 // ECALL + EBREAK


// Instructions that reuse an existing ALU operation
`define OP_ALU_ADDI   `OP_ALU_ADD  // Add Immediate
`define OP_ALU_SLTI   `OP_ALU_SLT  // Set Less Than Immediate
`define OP_ALU_SLTIU  `OP_ALU_SLTU // Set Less Than Immediate Unsigned
`define OP_ALU_XORI   `OP_ALU_XOR  // XOR Immediate
`define OP_ALU_ORI    `OP_ALU_OR   // OR Immediate
`define OP_ALU_ANDI   `OP_ALU_AND  // AND Immediate
`define OP_ALU_SLLI   `OP_ALU_SLL  // Shift Left Logical Immediate
`define OP_ALU_SRLI   `OP_ALU_SRL  // Shift Right Logical Immediate
`define OP_ALU_SRAI   `OP_ALU_SRA  // Shift Right Arithmetic Immediate
`define OP_ALU_AUIPC  `OP_ALU_ADD  // Add Upper Immediate to PC
`define OP_ALU_LOAD   `OP_ALU_ADD  // Load address calculation
`define OP_ALU_STORE  `OP_ALU_ADD  // Store address calculation
`define OP_ALU_JAL    `OP_ALU_ADD  // JAL target/link calculation
`define OP_ALU_JALR   `OP_ALU_ADD  // JALR target/link calculation

module alu (
    // INPUT
    input wire [5:0] i_alu_op,
    input wire [`DATA_WIDTH-1:0] i_a,
    input wire [`DATA_WIDTH-1:0] i_b,
    // OUTPUT
    output reg [`DATA_WIDTH-1:0] o_c
);

    always @(*) begin
        case (i_alu_op)
            `OP_ALU_ADD:  o_c = i_a + i_b;
            `OP_ALU_SUB:  o_c = i_a - i_b;
            `OP_ALU_AND:  o_c = i_a & i_b;
            `OP_ALU_OR:   o_c = i_a | i_b;
            `OP_ALU_XOR:  o_c = i_a ^ i_b;
            `OP_ALU_SLT:  o_c = ($signed(i_a) < $signed(i_b)) ? 32'b1 : 32'b0;
            `OP_ALU_SLTU: o_c = (i_a < i_b) ? 32'b1 : 32'b0;
            `OP_ALU_SLL:  o_c = i_a << i_b[4:0];
            `OP_ALU_SRL:  o_c = i_a >> i_b[4:0];
            `OP_ALU_SRA:  o_c = $signed(i_a) >>> i_b[4:0];
            `OP_ALU_LUI:  o_c = i_b;
            default:      o_c = {`DATA_WIDTH{1'b0}};
        endcase
    end
endmodule