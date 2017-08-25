`timescale 10 ns / 1 ps

module cpu_tb();

wire [11:0]addr_tb;
wire [15:0]dout, din_1;
wire mem_en, mem_read, mem_write;
reg clk, reset;
reg [15:0]din;

cpu cp1(.clk(clk), 
.reset(reset), 
.addr_tb(addr_tb), 
.mem_en(mem_en), 
.mem_read(mem_read), 
.mem_write(mem_write), 
.dout_cpu(dout), 
.din_cpu(din)

);
/*
memory mem1 (.clk(clk),
	     .en(mem_en),
	     .rd_en(mem_read),
	     .wr_en(mem_write),
	     .addr(addr_tb),
	     .din(dout),    //Reg_data2
	     .dout(din_1));
*/
initial begin 
	$display("\t time, \t clk, \t reset, \t din, \t addr_tb, \t mem_en, \t mem_read, \t mem_write");
	$monitor("%d, \t%b, \t%b, \t%h, \t%b, \t%b, \t%b",
         $time, clk, reset, din, mem_en, mem_read, mem_write);	
	din = 16'h0000;		
	clk = 0; 
	reset = 1; 
	
	#2 reset = 0;
	   din = 16'hb081; //din = din_1;
	#2 din = 16'haf00; //din = din_1;
	#2 din = 16'h1c3a; //din = din_1;
	#2 din = 16'h2300; //din = din_1;
	#2 din = 16'hddf6;
	#2 din = 16'he004;
	#6 $finish;
	end  

always begin
	#1 clk =!clk ;
	end


endmodule
