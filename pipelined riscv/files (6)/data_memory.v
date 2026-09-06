`timescale 1ns/1ps

module data_memory #(
    parameter MEM_DEPTH_BYTES = 4096
)(
    input  wire        clk,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] Mem_Addr,
    input  wire [31:0] Write_Data,
    input  wire [2:0]  funct3,
    output reg  [31:0] Read_Data
);
    reg [7:0] mem [0:MEM_DEPTH_BYTES-1];
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH_BYTES; i = i + 1)
            mem[i] = 8'h0;
    end

    wire [31:0] addr = Mem_Addr;

    // ---- Store ----
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: mem[addr] <= Write_Data[7:0];                
                3'b001: begin                                       
                    mem[addr]     <= Write_Data[7:0];
                    mem[addr+1]   <= Write_Data[15:8];
                end
                3'b010: begin                                          
                    mem[addr]     <= Write_Data[7:0];
                    mem[addr+1]   <= Write_Data[15:8];
                    mem[addr+2]   <= Write_Data[23:16];
                    mem[addr+3]   <= Write_Data[31:24];
                end
                default: ; // ignore
            endcase
        end
    end

    // ---- Load (combinational read) ----
    always @(*) begin
        case (funct3)
            3'b000:  Read_Data = {{24{mem[addr][7]}}, mem[addr]};                       // lb
            3'b001:  Read_Data = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};        // lh
            3'b010:  Read_Data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};    // lw
            3'b100:  Read_Data = {24'b0, mem[addr]};                                    // lbu
            3'b101:  Read_Data = {16'b0, mem[addr+1], mem[addr]};                       // lhu
            default: Read_Data = 32'h0;
        endcase
    end

endmodule
