`timescale 1ns/1ps
`include "defines.vh"

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [6:0] Operation,   
    input  wire [2:0] Funct,      
    output reg  [3:0] ALUCtrl
);
    wire is_alt = Operation[5]; 

    always @(*) begin
        case (ALUOp)
            `ALUOP_ADD: ALUCtrl = `ALU_ADD;
            `ALUOP_SUB: ALUCtrl = `ALU_SUB;

            `ALUOP_RFUNCT: begin
                case (Funct)
                    3'b000: ALUCtrl = is_alt ? `ALU_SUB : `ALU_ADD;
                    3'b001: ALUCtrl = `ALU_SLL;
                    3'b010: ALUCtrl = `ALU_SLT;
                    3'b011: ALUCtrl = `ALU_SLTU;
                    3'b100: ALUCtrl = `ALU_XOR;
                    3'b101: ALUCtrl = is_alt ? `ALU_SRA : `ALU_SRL;
                    3'b110: ALUCtrl = `ALU_OR;
                    3'b111: ALUCtrl = `ALU_AND;
                    default: ALUCtrl = `ALU_ADD;
                endcase
            end

            `ALUOP_IFUNCT: begin
                case (Funct)
                    3'b000: ALUCtrl = `ALU_ADD;   // addi
                    3'b001: ALUCtrl = `ALU_SLL;   // slli
                    3'b010: ALUCtrl = `ALU_SLT;   // slti
                    3'b011: ALUCtrl = `ALU_SLTU;  // sltiu
                    3'b100: ALUCtrl = `ALU_XOR;   // xori
                    3'b101: ALUCtrl = is_alt ? `ALU_SRA : `ALU_SRL; // srai/srli
                    3'b110: ALUCtrl = `ALU_OR;    // ori
                    3'b111: ALUCtrl = `ALU_AND;   // andi
                    default: ALUCtrl = `ALU_ADD;
                endcase
            end

            default: ALUCtrl = `ALU_ADD;
        endcase
    end
endmodule
