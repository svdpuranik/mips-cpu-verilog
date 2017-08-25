//Counter Register

module counter(clk, rst, in, out);

input clk, rst;
input [3:0] in;
output reg [3:0] out;


always @(posedge clk) begin
	if(rst) begin
		out <= 4'h0;
		$display("Counter Reset");
		end
	else out <= in; 
	end

endmodule
