// Integrated Electronic Systems Lab
// TU Darmstadt
// Author:	Dipl.-Ing. Boris Traskov
// Modified by M.Sc. Haoyuan Ying Dual 8-bit Memory Port -> Single 16-bit
// Email: 	boris.traskov@ies.tu-darmstadt.de

`timescale 1 ns / 1 ps

module testbench();

// PARAMETERS
parameter MEM_DEPTH   		= 2**12;	//8192 Bytes 4096*2B
parameter ADDR_WIDTH   		= $clog2(MEM_DEPTH);
parameter string filename	= "/home/vhdlp7/Desktop/HDL_Lab/sources/software/count32.bin";

// INTERNAL SIGNALS
integer file, status; // needed for file-io
logic			clk;
logic			rst;
logic			en;
logic			rd_en;
logic  			wr_en;
logic [15:0]	data_cpu2mem;
logic [15:0]	data_mem2cpu;
logic [ADDR_WIDTH-1:0] addr;

//assign en	= 1'b1;
//assign rd_en	= 1'b1;
//assign wr_en	= 1'b0;

//CPU INSTANTIATION
cpu cpu_i (
    .clk 	(clk),
    .reset 	(rst),
    .addr_tb	(addr),
    .en (en),
    .rd_en (rd_en),
    .wr_en (wr_en),
    .dout_cpu (data_cpu2mem),
    .din_cpu (data_mem2cpu)
);

// MODULE INSTANTIATION
memory #(
	.MEM_DEPTH (MEM_DEPTH)) 
memory_i (
    .clk  (clk),
    .addr	(addr),
    .en  	(en),
    .rd_en  (rd_en),
    .wr_en  (wr_en),
    .din (data_cpu2mem),
    .dout(data_mem2cpu));
  
//CLOCK GENERATOR

initial begin
	clk = 1'b0;
	forever #1  clk = !clk;
end

//RESET GENERATOR  
initial begin	
   	rst		= 1'b0;
	file		= $fopen(filename, "r");
	#3 rst		= 1'b1;     // 3   ns
	status		= $fread(memory_i.ram, file);
	#2.1 rst	= 1'b0;  //2.1 ns
	//$monitor("%b %h %h  %h", clk, addr, data_mem2cpu, data_cpu2mem);
	//$finish
end

endmodule
