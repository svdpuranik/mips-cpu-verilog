//Accumulator Buffer Register

module accumulator(rst, clk, branch, write_in, write_out, wr_in, wr_out, in, out, mem_regin ,mem_regout);

input clk, rst, branch; 
input [15:0] in;
output reg [15:0] out;



input write_in, mem_regin;
output reg write_out, mem_regout;

input [3:0]wr_in;
output reg [3:0]wr_out;

always @(posedge clk) begin
	if(rst||branch) begin
		out <= 16'h0000;
		wr_out <= 4'b0000;
		write_out <= 1'b0;
		mem_regout <= 1;
		$display("ACC Reset-Flush");
		end
	else begin
		out <= in;
		wr_out <= wr_in;
		write_out <= write_in;
		mem_regout <= mem_regin;
		$display("ACCU OutData:%h  WriteReg:%h  WriteEn:%b Mem_reg: %b",out,wr_out,write_out, mem_regout);
	end 
	end

endmodule

