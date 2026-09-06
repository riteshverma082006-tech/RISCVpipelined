`timescale 1ns/1ps

module ex_mem_register (
    input  wire        clk,
    input  wire        reset,

    input  wire        RegWrite_in, MemRead_in, MemWrite_in,
    input  wire [1:0]  MemtoReg_in,
    input  wire [31:0] ALUResult_in,
    input  wire [31:0] WriteData_in,   
    input  wire [31:0] PCPlus4_in,
    input  wire [4:0]  Rd_in,
    input  wire [2:0]  Funct3_in,     

    output reg          RegWrite_out, MemRead_out, MemWrite_out,
    output reg  [1:0]   MemtoReg_out,
    output reg  [31:0]  ALUResult_out,
    output reg  [31:0]  WriteData_out,
    output reg  [31:0]  PCPlus4_out,
    output reg  [4:0]   Rd_out,
    output reg  [2:0]   Funct3_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWrite_out  <= 1'b0;
            MemRead_out   <= 1'b0;
            MemWrite_out  <= 1'b0;
            MemtoReg_out  <= 2'b0;
            ALUResult_out <= 32'h0;
            WriteData_out <= 32'h0;
            PCPlus4_out   <= 32'h0;
            Rd_out        <= 5'b0;
            Funct3_out    <= 3'b0;
        end else begin
            RegWrite_out  <= RegWrite_in;
            MemRead_out   <= MemRead_in;
            MemWrite_out  <= MemWrite_in;
            MemtoReg_out  <= MemtoReg_in;
            ALUResult_out <= ALUResult_in;
            WriteData_out <= WriteData_in;
            PCPlus4_out   <= PCPlus4_in;
            Rd_out        <= Rd_in;
            Funct3_out    <= Funct3_in;
        end
    end
endmodule
