`timescale 10ns/1ns

module control_block_tb();

reg rst;
reg [3:0]opcode;

wire [3:0]ALU_op;
wire mem_reg, reg_write;  //Select the appropriate Memory for Register Selection and Address Selection
wire branch, mem_read, mem_write, mem_enable; // 
wire ALU_src, reg_dst, Intr_fetch;

control_block cbk1( 
		   .rst(rst), 
		   .opcode(opcode), 
		   .mem_reg(mem_reg), 
		   .reg_write(reg_write), 
		   .branch(branch), 
		   .mem_read(mem_read), 
		   .mem_write(mem_write), 
		   .mem_enable(mem_enable), 
                   .ALU_op(ALU_op), 
                   .ALU_src(ALU_src), 
                   .reg_dst(reg_dst), 
                   .Intr_fetch(Intr_fetch));


initial begin
rst = 1;
opcode = 0;
end

initial begin
	$monitor(" %d     %b    %b       %b        %b       %b        %b        %b         %b         %b       %b      %b       %b  ", 
                 $time, rst, opcode, mem_reg, reg_write, branch, mem_read, mem_write, mem_enable, ALU_op, ALU_src, reg_dst, Intr_fetch);
	#5
        rst =0;
	opcode = 9;
	#10;
	opcode = 10;
	#10;
	opcode = 11;
	#10;
	opcode = 12;
	#10;
	$finish;
end


endmodule
