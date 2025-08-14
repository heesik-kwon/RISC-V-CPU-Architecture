`timescale 1ns/1ps

// Load Data Processor Module
module LoadDataProcessor (
    input  logic [2:0] funct3,
    input  logic [31:0] data_mem_rdata,
    output logic [31:0] processed_data
);
    always_comb begin
        case (funct3)
            3'b000: processed_data  = {{24{data_mem_rdata[7]}}, data_mem_rdata[7:0]};    // Load Byte
            3'b001: processed_data  = {{16{data_mem_rdata[15]}}, data_mem_rdata[15:0]};  // Load Half
            3'b010: processed_data  = data_mem_rdata;                                    // Load Word
            3'b100: processed_data  = {24'b0, data_mem_rdata[7:0]};                      // Load Byte(Unsigned)
            3'b101: processed_data  = {16'b0, data_mem_rdata[15:0]};                     // Load Half(Unsigned)
            default: processed_data = data_mem_rdata;
        endcase 
    end
endmodule