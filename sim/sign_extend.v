
module sign_extend(clk, offset, signed_value);

input clk;
input [15:0]offset;

output reg [15:0]signed_value; 

always@(posedge clk) begin
	signed_value = {offset[15], offset[15], offset[15], offset[15], offset[15:0]};
	
end

endmodule
