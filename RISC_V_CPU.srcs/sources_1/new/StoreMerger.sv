`timescale 1ns / 1ps

module StoreMerger (
    input  logic [31:0] data,
    input  logic [31:0] ram_data,
    input  logic [ 2:0] funct3,
    output logic [31:0] size_data
);
    always_comb begin
        size_data = data;
        case (funct3)
            3'b000:  size_data = {ram_data[31:8], data[7:0]};
            3'b001:  size_data = {ram_data[31:16], data[15:0]};
            3'b010:  size_data = data;
            default: size_data = data;
        endcase
    end
endmodule
