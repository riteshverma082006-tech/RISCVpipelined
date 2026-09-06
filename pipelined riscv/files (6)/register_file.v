`timescale 1ns/1ps

module register_file (
    input  wire        clk,
    input  wire        reset,
    input  wire        RegWrite,
    input  wire [4:0]  RS1,
    input  wire [4:0]  RS2,
    input  wire [4:0]  RD,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);
    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'h0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'h0;
        end else if (RegWrite && RD != 5'd0) begin
            regs[RD] <= WriteData;
        end
    end

    // write-first read 
    assign ReadData1 = (RS1 == 5'd0) ? 32'h0 :
                        (RegWrite && RD == RS1 && RD != 5'd0) ? WriteData : regs[RS1];
    assign ReadData2 = (RS2 == 5'd0) ? 32'h0 :
                        (RegWrite && RD == RS2 && RD != 5'd0) ? WriteData : regs[RS2];

endmodule
