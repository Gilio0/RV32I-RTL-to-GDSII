`define DATA_WIDTH 32

// RISC-V ALU Operations
`define OP_ALU_LUI    5'b01101 // LUI
`define OP_ALU_AUIPC  5'b00101 // AUIPC
`define OP_ALU_JAL    5'b11011 // JAL
`define OP_ALU_JALR   5'b11001 // JALR
`define OP_ALU_B      5'b11000 // BEQ + BNE + BLT + BGE + BLTU + BGEU
`define OP_ALU_L      5'b00000 // LB + LH + LW + LBU + LHU
`define OP_ALU_S      5'b01000 // SB + SH + SW
`define OP_ALU_ADDI   5'b00100 // ADDI + SLTI + SLTIU + XORI + ORI + ANDI + SLLI + SRLI + SRAI
`define OP_ALU_ADD    5'b01100 // Add + sub + AND + OR + XOR + SLT + SLTU + SLL + SRL + SRA
`define OP_ALU_F_P    5'b00011 // FENCE + FENCE.TSO + PAUSE
`define OP_ALU_E      5'b11100 // ECALL + EBREAK

module alu (
    // INPUT
    input wire [4:0] i_alu_op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [`DATA_WIDTH-1:0] i_a,
    input wire [`DATA_WIDTH-1:0] i_b,
    // OUTPUT
    output reg [`DATA_WIDTH-1:0] o_c
);

    always @(*) begin
        case (i_alu_op)
            `OP_ALU_ADD: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000) begin
                            o_c = i_a + i_b; // ADD
                        end else if (funct7 == 7'b0100000) begin
                            o_c = i_a - i_b; // SUB
                        end else begin
                            o_c = {`DATA_WIDTH{1'b0}};
                        end
                    end
                    3'b001: o_c = i_a << i_b[4:0]; // SLL
                    3'b010: o_c = ($signed(i_a) < $signed(i_b)) ? 32'b1 : 32'b0; // SLT
                    3'b011: o_c = (i_a < i_b) ? 32'b1 : 32'b0; // SLTU
                    3'b100: o_c = i_a ^ i_b; // XOR
                    3'b101: begin
                        if (funct7 == 7'b0000000) begin
                            o_c = i_a >> i_b[4:0]; // SRL
                        end else if (funct7 == 7'b0100000) begin
                            o_c = $signed(i_a) >>> i_b[4:0]; // SRA
                        end else begin
                            o_c = {`DATA_WIDTH{1'b0}};
                        end
                    end
                    3'b110: o_c = i_a | i_b; // OR
                    3'b111: o_c = i_a & i_b; // AND
                    default: o_c = {`DATA_WIDTH{1'b0}};
                endcase
            end
            `OP_ALU_ADDI: begin
                case (funct3)
                    3'b000: o_c = i_a + i_b; // ADDI
                    3'b010: o_c = ($signed(i_a) < $signed(i_b)) ? 32'b1 : 32'b0; // SLTI
                    3'b011: o_c = (i_a < i_b) ? 32'b1 : 32'b0; // SLTIU
                    3'b100: o_c = i_a ^ i_b; // XORI
                    3'b110: o_c = i_a | i_b; // ORI
                    3'b111: o_c = i_a & i_b; // ANDI
                    3'b001: o_c = i_a << i_b[4:0]; // SLLI
                    3'b101: begin
                        if (funct7 == 7'b0000000) begin
                            o_c = i_a >> i_b[4:0]; // SRLI
                        end else if (funct7 == 7'b0100000) begin
                            o_c = $signed(i_a) >>> i_b[4:0]; // SRAI
                        end else begin
                            o_c = {`DATA_WIDTH{1'b0}};
                        end
                    end
                    default: o_c = {`DATA_WIDTH{1'b0}};
                endcase
            end
            `OP_ALU_S: begin
                case (funct3)
                    3'b000: o_c = i_a + i_b; // SB
                    3'b001: o_c = i_a + i_b; // SH
                    3'b010: o_c = i_a + i_b; // SW
                    default: o_c = {`DATA_WIDTH{1'b0}};
                endcase
            end
            `OP_ALU_L: begin
                case (funct3)
                    3'b000: o_c = i_a + i_b; // LB
                    3'b001: o_c = i_a + i_b; // LH
                    3'b010: o_c = i_a + i_b; // LW
                    3'b100: o_c = i_a + i_b; // LBU
                    3'b101: o_c = i_a + i_b; // LHU
                    default: o_c = {`DATA_WIDTH{1'b0}};
                endcase
            end
            `OP_ALU_B: begin
                case (funct3)
                    3'b000: o_c = (i_a == i_b) ? 32'b1 : 32'b0; // BEQ
                    3'b001: o_c = (i_a != i_b) ? 32'b1 : 32'b0; // BNE
                    3'b100: o_c = ($signed(i_a) < $signed(i_b)) ? 32'b1 : 32'b0; // BLT
                    3'b101: o_c = ($signed(i_a) >= $signed(i_b)) ? 32'b1 : 32'b0; // BGE
                    3'b110: o_c = (i_a < i_b) ? 32'b1 : 32'b0; // BLTU
                    3'b111: o_c = (i_a >= i_b) ? 32'b1 : 32'b0; // BGEU
                    default: o_c = {`DATA_WIDTH{1'b0}};
                endcase
            end
            `OP_ALU_JAL:  o_c = i_a + i_b;
            `OP_ALU_JALR: begin
                o_c = i_a + i_b;
                o_c[0] = 1'b0; // Clear the least significant bit for JALR
            end
            `OP_ALU_AUIPC:o_c = i_a + i_b;
            `OP_ALU_LUI:  o_c = i_b;
            `OP_ALU_F_P: begin
                // FENCE, FENCE.TSO, and PAUSE do not produce an ALU result.
                o_c = {`DATA_WIDTH{1'b0}};
            end
            `OP_ALU_E: begin
                // ECALL and EBREAK are handled as control/trap instructions.
                o_c = {`DATA_WIDTH{1'b0}};
            end
            default:      o_c = {`DATA_WIDTH{1'b0}};
        endcase
    end
endmodule