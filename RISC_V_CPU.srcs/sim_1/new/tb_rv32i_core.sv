`timescale 1ns / 1ps

module tb_rv32i_core ();
    logic clk;
    logic reset;

    MCU dut (
        .clk  (clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #20;
        reset = 0;
        #60 $finish();
    end
endmodule
