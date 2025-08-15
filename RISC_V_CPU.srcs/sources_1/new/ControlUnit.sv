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

module ControlUnit (
    input  logic [31:0] instr_data,
    output logic        reg_file_we,
    output logic [ 3:0] alu_ctrl,
    output logic        alu_src_sel,
    output logic        wb_mux_sel,
    output logic        data_mem_we,
    output logic        branch_en,
    output logic        jump_sel,
    output logic        jal_sel
);
    wire  [6:0] opcode = instr_data[6:0];
    wire  [2:0] func3 = instr_data[14:12];
    wire  [6:0] func7 = instr_data[31:25];
    logic [6:0] controls;

    assign {reg_file_we, alu_src_sel, data_mem_we, wb_mux_sel, branch_en, jump_sel, jal_sel} = controls;

    // Control signals(opcode)
    always_comb begin
        controls = 7'b0000000;
        case (opcode)
            `OP_TYPE_R:  controls = 7'b1_0_0_1_0_0_0;  // R-Type
            `OP_TYPE_L:  controls = 7'b1_1_0_0_0_0_0;  // L-Type
            `OP_TYPE_I:  controls = 7'b1_1_0_1_0_0_0;  // I-Type
            `OP_TYPE_S:  controls = 7'b0_1_1_1_0_0_0;  // S-Type
            `OP_TYPE_B:  controls = 7'b0_0_0_1_1_0_0;  // B-Type
            `OP_TYPE_LU: controls = 7'b1_1_0_1_0_0_0;  // LU-Type
            `OP_TYPE_AU: controls = 7'b1_1_0_1_0_0_0;  // AU_Type
            `OP_TYPE_J:  controls = 7'b1_0_0_0_1_1_0;  // J-Type
            `OP_TYPE_JL: controls = 7'b1_0_0_0_1_1_1;  // JL-Type
            default:     controls = 7'bx;  // Undefined opcode
        endcase
    end

    // ALU control logic(func3/func7)
    always_comb begin
        alu_ctrl = 3'b000;
        case (opcode)
            `OP_TYPE_R:  alu_ctrl = {func7[5], func3};  // R-Type
            `OP_TYPE_L:  alu_ctrl = `ADD;  // L-Type
            `OP_TYPE_I: begin
                if ({func7[5], func3} == 4'b1101) alu_ctrl = `SRA;
                else alu_ctrl = {1'b0, func3};  // I-Type
            end
            `OP_TYPE_S:  alu_ctrl = `ADD;  // S-Type
            `OP_TYPE_B:  alu_ctrl = {1'b0, func3};  // B-Type
            `OP_TYPE_LU: alu_ctrl = `LUI;  // LU-Type
            `OP_TYPE_AU: alu_ctrl = `AUIPC;  // AU_Type
            `OP_TYPE_J:  alu_ctrl = {func7[5], func3};  // J-Type
            `OP_TYPE_JL: alu_ctrl = {func7[5], func3};  // JL-Type
            default:     alu_ctrl = 4'bx;  // Undefined opcode
        endcase
    end

endmodule

