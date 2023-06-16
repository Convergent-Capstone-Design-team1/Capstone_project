// Pipeline에서 발생하는 Data Hazard를 해결하기 위한 모듈
// MEM stage와 WB stage에서의 Regwrite와 destination reisger 주소와
// 현재 명령어의 source register의 주소를 입력으로 받음

module FORWARDING_UNIT
(
    input           EX_MEM_RegWrite ,
    input           MEM_WB_RegWrite ,
    input   [4:0]   EX_MEM_RD       ,
    input   [4:0]   MEM_WB_RD       ,
    input   [4:0]   RS1             ,
    input   [4:0]   RS2             ,

    output  [1:0]   ForwardA        ,
    output  [1:0]   ForwardB   
);
    
    reg     [1:0]   ForwardA_r;
    reg     [1:0]   ForwardB_r;
    
    //ForwardA
    always @ (*) 
    begin
        //EX Hazard : RegWrite신호가 1 (R-type & I-type instructions) 일 때, RD가 x0가 아닐 때, 
        //            MEM stage의 RD주소와 ID stage에 넘어온 명령어의 RS1과 같을 때 ALU의 결과를 바로 가져오도록 함
        if (EX_MEM_RegWrite && (EX_MEM_RD != 5'd0) && (EX_MEM_RD == RS1)) begin
            ForwardA_r = 2'b10;
        end 
        //MEM Hazard : RegWrite신호가 1 (R-type & I-type instructions) 일 때, RD가 x0가 아닐 때, 
        //             WB stage의 RD주소와 ID stage에 넘어온 명령어의 RS1과 같을 때 WB stage의 WD를 바로 가져오도록 함   
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 5'd0) && (MEM_WB_RD == RS1)) begin
            ForwardA_r = 2'b01;    
        end
        //그렇지 않을 때는 기존의 RD1을 ALU input으로 넣음
        else begin
            ForwardA_r = 2'b00;
        end
    end

    //ForwardB
    always @ (*) 
    begin
        
        //EX Hazard : RegWrite신호가 1 (R-type & I-type instructions) 일 때, RD가 x0가 아닐 때, 
        //            MEM stage의 RD주소와 ID stage에 넘어온 명령어의 RS2과 같을 때 ALU의 결과를 바로 가져오도록 함
        if (EX_MEM_RegWrite && (EX_MEM_RD != 5'd0) && (EX_MEM_RD == RS2)) begin
            ForwardB_r = 2'b10;   
        end
        //MEM Hazard : RegWrite신호가 1 (R-type & I-type instructions) 일 때, RD가 x0가 아닐 때, 
        //             WB stage의 RD주소와 ID stage에 넘어온 명령어의 RS2과 같을 때 WB stage의 WD를 바로 가져오도록 함     
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 5'd0) && (MEM_WB_RD == RS2)) begin
            ForwardB_r = 2'b01;
        end 
        //그렇지 않을 때는 기존의 RD2을 ALU input으로 넣음
        else begin
            ForwardB_r = 2'b00;
        end
    end

    assign ForwardA = ForwardA_r;
    assign ForwardB = ForwardB_r;

endmodule