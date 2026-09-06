`timescale 1ns/1ps
`include "defines.vh"
module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  ALUCtrl,
    output reg  [31:0] Result,
    output wire         Zero,
    output wire         eq,
    output wire         lt,    
    output wire         ltu     
);
    always @(*) begin
        case (ALUCtrl)
            `ALU_ADD:  Result = a + b;
            `ALU_SUB:  Result = a - b;
            `ALU_AND:  Result = a & b;
            `ALU_OR:   Result = a | b;
            `ALU_XOR:  Result = a ^ b;
            `ALU_SLL:  Result = a << b[4:0];
            `ALU_SRL:  Result = a >> b[4:0];
            `ALU_SRA:  Result = $signed(a) >>> b[4:0];
            `ALU_SLT:  Result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            `ALU_SLTU: Result = (a < b) ? 32'h1 : 32'h0;
            default:   Result = 32'h0;
        endcase
    end

    assign Zero = (Result == 32'h0);
    assign eq   = (a == b);
    assign lt   = ($signed(a) < $signed(b));
    assign ltu  = (a < b);

endmodule
