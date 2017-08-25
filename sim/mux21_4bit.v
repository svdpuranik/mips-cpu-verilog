
module mux21_4bit(sel, inA, inB, out);

input sel;
input [3:0] inA, inB;
output reg [3:0] out;

always @ (inA, inB, sel) begin

	if(sel) out<=inB;
	else out<=inA;
	
	end

endmodule
