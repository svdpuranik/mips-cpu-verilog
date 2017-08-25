`timescale 10ns/1ns

module sign_extend_tb();

reg clk;
reg [11:0]offset;
wire [15:0]value;

sign_extend ex1(.clk(clk), 
					 .offset(offset),
					 .signed_value(value) 
);

initial begin
clk=0;
end

always@(*)
	#5 clk <= !clk ;

always@(posedge clk) begin
	$monitor("offset: %h Signed Value: %h", offset, value);
	offset = 10;
	#20;
	offset = -64;
	#20;
	offset = 34;
	#20;
	
end

endmodule


