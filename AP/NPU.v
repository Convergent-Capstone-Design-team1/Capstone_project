module npu
#(
    parameter data_size = 32        ,
    parameter mem_size = 28         ,
    parameter mul_size = 3          ,
    parameter mat_size = 9
)
(
    input           clk             ,
    input           rst             ,
    input           en              ,
    input           get_wr          ,
    input   [31:0]  get_data        ,
    input   [31:0]  get_addr        ,
    input   [31:0]  mem_addr        ,
    input   [31:0]  mem_init        ,

    output          pass_we         ,
    output          ack             ,
    output  [31:0]  modified_addr   ,
    output  [31:0]  modified_data
);

    reg [(mem_size*2)-1:0] npu_mem [data_size-1:0];     // for문으로 각 24개씩 32'b data를 초기화하며 넣어줌
    
    reg         flag;
    reg [5:0]   i;
    reg [5:0]   j;
    reg [5:0]   k;
    reg [31:0]  modified_addr;
    reg [31:0]  modified_data;

    reg [data_size-1:0] a1;
    reg [data_size-1:0] a2;
    reg [data_size-1:0] a3;
    reg [data_size-1:0] b1;
    reg [data_size-1:0] b2;
    reg [data_size-1:0] b3;

    wire [data_size-1:0] c1;
    wire [data_size-1:0] c2;
    wire [data_size-1:0] c3;
    wire [data_size-1:0] c4;
    wire [data_size-1:0] c5;
    wire [data_size-1:0] c6;
    wire [data_size-1:0] c7;
    wire [data_size-1:0] c8;
    wire [data_size-1:0] c9;

    reg [mul_size-1:0] en_ab;
    reg [mem_size-1:0] ack_cnt;

    generate
        genvar  idx;
        for (idx = 0; idx < 27; idx = idx+1) begin: inside_npu
            wire [31:0] tmp;
            assign tmp = npu_mem[idx];
        end
    endgenerate

    always @ (posedge rst) begin
        a1 <= 32'b0;
        a2 <= 32'b0;
        a3 <= 32'b0;
        b1 <= 32'b0;
        b2 <= 32'b0;
        b3 <= 32'b0;
        i  <= 6'b0;
        j  <= 6'b0;
        k  <= 6'b0;
    end

    always@(posedge clk) begin

        en_ab[0] <= (en && (i < (mul_size))) ? 1'b1 : 1'b0;
        en_ab[1] <= (en && (en_ab[0])) ? 1'b1 : 1'b0;
        en_ab[2] <= (en && (en_ab[1])) ? 1'b1 : 1'b0;

        /*** NPU module initialization ***/
        if(rst) begin
            npu_mem[mem_addr-1] <= mem_init;
            modified_addr <= 32'b0;
            modified_data <= 32'b0;
        end

        if(get_wr && (get_addr >= 0)) begin
            npu_mem[mem_addr] <= get_data;
        end

        /*** NPU core (Systolic array) operation ***/
        if(en) begin
            // CPU Instruction : matr  =>  EN : 1  & NPU operation start
            i <= i + 1'b1;
            // A matrix first row & B matrix first column
            if(en_ab[0]) begin
                a1 <= npu_mem[5'd0 * mul_size + (i-1)];
                b1 <= npu_mem[(i-1) * mul_size + 5'd0 + mat_size];
            end
            else begin
                a1 <= 32'd0;
                b1 <= 32'd0;
            end
            // A matrix second row & B matrix second column
            if(en_ab[1]) begin
                a2 <= npu_mem[5'd1 * mul_size + (i-2)];
                b2 <= npu_mem[(i-2) * mul_size + 5'd1 + mat_size];
            end
            else begin
                a2 <= 32'd0;
                b2 <= 32'd0;
            end
            // A matrix third row & B matrix third column
            if(en_ab[2]) begin
                a3 <= npu_mem[5'd2 * mul_size + (i-3)];
                b3 <= npu_mem[(i-3) * mul_size + 5'd2 + mat_size];
            end
            else begin
                a3 <= 32'd0;
                b3 <= 32'd0;
            end
            // 3x3 Matrix operation end
            if(c9) begin
                ack_cnt <= ack_cnt + 1'b1;
            end
            
        end
        else begin
            // NPU opeeration end
            ack_cnt <= 0;
            i <= 6'd0;
        end

        /*** Result matrix initialization & Store ***/
        if(ack) begin
            // ACK : 1 => NPU mem initialization
            for(j = 0; j < mat_size; j = j + 1) begin
                npu_mem[mat_size*2 + j] <= 0;
            end
        end
        else begin
            // ACK : 0 => Store MAC result to NPU MEMORY 
            npu_mem[mat_size*2 + 0] <= c1;
            npu_mem[mat_size*2 + 1] <= c2;
            npu_mem[mat_size*2 + 2] <= c3;
            npu_mem[mat_size*2 + 3] <= c4;
            npu_mem[mat_size*2 + 4] <= c5;
            npu_mem[mat_size*2 + 5] <= c6;
            npu_mem[mat_size*2 + 6] <= c7;
            npu_mem[mat_size*2 + 7] <= c8;
            npu_mem[mat_size*2 + 8] <= c9;
        end

        /*** Set flag bit & modified addr, data ***/
        if(!flag && (mul_size == ack_cnt)) begin
            // c9의 첫 결과가 나오고나서 3까지 cnt를 했다면 flag를 1로 set
            // c9의 최종 계산 값까지 3clk이 걸리기 때문
            flag <= 1;
        end
        else if(flag && (k < mat_size)) begin
            // flag가 1로 set 되고 9번까지 C 행렬에 들어가는 주소와 데이터를 CPU로 전송
            modified_addr <= mat_size*8 + k*4;
            modified_data <= npu_mem[mat_size*2 + k];
            k <= k + 1;
        end
        else begin
            // 위 조건이 아닐시 초기화
            k <= 0;
            flag <= 0;
            modified_addr <= 0;
            modified_data <= 0;
        end
    end

    wire ack;
    assign ack = (k == mat_size) ? 1'b1 : 1'b0; // k가 9까지 count되어서 주소와 데이터를 모두 전송했다면 ack을 1로 set
    assign pass_we = k && flag;                 // flag가 set되고 초기화가 될 때 까지 pass_we 1로 set

    /*** SYSTOLIC_ARRAY instant ***/
    SYSTOLIC_ARRAY SYSTOLIC_ARRAY
    (   
        //INPUT
        .clk(clk)       , 
        .rst(!en)       , 
        .a1(a1)         , 
        .a2(a2)         , 
        .a3(a3)         , 
        .b1(b1)         , 
        .b2(b2)         , 
        .b3(b3)         , 

        //OUTPUT
        .c1(c1)         , 
        .c2(c2)         , 
        .c3(c3)         , 
        .c4(c4)         , 
        .c5(c5)         , 
        .c6(c6)         ,     
        .c7(c7)         , 
        .c8(c8)         , 
        .c9(c9)
    );

endmodule