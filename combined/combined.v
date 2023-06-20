module combined
(
    input           clk				,
    input           rst				,
    input           rst_switch		,		// FPGA buttons
    input           start_switch	,
    input [39:0]    btb_init		,		// initial datas come from initial module
    input [7:0]     btb_addr		,
    input [1:0]     bht_init		,
    input [7:0]     bht_addr		,
    input [4:0]     reg_addr		,
    input [31:0]    reg_init		,
	input [31:0]	mem_addr		,
	input [31:0]	mem_init
);
	
    wire back_to_cpu;						// notice CPU that NPU has finished operations
    wire EN_NPU;
	wire clk_50_w;							// delayed clk for memory
	wire mem_rd_w;							// CPU read/write data from NPU's memory
	wire mem_wr_w;							

	wire cycle1;							// delayed EN_NPU signals
	wire cycle2;
	wire cycle3;
	wire [9:0] 	mat_src1;					// NPU refer to these mem addrs
	wire [9:0] 	mat_src2;
	wire [9:0] 	mat_rd;
	wire [31:0] addr_w;						// CPU read/write data from NPU's memory.
	wire [31:0] wd_w;
	wire [31:0] data_w;

  	TOPCPU DUT_CPU 
	(
		//INPUT	
		.clk(clk)					,
		.rst(rst)					,	
		.rst_switch(rst_switch)		,
		.start_switch(start_switch)	,
		.btb_init(btb_init)         ,
   		.btb_addr(btb_addr)         ,
    	.bht_init(bht_init)         ,
  		.bht_addr(bht_addr)         ,     
    	.reg_addr(reg_addr)         ,
    	.reg_init(reg_init)			,
		.mem_init_addr(mem_addr)	,
		.mem_init_data(mem_init)	,
		.acquire_npu(back_to_cpu)	,
		.R_DATA(data_w)				,
		.mem_haz(race)				,

		//OUTPUT
		.EN_NPU(EN_NPU)				,
		.clk_50(clk_50_w)			,
		.memread_c(mem_rd_w)		,
		.memwrite_c(mem_wr_w)		,
		.addr_c(addr_w)				,
		.wd_c(wd_w)					,
		.matA(mat_src1)				,
		.matB(mat_src2)				,
		.matC(mat_rd)
	);

	REGISTER #(1) calc_src_addr1
    (
        .CLK(clk_50_w)      ,
        .RST(rst)           ,
        .EN(1'b0)           ,
        .D(EN_NPU)       	,
        .Q(cycle1)
    );

    REGISTER #(1) calc_src_addr2
    (
        .CLK(clk_50_w)      ,
        .RST(rst)           ,
        .EN(1'b0)           ,
        .D(cycle1)   		,
        .Q(cycle2)
    );

    REGISTER #(1) calc_src_addr3
    (
        .CLK(clk_50_w)      ,
        .RST(rst)           ,
        .EN(1'b0)           ,
        .D(cycle2)   		,
        .Q(cycle3)
    );

	npu DUT_NPU
	(
		//INPUT
		.clk(clk)					,
		.rst(rst_switch)			,
		.en(cycle3 && EN_NPU)		,		// NPU is triggered by cycle3, not EN_NPU. 3 cycle delay enables to find out the mem addr to calculate with.
		.mem_addr(mem_addr)			,
		.mem_init(mem_init)			,
		.src1_addr(mat_src1[9:2])	,
		.src2_addr(mat_src2[9:2])	,
		.rd_addr(mat_rd[9:2])		,

		//OUTPUT
		.ack(back_to_cpu)			,

		//ports due to shared memory system
		.clk_50(clk_50_w)			,
		.MEMRead(mem_rd_w)			,
		.MEMWrite(mem_wr_w)			,
		.ADDR(addr_w)				,
		.WD(wd_w)					,
		.RD(data_w)
	);

endmodule
