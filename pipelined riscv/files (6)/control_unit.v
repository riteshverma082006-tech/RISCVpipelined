`timescale 1ns/1ps
`include "defines.vh"
// ============================================================
// Control_Unit (ID stage, combinational)
// ============================================================
module control_unit (
    input  wire [6:0] opcode,

    output reg        RegWrite,
    output reg        ALUSrc,      // 0 = rs2 (forwarded), 1 = immediate
    output reg [1:0]  ALUSrcA,     // ASRCA_REG / ASRCA_PC / ASRCA_ZERO
    output reg        MemRead,
    output reg        MemWrite,
    output reg [1:0]  MemtoReg,    // WB_ALU / WB_MEM / WB_PC4
    output reg        Branch,      // is a conditional branch
    output reg        Jump,        // is jal or jalr (unconditional)
    output reg        Jalr,        // 1 = jalr (target = rs1+imm), 0 = jal (target = PC+imm)
    output reg [1:0]  ALUOp,
    output reg [2:0]  ImmSrc
);
    always @(*) begin
        // safe defaults (NOP-like)
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        ALUSrcA  = `ASRCA_REG;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = `WB_ALU;
        Branch   = 1'b0;
        Jump     = 1'b0;
        Jalr     = 1'b0;
        ALUOp    = `ALUOP_ADD;
        ImmSrc   = `IMM_I;

        case (opcode)
            `OP_R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = `ALUOP_RFUNCT;
            end

            `OP_I_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = `ALUOP_IFUNCT;
                ImmSrc   = `IMM_I;
            end

            `OP_LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = `ALUOP_ADD;
                MemRead  = 1'b1;
                MemtoReg = `WB_MEM;
                ImmSrc   = `IMM_I;
            end

            `OP_STORE: begin
                ALUSrc   = 1'b1;
                ALUOp    = `ALUOP_ADD;
                MemWrite = 1'b1;
                ImmSrc   = `IMM_S;
            end

            `OP_BRANCH: begin
                ALUSrc   = 1'b0;
                ALUOp    = `ALUOP_SUB;
                Branch   = 1'b1;
                ImmSrc   = `IMM_B;
            end

            `OP_JAL: begin
                RegWrite = 1'b1;
                Jump     = 1'b1;
                Jalr     = 1'b0;
                MemtoReg = `WB_PC4;
                ImmSrc   = `IMM_J;
                ALUSrcA  = `ASRCA_PC;
                ALUOp    = `ALUOP_ADD; // unused result path for jal (target via PC-adder)
            end

            `OP_JALR: begin
                RegWrite = 1'b1;
                Jump     = 1'b1;
                Jalr     = 1'b1;
                ALUSrc   = 1'b1;
                ALUSrcA  = `ASRCA_REG;
                ALUOp    = `ALUOP_ADD;  // ALU computes rs1+imm -> jump target
                MemtoReg = `WB_PC4;
                ImmSrc   = `IMM_I;
            end

            `OP_LUI: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUSrcA  = `ASRCA_ZERO;
                ALUOp    = `ALUOP_ADD;  // result = 0 + imm
                ImmSrc   = `IMM_U;
            end

            `OP_AUIPC: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUSrcA  = `ASRCA_PC;
                ALUOp    = `ALUOP_ADD;  // result = PC + imm
                ImmSrc   = `IMM_U;
            end

            default: begin
                // NOP / unsupported -> no side effects
            end
        endcase
    end
endmodule
