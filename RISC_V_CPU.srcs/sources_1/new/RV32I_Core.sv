`timescale 1ns / 1ps

module RV32I_Core (
    input logic clk,
    input logic reset,

    // Instruction Memory Interface(ROM)
    input  logic [31:0] instr_data,
    output logic [31:0] instr_addr,

    // Data Memory Interface(RAM)
    output logic        data_mem_we,
    output logic [31:0] data_mem_addr,
    output logic [31:0] data_mem_wdata,
    input  logic [31:0] data_mem_rdata
);

    // Control Signals
    logic       reg_file_we;
    logic [3:0] alu_ctrl;
    logic       alu_src_sel;
    logic       wb_mux_sel;
    logic       branch_en;
    logic       jump_sel;
    logic       jal_sel;

    ControlUnit U_ControlUnit (.*);
    DataPath U_DataPath (.*);

endmodule

