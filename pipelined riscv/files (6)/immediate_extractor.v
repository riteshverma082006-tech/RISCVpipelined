`timescale 1ns/1ps
`include "defines.vh"
// ============================================================
// Immediate_Data_Extractor (ID stage, combinational)
// ============================================================
module immediate_extractor (
    input  wire [31:0] instruction,
    input  wire [2:0]  ImmSrc,
    output reg  [31:0] imm_data
);
    always @(*) begin
        case (ImmSrc)
            `IMM_I: imm_data = {{20{instruction[31]}}, instruction[31:20]};

            `IMM_S: imm_data = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            `IMM_B: imm_data = {{19{instruction[31]}}, instruction[31], instruction[7],
                                 instruction[30:25], instruction[11:8], 1'b0};

            `IMM_U: imm_data = {instruction[31:12], 12'b0};

            `IMM_J: imm_data = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                                 instruction[20], instruction[30:21], 1'b0};

            default: imm_data = 32'h0;
        endcase
    end
endmodule
