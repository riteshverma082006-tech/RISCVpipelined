`timescale 1ns/1ps
module tb_riscv_pipeline;

    reg clk;
    reg reset;

    riscv_pipeline_top #(.IMEM_INIT_FILE("program.hex")) dut (
        .clk(clk), .reset(reset)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    integer errors;

    initial begin
        clk   = 0;
        reset = 1;
        errors = 0;
        repeat (2) @(posedge clk);
        reset = 0;

     
        repeat (30) @(posedge clk);

  
        check(1, 32'd5,  "x1 (addi x1,x0,5)");
        check(2, 32'd10, "x2 (addi x2,x0,10)");
        check(3, 32'd15, "x3 (add x3,x1,x2) - EX forwarding");
        check(4, 32'd15, "x4 (lw x4,0(x0))");
        check(5, 32'd30, "x5 (add x5,x4,x4) - load-use stall");
        check(6, 32'd1,  "x6 (addi x6,x0,1)");
        check(7, 32'd0,  "x7 (must be squashed by taken branch)");
        check(8, 32'd42, "x8 (addi x8,x0,42) - reached via branch target)");

        if (errors == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d TEST(S) FAILED ***\n", errors);

        $finish;
    end

    task check(input [4:0] regnum, input [31:0] expected, input [200*8-1:0] label);
        reg [31:0] actual;
        begin
            actual = dut.u_regfile.regs[regnum];
            if (actual !== expected) begin
                $display("FAIL: %0s -> expected %0d, got %0d", label, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s -> %0d", label, actual);
            end
        end
    endtask

   
    always @(posedge clk) begin
        if (!reset && dut.RegWrite_wb)
            $display("t=%0t  WB: x%0d <= %0d (0x%08h)",
                      $time, dut.rd_wb, dut.wb_data, dut.wb_data);
    end

endmodule
