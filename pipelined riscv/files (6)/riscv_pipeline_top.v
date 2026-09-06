`timescale 1ns/1ps
`include "defines.vh"
// ============================================================================
// riscv_pipeline_top
//   5-stage RV32I pipeline: IF -> ID -> EX -> MEM -> WB
//   Full forwarding (EX-stage), load-use stall, branch/jump resolved in EX
//   with a 2-instruction flush (IF/ID + ID/EX).
// ============================================================================
module riscv_pipeline_top #(
    parameter IMEM_INIT_FILE = ""
)(
    input  wire clk,
    input  wire reset
);

    // ============================ IF stage =================================
    wire [31:0] pc_out;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;
    wire        PCWrite;
    wire [1:0]  PCSrc;          // driven from EX stage
    wire [31:0] branch_target;  // PC(ID/EX)+imm
    wire [31:0] jalr_target;    // ALU result with LSB cleared
    wire [31:0] instruction_if;
    wire        flush_if_id, stall_if_id;

    pc_register u_pc (
        .clk(clk), .reset(reset), .PCWrite(PCWrite),
        .PC_in(pc_next), .PC_out(pc_out)
    );

    adder u_pc_adder (.a(pc_out), .b(32'd4), .out(pc_plus4));

    assign pc_next = (PCSrc == `PC_BRANCH) ? branch_target :
                      (PCSrc == `PC_JALR)  ? jalr_target   :
                      pc_plus4;

    instruction_memory #(.INIT_FILE(IMEM_INIT_FILE)) u_imem (
        .Inst_Addr(pc_out), .instruction(instruction_if)
    );

    // flush IF/ID whenever a branch/jump is resolved taken in EX
    assign flush_if_id = (PCSrc != `PC_PLUS4);

    // ============================ IF/ID =====================================
    wire [31:0] instr_id, pc_id, pcplus4_id;

    if_id_register u_if_id (
        .clk(clk), .reset(reset), .stall(stall_if_id), .flush(flush_if_id),
        .instruction_in(instruction_if), .pc_in(pc_out), .pc_plus4_in(pc_plus4),
        .instruction_out(instr_id), .pc_out(pc_id), .pc_plus4_out(pcplus4_id)
    );

    // ============================ ID stage ==================================
    wire [6:0] opcode_id;
    wire [4:0] rs1_id, rs2_id, rd_id;
    wire [2:0] funct3_id;
    wire [6:0] funct7_id;

    instruction_parser u_parser (
        .instruction(instr_id),
        .opcode(opcode_id), .rs1(rs1_id), .rs2(rs2_id), .rd(rd_id),
        .funct3(funct3_id), .funct7(funct7_id)
    );

    wire RegWrite_id, ALUSrc_id, MemRead_id, MemWrite_id, Branch_id, Jump_id, Jalr_id;
    wire [1:0] ALUSrcA_id, MemtoReg_id, ALUOp_id;
    wire [2:0] ImmSrc_id;

    control_unit u_ctrl (
        .opcode(opcode_id),
        .RegWrite(RegWrite_id), .ALUSrc(ALUSrc_id), .ALUSrcA(ALUSrcA_id),
        .MemRead(MemRead_id), .MemWrite(MemWrite_id), .MemtoReg(MemtoReg_id),
        .Branch(Branch_id), .Jump(Jump_id), .Jalr(Jalr_id),
        .ALUOp(ALUOp_id), .ImmSrc(ImmSrc_id)
    );

    wire [31:0] read_data1_id, read_data2_id;
    wire        RegWrite_wb; // from WB stage (forward decl)
    wire [4:0]  rd_wb;
    wire [31:0] wb_data;

    register_file u_regfile (
        .clk(clk), .reset(reset),
        .RegWrite(RegWrite_wb), .RS1(rs1_id), .RS2(rs2_id), .RD(rd_wb),
        .WriteData(wb_data),
        .ReadData1(read_data1_id), .ReadData2(read_data2_id)
    );

    wire [31:0] imm_id;
    immediate_extractor u_immext (
        .instruction(instr_id), .ImmSrc(ImmSrc_id), .imm_data(imm_id)
    );

    // ---- Hazard detection (load-use) ----
    wire ID_EX_MemRead_probe;
    wire [4:0] ID_EX_Rd_probe;
    wire bubble_from_hazard;
    wire bubble_id_ex;

    hazard_detection_unit u_hazard (
        .ID_EX_MemRead(ID_EX_MemRead_probe), .ID_EX_Rd(ID_EX_Rd_probe),
        .IF_ID_Rs1(rs1_id), .IF_ID_Rs2(rs2_id),
        .PCWrite(PCWrite), .IF_ID_Write(), .stall(stall_if_id), .bubble(bubble_from_hazard)
    );

    // The instruction currently in ID (about to latch into ID/EX) must also be
    // squashed the same cycle a branch/jump resolves taken in EX - otherwise
    // the wrong-path instruction fetched right after the branch would execute.
    assign bubble_id_ex = bubble_from_hazard | flush_if_id;

    // ============================ ID/EX =====================================
    wire RegWrite_ex, ALUSrc_ex, MemRead_ex, MemWrite_ex, Branch_ex, Jump_ex, Jalr_ex;
    wire [1:0] ALUSrcA_ex, MemtoReg_ex, ALUOp_ex;
    wire [31:0] pc_ex, pcplus4_ex, read_data1_ex, read_data2_ex, imm_ex;
    wire [4:0] rs1_ex, rs2_ex, rd_ex;
    wire [2:0] funct3_ex;
    wire [6:0] funct7_ex;

    id_ex_register u_id_ex (
        .clk(clk), .reset(reset), .bubble(bubble_id_ex),
        .RegWrite_in(RegWrite_id), .ALUSrc_in(ALUSrc_id), .MemRead_in(MemRead_id),
        .MemWrite_in(MemWrite_id), .Branch_in(Branch_id), .Jump_in(Jump_id), .Jalr_in(Jalr_id),
        .ALUSrcA_in(ALUSrcA_id), .MemtoReg_in(MemtoReg_id), .ALUOp_in(ALUOp_id),
        .PC_in(pc_id), .PCPlus4_in(pcplus4_id),
        .ReadData1_in(read_data1_id), .ReadData2_in(read_data2_id), .ImmData_in(imm_id),
        .Rs1_in(rs1_id), .Rs2_in(rs2_id), .Rd_in(rd_id),
        .Funct3_in(funct3_id), .Funct7_in(funct7_id),

        .RegWrite_out(RegWrite_ex), .ALUSrc_out(ALUSrc_ex), .MemRead_out(MemRead_ex),
        .MemWrite_out(MemWrite_ex), .Branch_out(Branch_ex), .Jump_out(Jump_ex), .Jalr_out(Jalr_ex),
        .ALUSrcA_out(ALUSrcA_ex), .MemtoReg_out(MemtoReg_ex), .ALUOp_out(ALUOp_ex),
        .PC_out(pc_ex), .PCPlus4_out(pcplus4_ex),
        .ReadData1_out(read_data1_ex), .ReadData2_out(read_data2_ex), .ImmData_out(imm_ex),
        .Rs1_out(rs1_ex), .Rs2_out(rs2_ex), .Rd_out(rd_ex),
        .Funct3_out(funct3_ex), .Funct7_out(funct7_ex)
    );

    assign ID_EX_MemRead_probe = MemRead_ex;
    assign ID_EX_Rd_probe      = rd_ex;

    // ============================ EX stage ==================================
    wire [31:0] ex_mem_aluresult_probe, mem_wb_aluresult_probe, mem_wb_wbdata_probe;
    wire        ex_mem_regwrite_probe, mem_wb_regwrite_probe;
    wire [4:0]  ex_mem_rd_probe, mem_wb_rd_probe;
    wire [1:0]  ForwardA, ForwardB;

    forwarding_unit u_fwd (
        .ID_EX_Rs1(rs1_ex), .ID_EX_Rs2(rs2_ex),
        .EX_MEM_Rd(ex_mem_rd_probe), .EX_MEM_RegWrite(ex_mem_regwrite_probe),
        .MEM_WB_Rd(mem_wb_rd_probe), .MEM_WB_RegWrite(mem_wb_regwrite_probe),
        .ForwardA(ForwardA), .ForwardB(ForwardB)
    );

    wire [31:0] fwd_rs1 = (ForwardA == `FWD_EXMEM) ? ex_mem_aluresult_probe :
                          (ForwardA == `FWD_MEMWB) ? wb_data :
                          read_data1_ex;

    wire [31:0] fwd_rs2 = (ForwardB == `FWD_EXMEM) ? ex_mem_aluresult_probe :
                          (ForwardB == `FWD_MEMWB) ? wb_data :
                          read_data2_ex;

    // ALU operand A select
    wire [31:0] alu_a = (ALUSrcA_ex == `ASRCA_PC)   ? pc_ex :
                         (ALUSrcA_ex == `ASRCA_ZERO) ? 32'h0 :
                         fwd_rs1;

    // ALU operand B select
    wire [31:0] alu_b = ALUSrc_ex ? imm_ex : fwd_rs2;

    wire [3:0] alu_ctrl;
    alu_control u_alu_ctrl (
        .ALUOp(ALUOp_ex), .Operation(funct7_ex), .Funct(funct3_ex), .ALUCtrl(alu_ctrl)
    );

    wire [31:0] alu_result;
    wire alu_zero, cmp_eq, cmp_lt, cmp_ltu;
    alu u_alu (
        .a(alu_a), .b(alu_b), .ALUCtrl(alu_ctrl),
        .Result(alu_result), .Zero(alu_zero), .eq(cmp_eq), .lt(cmp_lt), .ltu(cmp_ltu)
    );

    // branch/jump target adder: PC(ID/EX) + imm
    adder u_branch_adder (.a(pc_ex), .b(imm_ex), .out(branch_target));
    // jalr target: (rs1+imm) with LSB cleared -> alu_result already = rs1+imm for jalr
    assign jalr_target = {alu_result[31:1], 1'b0};

    branch_unit u_branch (
        .Branch(Branch_ex), .Jump(Jump_ex), .Jalr(Jalr_ex), .funct3(funct3_ex),
        .eq(cmp_eq), .lt(cmp_lt), .ltu(cmp_ltu),
        .branch_taken(), .PCSrc(PCSrc)
    );

    // ============================ EX/MEM ====================================
    wire RegWrite_mem, MemRead_mem, MemWrite_mem;
    wire [1:0] MemtoReg_mem;
    wire [31:0] aluresult_mem, writedata_mem, pcplus4_mem;
    wire [4:0] rd_mem;
    wire [2:0] funct3_mem;

    ex_mem_register u_ex_mem (
        .clk(clk), .reset(reset),
        .RegWrite_in(RegWrite_ex), .MemRead_in(MemRead_ex), .MemWrite_in(MemWrite_ex),
        .MemtoReg_in(MemtoReg_ex), .ALUResult_in(alu_result), .WriteData_in(fwd_rs2),
        .PCPlus4_in(pcplus4_ex), .Rd_in(rd_ex), .Funct3_in(funct3_ex),

        .RegWrite_out(RegWrite_mem), .MemRead_out(MemRead_mem), .MemWrite_out(MemWrite_mem),
        .MemtoReg_out(MemtoReg_mem), .ALUResult_out(aluresult_mem), .WriteData_out(writedata_mem),
        .PCPlus4_out(pcplus4_mem), .Rd_out(rd_mem), .Funct3_out(funct3_mem)
    );

    assign ex_mem_aluresult_probe = aluresult_mem;
    assign ex_mem_regwrite_probe  = RegWrite_mem;
    assign ex_mem_rd_probe        = rd_mem;

    // ============================ MEM stage =================================
    wire [31:0] read_data_mem;
    data_memory u_dmem (
        .clk(clk), .MemRead(MemRead_mem), .MemWrite(MemWrite_mem),
        .Mem_Addr(aluresult_mem), .Write_Data(writedata_mem), .funct3(funct3_mem),
        .Read_Data(read_data_mem)
    );

    // ============================ MEM/WB ====================================
    wire [1:0] MemtoReg_wb2;
    wire [31:0] aluresult_wb, readdata_wb, pcplus4_wb;

    mem_wb_register u_mem_wb (
        .clk(clk), .reset(reset),
        .RegWrite_in(RegWrite_mem), .MemtoReg_in(MemtoReg_mem),
        .ALUResult_in(aluresult_mem), .ReadData_in(read_data_mem),
        .PCPlus4_in(pcplus4_mem), .Rd_in(rd_mem),

        .RegWrite_out(RegWrite_wb), .MemtoReg_out(MemtoReg_wb2),
        .ALUResult_out(aluresult_wb), .ReadData_out(readdata_wb),
        .PCPlus4_out(pcplus4_wb), .Rd_out(rd_wb)
    );

    assign mem_wb_aluresult_probe = aluresult_wb;
    assign mem_wb_regwrite_probe  = RegWrite_wb;
    assign mem_wb_rd_probe        = rd_wb;

    // ============================ WB stage ==================================
    assign wb_data = (MemtoReg_wb2 == `WB_MEM) ? readdata_wb :
                      (MemtoReg_wb2 == `WB_PC4) ? pcplus4_wb :
                      aluresult_wb;

endmodule
