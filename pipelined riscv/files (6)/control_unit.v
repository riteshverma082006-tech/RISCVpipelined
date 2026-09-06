`timescale 1ns/1ps
`include "defines.vh"

module control_unit (
    input  wire [6:0] opcode,

    output reg        RegWrite,
    output reg        ALUSrc,      
    output reg [1:0]  ALUSrcA,     
    output reg        MemRead,
    output reg        MemWrite,
    output reg [1:0]  MemtoReg,   
    output reg        Branch,    
    output reg        Jump,       
    output reg        Jalr,       
    output reg [1:0]  ALUOp,
    output reg [2:0]  ImmSrc
);
    always @(*) begin
      
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
                ALUOp    = `ALUOP_ADD; 
            end

            `OP_JALR: begin
                RegWrite = 1'b1;
                Jump     = 1'b1;
                Jalr     = 1'b1;
                ALUSrc   = 1'b1;
                ALUSrcA  = `ASRCA_REG;
                ALUOp    = `ALUOP_ADD;
                MemtoReg = `WB_PC4;
                ImmSrc   = `IMM_I;
            end

            `OP_LUI: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUSrcA  = `ASRCA_ZERO;
                ALUOp    = `ALUOP_ADD;  
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
              
            end
        endcase
    end
endmodule
