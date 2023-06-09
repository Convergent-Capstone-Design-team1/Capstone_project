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
        if      (RST)   Q_r <= 0;
        else if (EN)    Q_r <= Q;
        else            Q_r <= D;
    end

    assign Q = Q_r;
    
endmodule