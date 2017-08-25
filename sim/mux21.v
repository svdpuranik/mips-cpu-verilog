/**
2:1 Multiplexer for Program Counter
*/

module mux21 (in0, in1, select, out);
input [15:0] in0, in1;
input select;
output wire [15:0] out;

assign out = select? in1 : in0;

endmodule
