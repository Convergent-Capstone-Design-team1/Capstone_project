module MEM_STAGE
(
    input           clk_50              ,
    input           rst                 ,
    input   [4:0]   MEM_control         ,
    input           zero                ,
    input   [31:0]  result              ,
    input   [31:0]  WD                  ,
    input   [31:0]  mem_pc              ,
    input           hit                 ,
    input   [31:0]  mem_addr            ,
    input   [31:0]  mem_init            ,
    input           EN_NPU              ,
    input           npu2mem             ,
    input   [9:0]   critical_addr       ,

    output          branch              ,
    output  [31:0]  R_DATA              ,
    output  [31:0]  mem_pc_o            ,
    output          critical
);

    assign critical = ((selected_addr == critical_addr) && MEM_control[2] && EN_NPU) ? 1'b1 : 1'b0;     // 주소가 critical + Memread + NPU동작중인 경우, 접근해선 안되는 영역을 참고중입니다!
    assign branch = MEM_control[0] & zero;
    assign mem_pc_o = mem_pc;
    wire [31:0] selected_data = npu2mem ? mem_init : WD;
    wire [31:0] selected_addr = npu2mem ? mem_addr : result;

    DATA_MEM DATA_MEM
    (   
        //INPUT
        .clk_50(clk_50)                     ,
        .rst(rst)                           ,
        .MEMRead(MEM_control[2])            ,
        .MEMWrite(MEM_control[1] || npu2mem),
        .ADDR(selected_addr)                ,
        .WD(selected_data)                  ,
        .mem_addr(mem_addr)                 ,
        .mem_init(mem_init)                 ,
        
        //OUTPUT        
        .RD(R_DATA)
    );

endmodule