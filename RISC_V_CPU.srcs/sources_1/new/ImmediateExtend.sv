`timescale 1ns / 1ps
`define ADD 4'b0000
`define SUB 4'b1000
`define SLL 4'b0001
`define SRL 4'b0101
`define SRA 4'b1101
`define SLT 4'b0010
`define SLTU 4'b0011
`define XOR 4'b0100
`define OR 4'b0110
`define AND 4'b0111
`define LUI 4'b1001
`define AUIPC 4'b1010


`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111


`define OP_TYPE_R 7'b0110011
`define OP_TYPE_L 7'b0000011
`define OP_TYPE_I 7'b0010011
`define OP_TYPE_S 7'b0100011
`define OP_TYPE_B 7'b1100011
`define OP_TYPE_LU 7'b0110111
`define OP_TYPE_AU 7'b0010111
`define OP_TYPE_J 7'b1101111
`define OP_TYPE_JL 7'b1100111

// Sign Extend Module
module ImmediateExtend (
    input  logic [31:0] instr_data,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instr_data[6:0];
    wire [2:0] funct3 = instr_data[14:12];
    wire [6:0] func7 = instr_data[31:25];

    always_comb begin
        case (opcode)
            `OP_TYPE_R: immExt = 32'bx;
            `OP_TYPE_L: immExt = {{20{instr_data[31]}}, instr_data[31:20]};
            `OP_TYPE_S:
            immExt = {
                {20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]
            };
            `OP_TYPE_I: begin
                if (funct3 == 3'b011)
                    immExt = {
                        20'b0, instr_data[31:20]
                    };  // For STLI, Imm unsigned
                else immExt = {{20{instr_data[31]}}, instr_data[31:20]};
            end
            `OP_TYPE_B:
            immExt = {
                {20{instr_data[31]}},
                instr_data[7],
                instr_data[30:25],
                instr_data[11:8],
                1'b0
            };
            `OP_TYPE_LU: immExt = {{instr_data[31:12]}, 12'b0};
            `OP_TYPE_AU: immExt = {{instr_data[31:12]}, 12'b0};
            `OP_TYPE_J:
            immExt = {
                {12{instr_data[31]}},
                instr_data[19:12],
                instr_data[20],
                instr_data[30:21],
                1'b0
            };
            `OP_TYPE_JL: immExt = {{20{instr_data[31]}}, instr_data[31:20]};
            default: immExt = 32'bx;
        endcase
    end
endmodule

