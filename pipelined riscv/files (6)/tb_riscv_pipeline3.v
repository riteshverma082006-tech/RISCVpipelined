`timescale 1ns/1ps
module tb_riscv_pipeline3;
    reg clk, reset;
    riscv_pipeline_top #(.IMEM_INIT_FILE("program3.hex")) dut (.clk(clk), .reset(reset));
    always #5 clk = ~clk;
    integer errors;
    initial begin
        clk=0; reset=1; errors=0;
        repeat(2) @(posedge clk);
        reset=0;
        repeat(35) @(posedge clk);

        check(1, 32'hFFFFFFBF, "x1 addi -65");
        check(2, 32'hFFFFFFBF, "x2 lb sign-extend");
        check(3, 32'd191,      "x3 lbu zero-extend");
        check(6, 32'd0,        "x6 squashed by bne(taken)");
        check(7, 32'd1,        "x7 reached after bne");
        check(8, 32'd0,        "x8 squashed by blt(taken)");
        check(9, 32'd2,        "x9 reached after blt");
        check(10,32'd0,        "x10 squashed by bge(taken)");
        check(11,32'd3,        "x11 reached after bge");
        check(12,32'd55,       "x12 executes - bne NOT taken (fallthrough)");

        if (errors==0) $display("\n*** ALL TESTS PASSED ***\n");
        else $display("\n*** %0d TEST(S) FAILED ***\n", errors);
        $finish;
    end
    task check(input [4:0] regnum, input [31:0] expected, input [200*8-1:0] label);
        reg [31:0] actual;
        begin
            actual = dut.u_regfile.regs[regnum];
            if (actual !== expected) begin
                $display("FAIL: %0s -> expected 0x%08h, got 0x%08h", label, expected, actual);
                errors = errors+1;
            end else $display("PASS: %0s -> 0x%08h", label, actual);
        end
    endtask
endmodule
