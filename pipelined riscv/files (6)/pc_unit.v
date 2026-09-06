`timescale 1ns/1ps

module pc_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        PCWrite,     // 0 = stall (hold PC), from Hazard Unit
    input  wire [31:0] PC_in,
    output reg  [31:0] PC_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_out <= 32'h0;
        else if (PCWrite)
            PC_out <= PC_in;
    end
endmodule

module adder #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] out
);
    assign out = a + b;
endmodule
