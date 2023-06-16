module INITIAL_MODULE
(
    input       clk             ,
    input       rst_i           ,

    output  [39:0]  btb_init    ,
    output  [7:0]   btb_addr    ,

    output  [1:0]   bht_init    ,
    output  [7:0]   bht_addr    ,

    output  [31:0]  reg_init    ,    
    output  [4:0]   reg_addr    ,
    output  [31:0]  mem_init    ,    
    output  [31:0]  mem_addr
);

    reg [31:0] 	register_file [0:31];
    reg [31:0]  btb [0:255];
    reg [1:0]   bht [0:255];
    reg [31:0]  mem [0:26];
    reg [31:0]  mem_init;

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

    // Memory initilization
    reg [5:0] mem_addr_r;
    always @ (posedge clk)
    begin
        if (rst_i) begin
            mem_addr_r <= 6'b0;
        end
        else if (mem_addr_r <= 6'd63) begin
            case(mem_addr_r)
                6'd0 : mem_init <= 4;
                6'd1 : mem_init <= 7;
                6'd2 : mem_init <= 2;
                6'd3 : mem_init <= 4;
                6'd4 : mem_init <= 1;
                6'd5 : mem_init <= 8;
                6'd6 : mem_init <= 4;
                6'd7 : mem_init <= 2;
                6'd8 : mem_init <= 6;
                6'd9 : mem_init <= 9;
                6'd10 : mem_init <= 3;
                6'd11 : mem_init <= 1;
                6'd12 : mem_init <= 4;
                6'd13 : mem_init <= 2;
                6'd14 : mem_init <= 5;
                6'd15 : mem_init <= 8;
                6'd16 : mem_init <= 5;
                6'd17 : mem_init <= 2;
                6'd18 : mem_init <= 6;
                6'd19 : mem_init <= 9;
                6'd20 : mem_init <= 2;
                6'd21 : mem_init <= 4;
                6'd22 : mem_init <= 8;
                6'd23 : mem_init <= 1;
                6'd24 : mem_init <= 4;
                6'd25 : mem_init <= 7;
                6'd26 : mem_init <= 9;
                6'd27 : mem_init <= 4;
                6'd28 : mem_init <= 3;
                6'd29 : mem_init <= 6;
                6'd30 : mem_init <= 1;
                6'd31 : mem_init <= 9;
                6'd32 : mem_init <= 4;
                6'd33 : mem_init <= 7;
                6'd34 : mem_init <= 2;
                6'd35 : mem_init <= 5;
                6'd36 : mem_init <= 3;
                6'd37 : mem_init <= 8;
                6'd38 : mem_init <= 2;
                6'd39 : mem_init <= 9;
                6'd40 : mem_init <= 1;
                default : mem_init <= 0;

            endcase
            mem_addr_r <= mem_addr_r + 1;
        end
        else begin
            mem_addr_r <= 6'b0;
        end
    end
    assign mem_addr = {26'b0, mem_addr_r};

endmodule