//APSR Register

module apsr(rst, clk, in, out);

input clk, rst;
input [3:0] in;
output reg [3:0] out;


always @(posedge clk) begin
	if(rst) begin
		out <= 0;
		$display("APSR Reset");
		end
	else out <= in; 
	end

endmodule
