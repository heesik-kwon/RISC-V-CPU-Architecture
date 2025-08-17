`timescale 1ns/1ps

module RAM (
    input  logic clk, reset,
    input  logic we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);

    logic [31:0] mem [0:9];

    always_ff @( posedge clk ) begin
        if(we) begin
            mem[addr[31:2]] <= wData;            
        end
    end

    assign rData = mem[addr[31:2]];

endmodule
