`timescale 1ns/1ps
module tb_riscv_pipeline2;

    reg clk;
    reg reset;

    riscv_pipeline_top #(.IMEM_INIT_FILE("program2.hex")) dut (
        .clk(clk), .reset(reset)
    );

    always #5 clk = ~clk;
    integer errors;

    initial begin
        clk = 0; reset = 1; errors = 0;
        repeat (2) @(posedge clk);
        reset = 0;
        repeat (30) @(posedge clk);

        check(10, 32'h12345000, "x10 lui");
        check(11, 32'd4,        "x11 auipc (PC=4)");
        check(12, 32'hFFFFFFFB, "x12 addi -5");
        check(13, 32'd5,        "x13 sub x0-x12");
        check(14, 32'd1,        "x14 slt (-5 < 0)");
        check(15, 32'd24,       "x15 jal link (PC+4)");
        check(16, 32'd0,        "x16 squashed by jal");
        check(18, 32'd28,       "x18 auipc (PC=28)");
        check(19, 32'd36,       "x19 jalr link (PC+4)");
        check(20, 32'd0,        "x20 squashed by jalr");
        check(21, 32'd77,       "x21 reached via jalr target");

        if (errors == 0) $display("\n*** ALL TESTS PASSED ***\n");
        else $display("\n*** %0d TEST(S) FAILED ***\n", errors);
        $finish;
    end

    task check(input [4:0] regnum, input [31:0] expected, input [200*8-1:0] label);
        reg [31:0] actual;
        begin
            actual = dut.u_regfile.regs[regnum];
            if (actual !== expected) begin
                $display("FAIL: %0s -> expected 0x%08h, got 0x%08h", label, expected, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s -> 0x%08h", label, actual);
            end
        end
    endtask
endmodule
