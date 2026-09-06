`ifndef DEFINES_VH
`define DEFINES_VH

`define OP_R_TYPE   7'b0110011   // add, sub, sll, slt, sltu, xor, srl, sra, or, and
`define OP_I_TYPE   7'b0010011   // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
`define OP_LOAD     7'b0000011   // lb, lh, lw, lbu, lhu
`define OP_STORE    7'b0100011   // sb, sh, sw
`define OP_BRANCH   7'b1100011   // beq, bne, blt, bge, bltu, bgeu
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111


`define ALUOP_ADD      2'b00   // loads, stores, jal/jalr link math, auipc, lui
`define ALUOP_SUB      2'b01   // (unused directly - comparator handles branches)
`define ALUOP_RFUNCT   2'b10   // R-type: decode via funct3 AND funct7 bit5 (sub/sra)
`define ALUOP_IFUNCT   2'b11   // I-type ALU: decode via funct3; funct7 bit5 only valid for srai


`define ALU_ADD   4'b0000
`define ALU_SUB   4'b0001
`define ALU_AND   4'b0010
`define ALU_OR    4'b0011
`define ALU_XOR   4'b0100
`define ALU_SLL   4'b0101
`define ALU_SRL   4'b0110
`define ALU_SRA   4'b0111
`define ALU_SLT   4'b1000
`define ALU_SLTU  4'b1001

// ImmSrc - selects which immediate format the Immediate Data Extractor builds

`define IMM_I  3'b000
`define IMM_S  3'b001
`define IMM_B  3'b010
`define IMM_U  3'b011
`define IMM_J  3'b100


// ALUSrcA 

`define ASRCA_REG   2'b00   // rs1 (forwarded)
`define ASRCA_PC    2'b01   // PC of instruction (for auipc / jal target adder)
`define ASRCA_ZERO  2'b10   // constant 0 (for lui: result = 0 + imm)

// MemtoReg 

`define WB_ALU   2'b00
`define WB_MEM   2'b01
`define WB_PC4   2'b10   // link register (jal / jalr)


// PCSrc - selects next PC

`define PC_PLUS4     2'b00
`define PC_BRANCH    2'b01   // PC(ID/EX) + imm  (taken branch or JAL)
`define PC_JALR      2'b10   // (rs1 + imm) & ~1

// Forwarding mux selects

`define FWD_NONE   2'b00   // from register file / ID stage
`define FWD_EXMEM  2'b01
`define FWD_MEMWB  2'b10

`endif
