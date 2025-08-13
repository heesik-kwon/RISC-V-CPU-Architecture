`timescale 1ns / 1ps

// Register File Module
module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    output logic [31:0] RData1,
    output logic [31:0] RData2
);

    // [31:0]  : 각 레지스터의 비트 폭(XLEN=32)
    // [0:2**5-1] : x0 ~ x31
    logic [31:0] RegFile[0:2**5-1];

    // ------------------------------------------------------
    // 시뮬레이션 초기값 설정 (for test only)
    // ------------------------------------------------------
    initial begin
        for (int i = 0; i < 32; i++) begin
            RegFile[i] = i;
        end
    end

    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end

    // 읽기 포트: 주소가 0이면 RISC-V 규칙에 따라 항상 0 반환 (x0 = 0)
    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 0;
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 0;
endmodule
