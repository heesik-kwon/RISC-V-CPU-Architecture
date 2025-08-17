`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset
);
    logic [31:0] instr_data;
    logic [31:0] instr_addr;
    logic [31:0] data_mem_addr;
    logic [31:0] data_mem_wdata, data_mem_rdata;
    logic data_mem_we;

    RV32I_Core U_RV32I (
        .clk          (clk),                     
        .reset        (reset),                   
        .instr_data   (instr_data),               
        .instr_addr   (instr_addr),              
        .data_mem_we  (data_mem_we),              
        .data_mem_addr(data_mem_addr),           
        .data_mem_wdata(data_mem_wdata),         
        .data_mem_rdata(data_mem_rdata)           
    );

    ROM U_ROM (
        .addr(instr_addr),                       
        .data(instr_data)                         
    );

    RAM U_RAM (
        .clk(clk),                             
        .reset(reset),                           
        .we(data_mem_we),                      
        .addr(data_mem_addr),                    
        .wData(data_mem_wdata),                
        .rData(data_mem_rdata)               
    );
endmodule