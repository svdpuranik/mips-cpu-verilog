module demux12(in, sel, outA, outB);
input [15:0]in;
input sel;
output [15:0] outA, outB;

assign outA = (~sel)?in:16'h0000;
assign outB =  (sel)?in:16'h0000;
/*always @(in) begin
	if(sel)
		outB <= in; 
   else 
      		outA <= in;
   end*/
endmodule
