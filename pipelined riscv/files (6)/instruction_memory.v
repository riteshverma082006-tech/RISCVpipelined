`timescale 1ns/1ps
// ============================================================
// Instruction_Memory  (IF stage)
//   Word-addressed ROM, loaded from a hex file at elaboration.
//   PC is a byte address; only PC[31:2] is used to index words.
// ============================================================
module instruction_memory #(
    parameter MEM_DEPTH_WORDS = 1024,
    parameter INIT_FILE       = ""
)(
    input  wire [31:0] Inst_Addr,   // PC_out from PC register
    output wire [31:0] instruction
);

    reg [31:0] mem [0:MEM_DEPTH_WORDS-1];

    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH_WORDS; i = i + 1)
            mem[i] = 32'h00000013; // default = NOP (addi x0,x0,0)
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    assign instruction = mem[Inst_Addr[31:2]];

endmodule
