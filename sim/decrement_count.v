module decrement_count(in, out);

input [3:0]in;

output reg [3:0]out;
always @(*)
	out = in?(in - 1):in ;

endmodule

