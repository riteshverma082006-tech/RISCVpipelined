`timescale 1ns/1ps

module id_ex_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        bubble,

    // control in
    input  wire        RegWrite_in, ALUSrc_in, MemRead_in, MemWrite_in,
    input  wire        Branch_in, Jump_in, Jalr_in,
    input  wire [1:0]  ALUSrcA_in, MemtoReg_in, ALUOp_in,

    // data in
    input  wire [31:0] PC_in, PCPlus4_in,
    input  wire [31:0] ReadData1_in, ReadData2_in, ImmData_in,
    input  wire [4:0]  Rs1_in, Rs2_in, Rd_in,
    input  wire [2:0]  Funct3_in,
    input  wire [6:0]  Funct7_in,

    // control out
    output reg         RegWrite_out, ALUSrc_out, MemRead_out, MemWrite_out,
    output reg         Branch_out, Jump_out, Jalr_out,
    output reg  [1:0]  ALUSrcA_out, MemtoReg_out, ALUOp_out,

    // data out
    output reg  [31:0] PC_out, PCPlus4_out,
    output reg  [31:0] ReadData1_out, ReadData2_out, ImmData_out,
    output reg  [4:0]  Rs1_out, Rs2_out, Rd_out,
    output reg  [2:0]  Funct3_out,
    output reg  [6:0]  Funct7_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || bubble) begin
            RegWrite_out  <= 1'b0;
            ALUSrc_out    <= 1'b0;
            MemRead_out   <= 1'b0;
            MemWrite_out  <= 1'b0;
            Branch_out    <= 1'b0;
            Jump_out      <= 1'b0;
            Jalr_out      <= 1'b0;
            ALUSrcA_out   <= 2'b0;
            MemtoReg_out  <= 2'b0;
            ALUOp_out     <= 2'b0;
            PC_out        <= 32'h0;
            PCPlus4_out   <= 32'h0;
            ReadData1_out <= 32'h0;
            ReadData2_out <= 32'h0;
            ImmData_out   <= 32'h0;
            Rs1_out       <= 5'b0;
            Rs2_out       <= 5'b0;
            Rd_out        <= 5'b0;
            Funct3_out    <= 3'b0;
            Funct7_out    <= 7'b0;
        end else begin
            RegWrite_out  <= RegWrite_in;
            ALUSrc_out    <= ALUSrc_in;
            MemRead_out   <= MemRead_in;
            MemWrite_out  <= MemWrite_in;
            Branch_out    <= Branch_in;
            Jump_out      <= Jump_in;
            Jalr_out      <= Jalr_in;
            ALUSrcA_out   <= ALUSrcA_in;
            MemtoReg_out  <= MemtoReg_in;
            ALUOp_out     <= ALUOp_in;
            PC_out        <= PC_in;
            PCPlus4_out   <= PCPlus4_in;
            ReadData1_out <= ReadData1_in;
            ReadData2_out <= ReadData2_in;
            ImmData_out   <= ImmData_in;
            Rs1_out       <= Rs1_in;
            Rs2_out       <= Rs2_in;
            Rd_out        <= Rd_in;
            Funct3_out    <= Funct3_in;
            Funct7_out    <= Funct7_in;
        end
    end
endmodule
