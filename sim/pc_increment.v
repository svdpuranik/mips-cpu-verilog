/**
Program Counter Incrementer
*/

module pc_increment(pc_current, stall, decrement, pc_next);
input [15:0] pc_current;

input stall, decrement;
output wire [15:0] pc_next;
/*
always@(*) begin
	if(stall) begin
		pc_next <= pc_current;
		//$display("PC Not Incremented");
		end
	else begin
		pc_next <= pc_current + 16'h0002;
		//$display("PC Incremented %h", pc_next);
		end
end
*/
assign pc_next = decrement?(stall?(pc_current-16'h0004):(pc_current-16'h0002)):(stall?pc_current:(pc_current + 16'h0002)); 


endmodule

