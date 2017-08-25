`timescale 1 ns / 100 ps
module decode_tb;

reg reset, branch;
reg [15:0]data;
reg clk;

wire [15:0] offset;
wire [3:0] reg1, reg2, reg3;
wire [4:0] opcode;
wire [7:0] r_list;
wire [3:0] cond;
wire [3:0] r_list_size;
wire stall;

decode d1 (
	.clk(clk),
	.branch(branch),
	.data(data),
	.reset(reset),
	.reg1(reg1),
	.reg2(reg2),
	.reg3(reg3),
	.r_list(r_list),
	.r_list_size(r_list_size),
	.cond(cond),
	.offset(offset),
	.opcode(opcode),
	.stall(stall)
);

initial begin
	reset = 1'b1;
	data = 16'b0;


	$display ("\t\t\t\t time\t reset\t data\t offset\t reg1\t reg2\t reg3\t opcode\t r_list\t r_list_size\t cond\t");
	$monitor(" %d     %b     %h       %b        %b       %b        %b        %b          %b        %b   ", 
                 $time, reset, data, offset, reg1, reg2, reg3, opcode, r_list, r_list_size, cond);
	
	#5 reset = 1'b0;
	data = 16'hB580;
	#10 data = 16'hAF02;
	#10 data = 16'h4A08;
	#10 data = 16'h2300;
	#10 data = 16'h6013;
	#10 data = 16'hE004;
	#10 data = 16'h4B06;
	#10 data = 16'h681B;
	#10 data = 16'h1C5A;
	#10 data = 16'h4B05;
	#10 data = 16'h601A;
	#10 data = 16'h4B04;
	#10 data = 16'h681B;
	#10 data = 16'h2B1F;
	#10 data = 16'hDDF6;
	#10 data = 16'h2300;
	#10 data = 16'h1C18;
	#10 data = 16'h46BD;
	#10 data = 16'hB082;
	#10 data = 16'hBD80;
	#10 $finish;	
	
end

endmodule
