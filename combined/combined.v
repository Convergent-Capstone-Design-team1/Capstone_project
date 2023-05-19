module combined(
    input           clk				,
    input           rst				,
    input           rst_switch		,
    input           start_switch	,
    input [39:0]    btb_init		,
    input [7:0]     btb_addr		,
    input [1:0]     bht_init		,
    input [7:0]     bht_addr		,
    input [4:0]     reg_addr		,
    input [31:0]    reg_init		,
	input [31:0]	mem_addr		,
	input [31:0]	mem_init
);
	
    wire back_to_cpu;
    wire en_npu;
	wire passing;
	wire updating;
	wire [31:0] sync_addr;
	wire [31:0] sync_data;
	wire [31:0] wb_addr;
	wire [31:0] wb_data;

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
		.npu_addr(wb_addr)			,
		.npu_data(wb_data)			,
		.npu_we(updating)			,

		//OUTPUT
		.toss_npu(en_npu)			,
		.sync_wr(passing)			,
		.sync_addr(sync_addr)		,
		.sync_data(sync_data)
	);

	npu DUT_NPU
	(
		//INPUT
		.clk(clk)					,
		.rst(rst_switch)			,
		.en(en_npu)					,
		.get_wr(passing)			,
		.get_data(sync_data)		,
		.get_addr(sync_addr)		,
		.mem_addr(mem_addr)			,
		.mem_init(mem_init)			,

		//OUTPUT
		.pass_we(updating)			,
		.ack(back_to_cpu)			,
		.modified_addr(wb_addr)		,
		.modified_data(wb_data)
	);

endmodule

