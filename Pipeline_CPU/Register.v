module REGISTER 
#(
    parameter W = 1
)
(   
    input           CLK ,
    input           RST ,
    input           EN  ,
    input   [W-1:0] D   ,
    output  [W-1:0] Q
);

    reg     [W-1:0] Q_r;
    always @ (posedge CLK or negedge RST)
    begin
        if      (RST)   Q_r <= 0;           //reset 신호가 들어오면 0으로 초기화
        else if (EN)    Q_r <= Q;           //stall 신호가 들어오면 값 유지 -> stall
        else            Q_r <= D;           
    end

    assign Q = Q_r;
    
endmodule