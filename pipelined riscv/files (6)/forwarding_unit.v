`timescale 1ns/1ps
`include "defines.vh"
// ============================================================
// Forwarding_Unit (EX stage, combinational)
//   Prioritizes EX/MEM (most recent) over MEM/WB.
// ============================================================
module forwarding_unit (
    input  wire [4:0] ID_EX_Rs1,
    input  wire [4:0] ID_EX_Rs2,

    input  wire [4:0] EX_MEM_Rd,
    input  wire       EX_MEM_RegWrite,

    input  wire [4:0] MEM_WB_Rd,
    input  wire       MEM_WB_RegWrite,

    output reg [1:0]  ForwardA,
    output reg [1:0]  ForwardB
);
    always @(*) begin
        // ---- ForwardA (rs1) ----
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs1))
            ForwardA = `FWD_EXMEM;
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs1))
            ForwardA = `FWD_MEMWB;
        else
            ForwardA = `FWD_NONE;

        // ---- ForwardB (rs2) ----
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs2))
            ForwardB = `FWD_EXMEM;
        else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs2))
            ForwardB = `FWD_MEMWB;
        else
            ForwardB = `FWD_NONE;
    end
endmodule
