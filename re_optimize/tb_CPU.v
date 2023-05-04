`timescale  1ns / 100ps 
module tb_CPU();

	reg 	rst, clk;
	integer i;
	reg [1:0] sw;
	reg [31:0] val0 = 32'd1;
	reg [31:0] val1 = 32'd2;
	reg [31:0] val2 = 32'd3;
	reg [31:0] val3 = 32'd4;
	reg [31:0] val4 = 32'd5;
	reg [31:0] val5 = 32'd6;
	reg [31:0] val6 = 32'd7;
	reg [31:0] val7 = 32'd8;
	reg [31:0] val8 = 32'd9;
	reg [31:0] val9 = 32'd1;
	reg [31:0] val10 = 32'd2;
	reg [31:0] val11 = 32'd3;
	reg [31:0] val12 = 32'd4;
	reg [31:0] val13 = 32'd5;
	reg [31:0] val14 = 32'd6;
	reg [31:0] val15 = 32'd7;
	reg [31:0] val16 = 32'd8;
	reg [31:0] val17 = 32'd9;
	reg [31:0] val18 = 32'd0;
	reg [31:0] val19 = 32'd0;
	reg [31:0] val20 = 32'd0;
	reg [31:0] val21 = 32'd0;
	reg [31:0] val22 = 32'd0;
	reg [31:0] val23 = 32'd0;
	reg [31:0] val24 = 32'd0;
	reg [31:0] val25 = 32'd0;
	reg [31:0] val26 = 32'd0;
	
  	TOPCPU CPU 
	(
		.clk(clk),
		.rst(rst),
		.sw(sw)	 ,
		.axi_val0(val0),
		.axi_val1(val1),
		.axi_val2(val2),
		.axi_val3(val3),
		.axi_val4(val4),
		.axi_val5(val5),
		.axi_val6(val6),
		.axi_val7(val7),
		.axi_val8(val8),
		.axi_val9(val9),
		.axi_val10(val10),
		.axi_val11(val11),
		.axi_val12(val12),
		.axi_val13(val13),
		.axi_val14(val14),
		.axi_val15(val15),
		.axi_val16(val16),
		.axi_val17(val17),
		.axi_val18(val18),
		.axi_val19(val19),
		.axi_val20(val20),
		.axi_val21(val21),
		.axi_val22(val22),
		.axi_val23(val23),
		.axi_val24(val24),
		.axi_val25(val25),
		.axi_val26(val26)
	);

	always #50 clk = ~clk;
	
	initial 
	begin
		$dumpfile("test.vcd");
		$dumpvars(0, tb_CPU);
		sw = 2'b10;
		rst = 0;
		clk = 0;
		#200
		sw = 2'b01;
		rst = 1;
		#200
		rst = 0;
		
		#150000
		rst = 1; 
		$finish;
	end

endmodule

