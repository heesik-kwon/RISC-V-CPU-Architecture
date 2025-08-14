`timescale 1ns / 1ps

//-----------------------------------------------------
// R-type / I-type ALU 연산
//-----------------------------------------------------
// ADD  = funct7[5] = 0, funct3 = 000  (R-type ADD / I-type ADDI)
`define ADD 4'b0000
// SUB  = funct7[5] = 1, funct3 = 000  (R-type SUB)
`define SUB 4'b1000
// SLL  = funct7[5] = 0, funct3 = 001  (R-type SLL / I-type SLLI)
`define SLL 4'b0001
// SRL  = funct7[5] = 0, funct3 = 101  (R-type SRL / I-type SRLI)
`define SRL 4'b0101
// SRA  = funct7[5] = 1, funct3 = 101  (R-type SRA / I-type SRAI)
`define SRA 4'b1101
// SLT  = funct7[5] = 0, funct3 = 010  (R-type SLT / I-type SLTI)
`define SLT 4'b0010
// SLTU = funct7[5] = 0, funct3 = 011  (R-type SLTU / I-type SLTIU)
`define SLTU 4'b0011
// XOR  = funct7[5] = 0, funct3 = 100  (R-type XOR / I-type XORI)
`define XOR 4'b0100
// OR   = funct7[5] = 0, funct3 = 110  (R-type OR  / I-type ORI)
`define OR 4'b0110
// AND  = funct7[5] = 0, funct3 = 111  (R-type AND / I-type ANDI)
`define AND 4'b0111

//-----------------------------------------------------
// U-type ALU 연산
//-----------------------------------------------------
// LUI   = U-type (Load Upper Immediate)
`define LUI 4'b1001
// AUIPC = U-type (Add Upper Immediate to PC)
`define AUIPC 4'b1010



`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

// opcode
`define OP_TYPE_R 7'b0110011  // R: 레지스터-레지스터 ALU
`define OP_TYPE_I   7'b0010011  // I: 즉시값 ALU(ADDI/ANDI/… + SLLI/SRLI/SRAI)
`define OP_TYPE_L 7'b0000011  // I: LOAD (LB/LH/LW/LBU/LHU)
`define OP_TYPE_S 7'b0100011  // S: STORE (SB/SH/SW)
`define OP_TYPE_B 7'b1100011  // B: BRANCH (BEQ/BNE/…)
`define OP_TYPE_LU 7'b0110111  // U: LUI
`define OP_TYPE_AU 7'b0010111  // U: AUIPC
`define OP_TYPE_J 7'b1101111  // J: JAL
`define OP_TYPE_JL 7'b1100111  // I: JALR (funct3=000)

// ALU Module
module alu (
    input  logic [ 3:0] alu_ctrl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] pc_input,
    input  logic        is_branch,
    output logic        branch_flag,
    output logic [31:0] result
);

    // RV32의 최대 shift양은 5bit
    wire [4:0] s_a = b[4:0];

    always_comb begin
        case (alu_ctrl)
            `ADD: result = a + b;  // 덧셈
            `SUB: result = a - b;  // 뺄셈
            `SLL: result = a << s_a;  // 논리 왼쪽 시프트
            `SRL: result = a >> s_a;  // 논리 오른쪽 시프트
            `SRA: result = $signed(a) >>> s_a;  // 산술 오른쪽 시프트
            `SLT:
            result = ($signed(a) < $signed(b)) ? 32'd1 :
                32'd0;  // signed 비교
            `SLTU: result = (a < b) ? 32'd1 : 32'd0;  // unsigned 비교
            `XOR: result = a ^ b;  // XOR
            `OR: result = a | b;  // OR
            `AND: result = a & b;  // AND
            `LUI: result = b;  // 상위 20비트 imm 로드
            `AUIPC: result = pc_input + b;  // PC + imm
            default: result = 32'bx;
        endcase
    end

    always_comb begin
        if (!is_branch) branch_flag = 1'b0;
        else
            case (alu_ctrl[2:0])
                `BEQ: branch_flag = (a == b);
                `BNE: branch_flag = (a != b);
                `BLT: branch_flag = ($signed(a) < $signed(b));
                `BGE: branch_flag = ($signed(a) >= $signed(b));
                `BLTU: branch_flag = (a < b);
                `BGEU: branch_flag = (a >= b);
                default: branch_flag = 1'b0;
            endcase
    end
endmodule

