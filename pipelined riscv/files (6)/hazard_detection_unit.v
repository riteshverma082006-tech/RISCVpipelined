`timescale 1ns/1ps
// ============================================================
// Hazard_Detection_Unit (combinational, straddles ID/EX boundary)
//   Detects: load-use hazard -> stall PC & IF/ID one cycle,
//   bubble ID/EX (turn its control signals to 0).
// ============================================================
module hazard_detection_unit (
    input  wire        ID_EX_MemRead,
    input  wire [4:0]  ID_EX_Rd,
    input  wire [4:0]  IF_ID_Rs1,
    input  wire [4:0]  IF_ID_Rs2,

    output wire        PCWrite,      // 0 -> stall PC
    output wire        IF_ID_Write,  // used as "not stall" for IF/ID (we reuse stall signal instead)
    output wire        stall,        // 1 -> stall IF/ID, bubble ID/EX
    output wire        bubble
);
    wire load_use_hazard;

    assign load_use_hazard = ID_EX_MemRead &&
                              (ID_EX_Rd != 5'd0) &&
                              ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2));

    assign stall       = load_use_hazard;
    assign bubble      = load_use_hazard;
    assign PCWrite      = ~load_use_hazard;
    assign IF_ID_Write  = ~load_use_hazard;

endmodule
