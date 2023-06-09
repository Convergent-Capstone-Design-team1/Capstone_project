`timescale  1ns / 100ps 
module tb_combined();

	reg 	rst, clk;

	//FPGA Swtich
	reg		start_switch;
	reg		init_switch;
	reg		rst_switch;

	//BTB
	wire	[7:0]	btb_addr;
	wire	[39:0]	btb_init;
	//BHT
	wire	[7:0]	bht_addr;
	wire	[1:0]	bht_init;
	//REGISTER_FILE
	wire	[4:0]	reg_addr;
	wire	[31:0]	reg_init;
	//MEMORY DATA
	wire	[31:0]	mem_addr;
	wire	[31:0]	mem_init;

	wire			en_npu;
	wire			back_to_cpu;

	integer i;

	combined DUT_combined
	(
		.clk(clk)					,
		.rst(rst)					,	
		.rst_switch(rst_switch)		,
		.start_switch(start_switch)	,
		.btb_init(btb_init)			,
		.btb_addr(btb_addr)			,
		.bht_init(bht_init)			,
		.bht_addr(bht_addr)			,
		.reg_addr(reg_addr)			,
		.reg_init(reg_init)			,
		.mem_addr(mem_addr)			,
		.mem_init(mem_init)
	);

	INITIAL_MODULE INITIAL_MODULE
	(	
		//INPUT
		.clk(clk)					,
		.rst_i(init_switch)			,

		//OUTPUT
		.btb_init(btb_init)         ,
   		.btb_addr(btb_addr)         ,
    	.bht_init(bht_init)         ,
  		.bht_addr(bht_addr)         ,     
    	.reg_addr(reg_addr)         ,
    	.reg_init(reg_init)			,
		.mem_addr(mem_addr)			,
		.mem_init(mem_init)
	);

	
	always #2.5 clk = ~clk;
	
	initial	begin
		$dumpfile("test.vcd");
		$dumpvars(0, tb_combined);

		rst = 1'b0;
		clk = 1'b0;
		init_switch = 1'b0;
		rst_switch = 1'b0;
		start_switch = 1'b0;

		#50
		rst_switch = 1'b1;
		init_switch = 1'b1;
		
		#150
		init_switch = 1'b0;
		
		#5000
		rst_switch = 1'b0;

		#150
		rst = 1'b1;
		start_switch = 1'b1;
		
		#500
		rst = 1'b0;
		
		#10000
		rst = 1'b1; 
		$finish;
	end

endmodule

