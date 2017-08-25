module branch(reset, pc, Imm_val, branch, branch_con, pc_branch);

input [15:0]pc, Imm_val;
input branch, reset, branch_con;

output reg [15:0]pc_branch;

always@(*) begin
	if(reset)
		pc_branch = 16'h0000;
	else begin
		if(branch)begin
			if(branch_con)
				pc_branch = pc-6;
			else 
				pc_branch = pc + Imm_val-4;
			//$display("inside Branch %h %h %h", pc, Imm_val, pc_branch);
		end
		else begin
			pc_branch = pc;
			//$display("No Branch %h",pc_branch);
		end
	end
end

endmodule
