module BTB_MEM
#(
    parameter NUM_ENTRIES = 256  ,   // BTB 엔트리 수
    parameter ENTRY_WIDTH = 40      // BTB 엔트리 너비 (주소와 상태 비트) 
)
(
    input           clk         ,
    input           WE          ,
    input           RE          ,
    input   [7:0]   addr        ,
    input   [39:0]  data_i      ,

    output          hs          ,
    output  [39:0]  data_o      
);

    generate
    genvar  idx;
    for (idx = 0; idx < 40; idx = idx+1) begin: btb_mem
       wire [39:0] tmp;
       assign tmp = btb[idx];
    end
    endgenerate

    integer i; 
    initial begin
        for (i = 0; i < 40; i = i+1) begin
            btb[i] = 40'b0;
        end
    end
  
    /***********************************************************************/
    
    reg [ENTRY_WIDTH-1:0] btb [NUM_ENTRIES-1:0];              // BTB 메모리 

    /* write */
    always @ (posedge clk)
    begin
        if (WE)
            btb[addr] = data_i;
    end

    /* read */
    reg         hs_r;
    reg [39:0]  data_o_r;
    always @ (posedge clk)
    begin 
        if (RE) begin
            data_o_r <= btb[addr];
            hs_r <= 1'b1;
        end
        else begin
            data_o_r <= 40'hz;
            hs_r <= 1'b0;
        end
    end

    assign data_o = data_o_r; 
    assign hs = hs_r;

endmodule