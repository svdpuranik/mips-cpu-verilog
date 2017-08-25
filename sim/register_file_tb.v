`timescale 10ns/1ns

module register_file_tb();

wire signed [15:0]data_regA, data_regB;
reg signed [15:0]in_data;
reg [3:0]regA, regB, wrreg;
reg WE, clk;

register_file R1(.clock(clk),
					  .WE(WE),
					  .InData(in_data),
				     .WrReg(wrreg),
					  .ReadA(regA),
					  .ReadB(regB),
					  .OutA(data_regA),
					  .OutB(data_regB)
);

initial begin
	in_data = 0;
	WE =0;
	wrreg = 0;
	regA = 1;
	regB = 2;
	clk=0;
end

always@(*)
	#5 clk <= !clk ;

always@(posedge clk) begin
   $monitor("OutA: %h OutB: %h", data_regA, data_regB);
	in_data = 10;
   WE=1;
   wrreg = 1;
   regA = 1;
   regB = 2;
	#10;
	in_data = -200;
   WE=1;
   wrreg = 2;
   regA = 1;
   regB = 2;
	
	#10;
   in_data = -200;
   WE=0;
   
   regA = 1;
   regB = 2;
	
	#10;

end






endmodule