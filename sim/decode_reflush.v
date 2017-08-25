module decode_reflush (clk, rst, rst_branch_flush, branch_decode_reflush);

input clk, rst, rst_branch_flush;
output  reg branch_decode_reflush;

always @(posedge clk) begin

	if(rst) branch_decode_reflush<=1'b0; 
	else begin
		if(rst_branch_flush) branch_decode_reflush<=1'b1;
		else branch_decode_reflush<=1'b0;
	end

end

endmodule
