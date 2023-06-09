module ID_STAGE
(   
    input           clk_50          ,
    input           rst             ,
    input   [4:0]   reg_addr        ,
    input   [31:0]  reg_init        ,

    input   [31:0]  INST            ,
    input   [4:0]   WR              ,
    input   [4:0]   RD              ,
    input   [31:0]  WD              ,
    input           RegWrite        ,
    input           MEMRead         ,
    input           flush           ,
    input           hit             ,
    input           ack             ,
    input           critical        ,
    input           npu_matching    ,
    
    output          stall           ,
    output  [31:0]  RD1             ,
    output  [31:0]  RD2             ,
    output  [31:0]  S_INST          ,
    output  [5:0]   f_id_ctrl       ,
    output  [3:0]   ALU_control     ,
    output          EN_NPU          ,
    output  [9:0]   critical_addr
);
    wire    [7:0]   control;
    wire    [4:0]   sel_addr;
    wire            npu_stalling1;      // npu_stall을 1 cycle delay
    wire            npu_stalling2;      // npu_stall을 2 cycle delay (critical addr 저장 완료시점)
    reg     [9:0]   critical_addr;      // 메모리의 해당 영역의 주소는 접근해선 안됩니다.
    reg             EN_NPU;             // NPU의 동작신호
    reg             npu_stall;          // 1. Matrix연산이 시작되었다는 뜻으로, PC는 critical addr이 확실히 저장되었을 때 까지 무조건 기다려야합니다.
                                        // 2. 이는, 바로 직전 명령어가 critical addr의 값을 reg에 썼을 경우 2cycle을 기다려야 하기 때문입니다.
    reg             critical_state;

    always @(posedge clk_50 or posedge rst) begin
        if(rst) begin
            EN_NPU <= 1'b0;
            npu_stall <= 1'b0;
            critical_addr <= 0;
            critical_state <= 0;
        end
        else if(ack) begin
            EN_NPU <= 1'b0;
            critical_addr <= 0;
            critical_state <= 0;
            npu_stall <= 0;
        end
        else if(npu_matching) begin
            npu_stall <= 1'b1;
        end
        else if(ALU_control == 4'd8) begin              // 3. Matrix 연산이 시작되었으므로, NPU를 동작시키고, critical addr get까지 PC를 stall합니다.
            EN_NPU <= 1'b1;
            npu_stall <= 1'b1;
        end
        else if(critical) begin                         // 6. 만일 critical path의 데이터를 load할 경우, data hazard입니다!
            npu_stall <= 1'b1;
            critical_state <= 1'b1;
        end
        else if(!critical_state && critical_addr) begin // 5. critical addr get이 끝났으므로, 이제 PC는 resume해도 됩니다.
            npu_stall <= 1'b0;
        end
        else if(npu_stalling2 && EN_NPU) begin          // 4. Matrix연산 직전 명령어가 critical path라도, 2사이클 이후엔 확실히 값이 쓰여 있습니다.
            critical_addr <= RD1[9:0];                  // 4. Matr 명령어의 RD부분으로부터 critical path를 얻습니다.
        end
        else begin
        end        
    end

    HAZARD_DETECTION HAZARD_DETECTION
    (   
        //INPUT
        .MEMRead(MEMRead)           ,
        .RD(RD)                     ,
        .RS1(INST[19:15])           ,
        .RS2(INST[24:20])           ,
        .mat_start(npu_stall)       ,
        
        //OUTPUT
        .stall(stall)               
    );

    CONTROL CONTROL
    (
        //INPUT
        .CtrlSrc(stall)             ,
        .opcode(INST[6:0])          ,
        
        //OUTPUT
        .control(control)
    );

    REGISTER #(1) calc_addr_1
    (
        .CLK(clk_50)                ,
        .RST(rst)                   ,
        .EN(1'b0)                   ,
        .D(npu_stall)               ,
        .Q(npu_stalling1)
    );

    REGISTER #(1) calc_addr_2
    (
        .CLK(clk_50)                ,
        .RST(rst)                   ,
        .EN(1'b0)                   ,
        .D(npu_stalling1)           ,
        .Q(npu_stalling2)
    );

    assign sel_addr = npu_stalling2 ? INST[11:7] : INST[19:15];
    REGISTER_FILE REGISTER_FILE
    (
        //INPUT
        .clk_50(clk_50)             ,
        .rst(rst)                   ,
        .reg_addr(reg_addr)         ,
        .reg_init(reg_init)         ,
        
        .RR1(sel_addr)              ,
        .RR2(INST[24:20])           ,
        .WR(WR)                     ,
        .WD(WD)                     ,
        .WE(RegWrite)               ,
        
        //OUTPUT
        .RD1(RD1)                   ,
        .RD2(RD2)
    );

    IMMGEN IMMGEN
    (
        //INPUT
        .INST(INST)                 ,    
       
        //OUTPUT
        .S_INST(S_INST)
    );

    ALU_CONTROL ALU_CONTROL
    (
        //INPUT
        .funct7({INST[30],INST[25]}), 
        .funct3(INST[14:12])        , 
        .ALUOp(control[1:0])        , 
        
        //OUTPUT
        .ALU_control(ALU_control)
    );

    ID_EX_FLUSH ID_EX_FLUSH
    (
        //INPUT
        .flush(flush)               ,
        .hit(hit)                   ,
        .id_ex_ctrl(control[7:2])   ,
       
        //OUTPUT
        .id_ex_f_ctrl(f_id_ctrl)    
    );
    
endmodule