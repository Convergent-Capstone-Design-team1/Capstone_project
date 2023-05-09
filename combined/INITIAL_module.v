module INITIAL_MODULE
(
    input       clk             ,
    input       rst_i           ,

    output  [39:0]  btb_init    ,
    output  [7:0]   btb_addr    ,

    output  [1:0]   bht_init    ,
    output  [7:0]   bht_addr    ,

    output  [31:0]  reg_init    ,    
    output  [4:0]   reg_addr
);

    reg [31:0] 	register_file [0:31];
    reg [31:0]  btb [0:255];
    reg [1:0]   bht [0:255];

    // BTB initialization
    reg [7:0] btb_addr_r;
    always @ (posedge clk)
    begin
        if (rst_i)
        begin
            btb_addr_r <= 8'b0;
        end
        else if (btb_addr_r <= 8'd255)
        begin
            btb[btb_addr_r] <= 40'b0;
            btb_addr_r <= btb_addr_r + 1;
        end
        else 
        begin
            btb_addr_r <= 8'b0;
        end
    end

    assign btb_init = btb[btb_addr_r];
    assign btb_addr = btb_addr_r;

    // BHT initialization
    reg [7:0] bht_addr_r;
    always @ (posedge clk)
    begin
        if (rst_i)
        begin
            bht_addr_r <= 8'b0;
        end
        else if (bht_addr_r <= 8'd255)
        begin
            bht[bht_addr_r] <= 2'b0;
            bht_addr_r <= bht_addr_r + 1;
        end
        else 
        begin
            bht_addr_r <= 8'b0;
        end
    end

    assign bht_init = bht[bht_addr_r];
    assign bht_addr = bht_addr_r;

    // Register file initialization
    reg [4:0] reg_addr_r;
    always @ (posedge clk)
    begin
        if (rst_i)
        begin
            reg_addr_r <= 5'b0;
        end
        else if (reg_addr_r <= 8'd255)
        begin
            register_file[reg_addr_r] <= reg_addr;
            reg_addr_r <= reg_addr_r + 1;
        end
        else
        begin
            reg_addr_r <= 5'b0;
        end
        
    end

    assign reg_init = register_file[reg_addr_r];
    assign reg_addr = reg_addr_r;

endmodule