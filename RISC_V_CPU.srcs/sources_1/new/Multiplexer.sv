`timescale 1ns / 1ps

// 2x1 Mux Module
module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
            default: y = 32'bx;
        endcase
    end
endmodule

// 3x1 Mux Module
module mux_3x1 (
    input  logic [ 1:0] sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    input  logic [31:0] x2,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            2'b00:   y = x0;
            2'b01:   y = x1;
            2'b10:   y = x2;
            2'b11:   y = x2;
            default: y = 32'bx;
        endcase
    end
endmodule
