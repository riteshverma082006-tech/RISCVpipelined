`timescale 1ns/1ps
`include "defines.vh"
// ============================================================
// Branch_Unit (EX stage, combinational)
//   Determines branch_taken from funct3 + comparator flags, and
//   builds the overall PCSrc select for the fetch-stage mux.
// ============================================================
module branch_unit (
    input  wire       Branch,
    input  wire       Jump,
    input  wire       Jalr,
    input  wire [2:0] funct3,
    input  wire       eq,
    input  wire       lt,
    input  wire       ltu,
    output reg        branch_taken,
    output reg [1:0]  PCSrc
);
    always @(*) begin
        branch_taken = 1'b0;
        if (Branch) begin
            case (funct3)
                3'b000: branch_taken = eq;        // beq
                3'b001: branch_taken = ~eq;       // bne
                3'b100: branch_taken = lt;        // blt
                3'b101: branch_taken = ~lt;       // bge
                3'b110: branch_taken = ltu;       // bltu
                3'b111: branch_taken = ~ltu;      // bgeu
                default: branch_taken = 1'b0;
            endcase
        end

        if (Jump && Jalr)
            PCSrc = `PC_JALR;
        else if (Jump || (Branch && branch_taken))
            PCSrc = `PC_BRANCH;
        else
            PCSrc = `PC_PLUS4;
    end
endmodule
