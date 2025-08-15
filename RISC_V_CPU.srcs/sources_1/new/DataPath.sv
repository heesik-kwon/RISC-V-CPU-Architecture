`timescale 1ns/1ps

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_data,
    output logic [31:0] instr_addr,
    input  logic        reg_file_we,
    input  logic [ 3:0] alu_ctrl,
    input  logic        alu_src_sel,
    input  logic        wb_mux_sel,
    input  logic        branch_en,   // B-type일 때 1
    input  logic        jump_sel,    // Writeback용 (PC+4 선택)
    input  logic        jal_sel,     // JALR 기반 선택(rs1 vs PC)
    output logic [31:0] data_mem_addr,
    output logic [31:0] data_mem_wdata,
    input  logic [31:0] data_mem_rdata
);

    logic [31:0] PC_Data, RegFileData1, RegFileData2, aluResult, immOut, aluSrcMuxOut;
    logic [31:0] wrMuxOut, branch_enMuxOut, jalMuxOut;
    logic [31:0] data_mem_rdata_processed, J_PC_Data;
    logic        branch_enMuxSel, branch_flag;

    logic        is_branch;  // B-type 명령일 때만 1

    wire  [2:0] funct3  = instr_data[14:12];

    assign data_mem_addr = aluResult;

    // 컨트롤에서 B-type에만 1을 주는 branch_en 사용
    assign is_branch = branch_en;

    // B-type 분기 or J-type 점프 시 PC에 immOut 더함
    assign branch_enMuxSel = (branch_flag & branch_en) || (instr_data[6] && instr_data[2]);

    // ------------------------
    // Program Counter
    // ------------------------
    register U_PC (
        .clk   (clk),
        .reset (reset),
        .d     (PC_Data),
        .q     (instr_addr)
    );

    // ------------------------
    // Immediate Extension
    // ------------------------
    ImmediateExtend U_Extend (
        .instr_data(instr_data),
        .immExt    (immOut)
    );

    // ------------------------
    // Register File
    // ------------------------
    RegisterFile U_RegFile (
        .clk   (clk),
        .we    (reg_file_we),
        .RAddr1(instr_data[19:15]),
        .RAddr2(instr_data[24:20]),
        .WAddr (instr_data[11:7]),
        .WData (wrMuxOut),
        .RData1(RegFileData1),
        .RData2(RegFileData2)
    );

    // ------------------------
    // ALU Source Mux (rs2 vs imm)
    // ------------------------
    mux_2x1 U_AluSrcMux (
        .sel(alu_src_sel),
        .x0 (RegFileData2),
        .x1 (immOut),
        .y  (aluSrcMuxOut)
    );

    // ------------------------
    // ALU
    // ------------------------
    alu U_ALU (
        .alu_ctrl   (alu_ctrl),
        .a          (RegFileData1),
        .b          (aluSrcMuxOut),
        .pc_input   (instr_addr),
        .is_branch  (is_branch),      
        .branch_flag(branch_flag),
        .result     (aluResult)
    );

    // ------------------------
    // LOAD 데이터 후처리 (LB/LH/LW/LBU/LHU)
    // ------------------------
    LoadDataProcessor U_LoadDataProcessor (
        .funct3           (funct3),
        .data_mem_rdata  (data_mem_rdata),
        .processed_data  (data_mem_rdata_processed)
    );

    // ------------------------
    // Branch & Jump Logic
    // ------------------------
    // 분기/점프면 immOut, 아니면 +4
    mux_2x1 U_branch_en_Mux (
        .sel(branch_enMuxSel),
        .x0 (32'd4),
        .x1 (immOut),
        .y  (branch_enMuxOut)
    );

    // JAL vs JALR: PC기반(JAL) vs rs1기반(JALR)
    mux_2x1 U_JAL_Mux (
        .sel(jal_sel),
        .x0 (instr_addr),
        .x1 (RegFileData1),
        .y  (jalMuxOut)
    );

    adder U_Adder_PC (
        .a(instr_addr),
        .b(branch_enMuxOut),
        .y(PC_Data)
    );

    // Writeback용 (PC + 4)
    adder U_J_Adder_PC(
        .a(instr_addr),
        .b(32'd4),
        .y(J_PC_Data)
    );

    // ------------------------
    // Writeback MUX
    // ------------------------
    // sel = {jump_sel, wb_mux_sel}
    // 00: load 데이터, 01: ALU 결과, 1x: PC+4
    mux_3x1 U_wrMux (
        .sel({jump_sel, wb_mux_sel}),
        .x0 (data_mem_rdata_processed),
        .x1 (aluResult),
        .x2 (J_PC_Data),
        .y  (wrMuxOut)
    );

    // ------------------------
    // STORE 데이터 폭 처리 (SB/SH/SW)
    // ------------------------
    StoreMerger U_Store_Merger(
        .data     (RegFileData2),
        .ram_data (data_mem_rdata_processed),
        .funct3    (funct3),
        .size_data(data_mem_wdata)
    );

endmodule
