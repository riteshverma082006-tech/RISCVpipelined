`timescale 1ns/1ps

module if_id_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] instruction_in,
    input  wire [31:0] pc_in,
    input  wire [31:0] pc_plus4_in,

    output reg  [31:0] instruction_out,
    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus4_out
);
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            instruction_out <= 32'h00000013; // NOP
            pc_out          <= 32'h0;
            pc_plus4_out    <= 32'h0;
        end else if (!stall) begin
            instruction_out <= instruction_in;
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
        end
        // else hold
    end
endmodule
