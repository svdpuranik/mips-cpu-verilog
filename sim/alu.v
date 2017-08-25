
module alu(clk, rst, branch, opcode, inA, inB, inC, in_apsr, in_pc, wreg_loc_in, wreg_en_in, mem_reg_in, instr_fetch_in,
	   out, out_apsr, wreg_loc_out, wreg_en_out, mem_reg_out, branch_con, instr_fetch_out, reg_dst_in, reg_dst_out, 
           mem_read_in, mem_read_out, mem_write_in,mem_write_out, rst_branch_flush, branch_flush, offset_in, offset_out,
	   cmp_r_in, cmp_r_out, regdata2_in,regdata2_out);

input clk, rst, branch, rst_branch_flush, wreg_en_in, mem_reg_in, instr_fetch_in, reg_dst_in, mem_read_in, mem_write_in, cmp_r_in;
input [4:0] opcode;
input [3:0] wreg_loc_in, in_apsr;
input [15:0] inA, inB, inC, in_pc, offset_in, regdata2_in;

output reg cmp_r_out;
output reg [15:0] out, offset_out,regdata2_out;
output reg [3:0] wreg_loc_out,out_apsr;
output reg branch_con, wreg_en_out, mem_reg_out, instr_fetch_out, reg_dst_out, mem_read_out, mem_write_out, branch_flush; 


localparam  push=0, pop=1, sub_sp=2, cmp=3, movs=4, mov=5, ldr=6, str=7, 
            ldr_nop=8, add_sp=9, branch_nc= 10, adds_3op=11, branch_c=12, strb=13, ldrb=14, adds_2op=15, NOP = 16;

//Local registers
reg instr_flag;



`define in_overflow in_apsr[0]
`define in_carry in_apsr[1]
`define in_zero in_apsr[2]
`define in_negative in_apsr[3]


`define out_overflow out_apsr[0]
`define out_carry out_apsr[1]
`define out_zero out_apsr[2]
`define out_negative out_apsr[3]

always @(posedge clk) begin   
	

	if(rst) begin
		out <= 16'h0000;
		wreg_loc_out <= 4'b0000;
		wreg_en_out <= 1'b0;
		mem_reg_out <= 1;
		instr_fetch_out<=1;
		branch_con <= 1'b0;
		reg_dst_out <= 0;
		mem_read_out <= 1;
		mem_write_out <= 0;
		branch_flush <= 1'b0;
		offset_out<=0;
		cmp_r_out <= 0;	
		instr_flag <=0;
		//$display("ALU RESET/FLUSH");
		`out_zero<= 0;
		`out_overflow <= 0;
		`out_negative <= 0;
		`out_carry <= 0 ;
		regdata2_out <= 0;
		end
	
	else if(~rst_branch_flush) begin
		branch_flush <= 1'b0;
		`out_zero<= `in_zero;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_carry <= `in_carry ;
		regdata2_out <= 0;
		
		end
	
	else begin
		instr_fetch_out<=instr_fetch_in;
		wreg_loc_out <= wreg_loc_in;
		wreg_en_out <= wreg_en_in;
		mem_reg_out <= mem_reg_in;
		reg_dst_out <= reg_dst_in;
		mem_read_out <= mem_read_in;
		mem_write_out <= mem_write_in;
		offset_out<=offset_in;
		
	case(opcode)
	push: begin //inA<= Stack Pointer  
		out <= inA - 1;
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ; 
		//$display("ALU PUSH");
		branch_flush <= branch;
		regdata2_out <= regdata2_in;
		branch_con <= 1'b0;
	      end 

	pop: begin
		//SP increment 
		out <= inA + 1;
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ; 
		//$display("ALU POP");
		branch_flush <= branch;
		regdata2_out <= regdata2_in;
		//SP increase by 2 as registers both are being poped
		branch_con <= 1'b0;
	     end

	sub_sp: begin
//		 out <= inA - inB;
		 //if(out<=<=0) `out_zero <= 0;
		out <= inA - inB ; 
		if(~out) `out_zero <= 1'b1 ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_carry <= `in_carry ;
		////$display("ALU SUB inA: %h  inB: %h out:%h", inA, inB, out);
		branch_flush <= branch;
		regdata2_out <= regdata2_in;
		branch_con <= 1'b0;
	     end
	
	add_sp: begin
		{`out_overflow, out} <= inA + inB; 
		////$display("ALU ADD inA: %h inB: %h out:%h WriteReg:%h  WriteEn:%b Mem/Reg: %b", inA, inB, out, wreg_loc_out, wreg_en_out, mem_reg_out);
	     	branch_flush <= branch;
		regdata2_out <= regdata2_in;
		end
   
        adds_2op: begin
		{`out_overflow, out} <= inA + inB; 
		//$display("ALU ADD 2OP inA: %h  inB: %h out:%h", inA, inB, out);
		branch_flush <= branch;
		regdata2_out <= regdata2_in;
	     end
      
        adds_3op: begin
		{`out_overflow, out} <= inA + inB; 
		//$display("ALU ADD inA: %h  inB: %h out:%h", inA, inB, out);
		branch_flush <= branch;
		regdata2_out <= regdata2_in;	
	     end
       
	cmp: begin
		regdata2_out <= regdata2_in;
		 if(inA-inB) begin
			 out_apsr[2] <= 1'b1 ;
			 cmp_r_out<=1'b0;
			$display("Not Equal ZF= %b", out_apsr[2]);
			end
		 else begin
		out_apsr[2] <= 0 ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_carry <= `in_carry ;
		cmp_r_out<=1'b1;
		end
		branch_flush <= branch;
		branch_con <= 1'b0;
		//$display("CMP inA<=%h inB<=%h out<=%h ZF=%b",inA, inB, out, out_apsr[2]);
	     end
	
	str: begin
		if(~instr_flag) begin
			out<=inA+inB;
			instr_flag <= 1;
			regdata2_out <= regdata2_in;
		end
		else begin
			out <= inA+inB+2;
			instr_flag <= 0;
			regdata2_out <= 16'h0000;
		end
		//$display("ALU STORE inA<=%h inB<=%h out<=%h WriteReg:%h  WriteEn:%b Mem/Reg: %b", inA, inB, out, wreg_loc_out, wreg_en_out, mem_reg_out);
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
	     end


	ldr: begin
		//out<=in_pc+inB+4;
		regdata2_out <= regdata2_in;
		if(~((in_pc+inB)%4 == 0)) begin
			out <= in_pc+inB+2;
			$display("LDR: Out Value: %h", out);
		end
		else begin
		out<=in_pc+inB+4;
		//$display("ALU LDR PC inA: %h inB: %h out:%h WriteReg:%h  WriteEn:%b Mem/Reg: %b", inA, inB, out, wreg_loc_out, wreg_en_out, mem_reg_out);
		end
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
	     end
	ldr_nop: begin
		regdata2_out <= regdata2_in;
		out<=inA+inB;
		//$display("ALU LDR Imm(NOP) inA: %h inB: %h out:%h WriteReg:%h  WriteEn:%b Mem/Reg: %b", inA, inB, out, wreg_loc_out, wreg_en_out, mem_reg_out);
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
	     end
	branch_c: begin
		regdata2_out <= regdata2_in;	
		if(~cmp_r_in) begin
			cmp_r_out<=1'b0;
			branch_con <= 1'b1;
			branch_flush <= branch;
		//$display("ALU Con Satis inA: %h out:%h ZF:%b  Branch_Con: %b", inA, out, in_apsr[2] , branch_con);
			//out_apsr[2]<= 1'b0;
			
			`out_overflow <= `in_overflow ;
			`out_negative <= `in_negative ;
			`out_carry <= `in_carry ;
		end
                else begin 
		branch_con <= 1'b0;
		branch_flush <= branch;
		`out_zero<= `in_zero;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_carry <= `in_carry ;
		//$display("ALU Con NSatis inA: %h out:%h ZF:%b  Branch_Con: %b", inA, out, `in_zero, branch_con);
	     	
		end
		out <= 0;
		end

	branch_nc: begin
		regdata2_out <= regdata2_in;
		branch_flush <= branch;
		`out_zero<= `in_zero;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_carry <= `in_carry ;
	    end

	movs: begin
		regdata2_out <= regdata2_in;
		out<= inB;
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
		//$display("ALU MOVS inA: %h  inB: %h out:%h", inA, inB, out);
	     end

	mov: begin
		regdata2_out <= regdata2_in;
		out<= inA;
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
		//$display("ALU MOV inA: %h  inB: %h out:%h", inA, inB, out);
	end

	strb: begin
		if(~((inA+inB)%2)) begin	// Check for even location
			out<= inA+inB;
		end
		else begin
			out <= inA+inB-1;	//NOP for odd location
		end
		regdata2_out <= inC;
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
	     end


	ldrb: begin
		
		regdata2_out <= regdata2_in;
		if(((inA+inB)%2)) begin
			out <= inA+inB;
		end
		else begin
		out<=inA+inB-1;
		end
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		branch_flush <= branch;
	     end
default:
	begin
		branch_con <= 0;
		branch_flush <= 0;
		`out_carry <= `in_carry ;
		`out_overflow <= `in_overflow ;
		`out_negative <= `in_negative ;
		`out_zero <= `in_zero ;
		regdata2_out <= regdata2_in;
	end
	endcase
	end
end 

endmodule
