/**
Instruction Decode block
This block accepts instuction code as an input.
The output of the blocks are two registers in operation and an offset, if applicable.
*/
module decode(
	clk,
	data,
	reset,
	branch_flush,
	reg1,
	reg2,
	reg3,
	reg4,
	r_list,
	r_list_size,
	cond,
	offset,
	opcode,
	stall,
	count_in, 
	count_out,
	decrement,
	instr_fetch,
	branch_decode_flush,
	branch_decode_reflush
);

//inputs
input [15:0] data; //instruction code coming from Fetch block
input reset, branch_flush,  branch_decode_flush, branch_decode_reflush, clk; 
input [3:0]count_in;

//outputs
output reg [15:0] offset; //immediate value
output reg [3:0] reg1, reg2, reg3, reg4; //reg1 -> usually sp or pc or lr, reg2 -> source register, reg3 -> destination register
output reg [7:0] r_list; //register list for push and pop instructions
output reg [3:0] cond; //condtion for branching
output reg [3:0] r_list_size, count_out; //count of the registers to be pushed or popped excluding LR
output reg [4:0] opcode; //5 bit opcode
output reg stall, decrement, instr_fetch; //signal to stop PC from incrementing


localparam  PUSH = 0, POP = 1, SUB_SP = 2, CMP = 3, MOVS = 4, MOV = 5, LDR = 6, STR = 7, 
            LDR_NOP = 8, ADD_SP = 9, BRANCH_NC = 10, ADDS_3OP = 11, BRANCH_C = 12, STRB = 13, LDRB = 14, ADDS_2OP = 15, NOP = 16;


always @ (posedge clk) begin
	if(reset) begin
		reg1 <= 4'b0;
		reg2 <= 4'b0;
		reg3 <= 4'b0;
		reg4 <= 4'b0;
		r_list <= 8'b0;
		r_list_size <= 3'b0;
		cond <= 4'b0;
		offset <= 16'b0;
		opcode <= 5'b10000;
		stall <= 1'b0;
		   	//intrs_out - 1 ; mem_data_out - 0
		count_out <= 0;
		decrement <= 0;
		instr_fetch<=1;
		//display("Reset");
	end

	else if(branch_decode_flush||branch_decode_reflush) begin
		//display("DECODE DEFAULT %h", data);
		reg1 <= 4'b1111;
		reg2 <= 4'b1111;
		reg3 <= 4'b1111;
		reg4 <= 4'b1111;
		offset <= 16'b0;
		opcode <= 5'b10000;
		stall <=0;
		instr_fetch<=1;	  
		decrement <= 0;
		count_out<=count_in+1;				
		end

	else if(branch_flush) begin
		//display("DECODE DEFAULT %h", data);
		reg1 <= 4'b1111;
		reg2 <= 4'b1111;
		reg3 <= 4'b1111;
		offset <= 16'b0;
		reg4 <= 4'b1111;
		opcode <= 5'b10000;
		stall <=0;
		instr_fetch<=1;	  
		decrement <= 0;
		count_out<=count_in+1;				
		end
	
	else begin
	if(count_in) begin
		
		count_out <= count_in;
		decrement <= 0;
		stall <= 1'b1;
		//display("Count %h", count_in); 
		
		if(count_in == 1'b1) begin
			//stall <= 0;
			count_out <= 0;
			opcode <=5'b10000;
			instr_fetch<=1;
		end
		
		
	end
	
	else begin
	
	case(data[15:12]) 
				
				4'hB: begin 
					if(data[11:10]==2'b01) begin
						//PUSH r_list, lr
						//display("DECODE Push to Stack %h", data);				
						reg1 <= 4'b1110; //LR
						r_list <= data[7:0];
						//r_list_size <= r_list[0] + r_list[1] + r_list[2] + r_list[3] + r_list[4] + r_list[5] + r_list[6] + r_list[7];
						opcode <= PUSH;
						stall <=0;
						instr_fetch<=1;   
						count_out <= 0;
						decrement <= 0;
						//count_out <= r_list[0] + r_list[1] + r_list[2] + r_list[3] + r_list[4] + r_list[5] + r_list[6] + r_list[7];
					end
					else if (data[11:10]==2'b11) begin
						//POP rlist, lr
						//display("DECODE Pull from Stack");
						reg1 <= 4'b1110; //LR
						r_list <= data[7:0]; 
						//r_list_size <= r_list[0] + r_list[1] + r_list[2] + r_list[3] + r_list[4] + r_list[5] + r_list[6] + r_list[7];
						opcode <= POP;
						stall <=0;
						instr_fetch<=1; 
						count_out <= 0;
						decrement <= 0;  
						//count <= r_list[0] + r_list[1] + r_list[2] + r_list[3] + r_list[4] + r_list[5] + r_list[6] + r_list[7];
					end
					else begin
						//SUB SP,Imm
						//display("DECODE Subtract offset from Static Pointer %h", data);
						reg1 <= 4'b1101; //SP
						reg3 <= 4'b1101;
						offset <= ((data << 2) & 16'h01ff);
						opcode <= SUB_SP;
						stall <=0;
						instr_fetch<=1;      //intrs_out - 1 ; mem_data_out - 0
						count_out <= 0;
					end
				end
	
				4'h2: begin
					if(data[11]==1'b1) begin
						//CMP r3, imm
						//display("DECODE Compare Immediate");
						reg1 <= {1'b0, data[10:8]};
						offset <= {8'b0, data[7:0]};
						opcode <= CMP;
						stall <=0;
						instr_fetch<=1;   
						count_out <= 0;
					end
					else begin
						//MOVS r3, imm
						//display("DECODE Move Immediate");
						reg3 <= {1'b0, data[10:8]};
						offset <= {8'b0, data[7:0]};	
						opcode <= MOVS;		
						stall <=0;
						instr_fetch<=1;   
						count_out <= 0;
						decrement <= 0;
					end
				end
	
				4'h4: begin
					if(data[11]==1'b0) begin
						//MOV 
						//display("DECODE High Register Operation Exchange");
						if(data[9:8] == 2'b10 && data[7:6] == 2'b01) begin
							//MOV Rd, Hs
							reg1 <= 4'b0;
							reg2 <= {1'b1, data[2:0]};
							reg3 <= {1'b0, data[5:3]};
							opcode <= MOV;
							stall <=0;
							instr_fetch<=1;	   
							count_out <= 0;
						end
						else if(data[9:8] == 2'b10 && data[7:6] == 2'b10) begin
							//MOV Hd, Rs
							reg1 <= 4'b0;
							reg2 <= {1'b0, data[5:3]};
							reg3 <= {1'b1, data[2:0]};
							offset <= 16'b0;
							opcode <= MOV;
							stall <= 1'b0;
							instr_fetch<=1;   
							count_out <= 0;
						end
						else if(data[9:8] == 2'b10 && data[7:6] == 2'b11) begin
							//MOV Hd, Hs
							reg1 <= 4'b0;
							reg2 <= {1'b1,data[5:3]};
							reg3 <= {1'b1,data[2:0]};
							opcode <= MOV;
							stall <=0;
							instr_fetch<=1;   
							count_out <= 0;
						end
					end
					else begin
						//LDR r3, [pc, imm]
						//display("DECODE LDR PC Relative Load %h", data);
						reg1 <= 4'b1111; //PC
						reg3 <= {1'b0, data[10:8]};
						offset <= (data << 2) & 16'h03ff; 
						opcode <= LDR;
						stall <= 1'b1;
						count_out <= 3;
						instr_fetch<=0;   	//intrs_out - 1 ; mem_data_out - 0
						decrement <= 1;
					end
				end
					
				4'h6: begin
					
					offset <= {11'b0, data[10:6]}; 
					if(data[11]==1'b0) begin
						//STR r2, [r3, imm]
						reg1 <= {1'b0, data[5:3]};
						reg2 <= {1'b0, data[2:0]};
						reg3 <= {1'b0, data[2:0]};
						//display("DECODE Store Immediate");					
						opcode <= STR;
						stall <= 1'b0;
						instr_fetch<=0;   //For memory operaations
						count_out <= 3;
						decrement <= 1;
					end
					else begin
					//LDR(NOP) ldr r3, [r3, #0]
						reg1 <= {1'b0, data[5:3]};
						reg2 <= 4'b0;
						reg3 <= {1'b0, data[2:0]};
						//display("DECODE Load Immediate"); 
						opcode <= LDR_NOP;
						stall <=1'b1;
						instr_fetch<=0;   
						count_out <= 3;
						decrement <= 1;
					end
				end

				4'hA: //ADD_SP -> add r7, sp, imm
				begin
					//display("DECODE ADD_SP");
					reg1 <= 4'b1101; //SP
					reg3 <= {1'b0, data[10:8]};
					offset <= (data << 2) & 16'h03ff; 
					opcode <= ADD_SP;
					stall <=0;
					instr_fetch<=1;   
					count_out <= 0;	
				end

				4'hE: //branch nc
				begin
					offset <= (data[10:0] << 1) & 16'h07ff;
					opcode <= BRANCH_NC;
					//display("DECODE Unconditional Branching %h", offset);
					stall <=0;
					instr_fetch<=1;
					decrement <= 0;  
					count_out <= 2;
				end
			
				4'h1: //ADDS with 3 operands -> adds r2, r3, imm
				begin
					//display("DECODE Add with 3 operands");
					reg1 <= {1'b0, data[5:3]};
					reg3 <= {1'b0, data[2:0]};
					offset <= {13'b0, data[8:6]};
					opcode <= ADDS_3OP;
					stall <=0;
					instr_fetch<=1;   
					count_out <= 0;
				end

				4'hD: //branch c
				begin
					
					offset <= data[7]? {8'hff, (data[7:0] << 1)}:{8'h00, (data[7:0] << 1)};
					cond <= data[11:8];
					opcode <= BRANCH_C;
					//display("DECODE  Conditional Branching %h", offset);
					stall <=0;
					instr_fetch<=1;
					decrement <= 0;  
					count_out <= 2;
				end

				4'h5: begin
					reg1 <= data[8:6]; //offset register
					reg2 <= data[5:3]; //base register
					
					offset <= {8'b0, data[7:0]};
					if(data[11]==1'b0) begin
						//strb r3, [r2, r1]
						//display("DECODE Store with Register");
						opcode <= STRB;
						reg4 <= data[2:0]; //destination register
						stall <= 1'b0;
						instr_fetch<=0;   //For memory operaations
						count_out <= 3;
						decrement <= 1;
					end
					else begin
						//ldrb r3, [r3, r2]
						//display("DECODE  Load with register Offset");
						opcode <= LDRB;
						
						reg1 <= {1'b0, data[5:3]};
						reg2 <= 4'b0;
						reg3 <= {1'b0, data[2:0]};
						//display("DECODE Load Register"); 
						opcode <= LDR_NOP;
						stall <=1'b1;
						instr_fetch<=0;   
						count_out <= 3;
						decrement <= 1;
					end
				end

				4'h3: begin
					//adds with 2 operands -> add r3, imm
					//display("DECODE  Add Immediate");
					reg3 <= {1'b0,data[10:8]};
					offset <= {8'b0, data[7:0]};
					opcode <= ADDS_2OP;
					stall <=0;
					instr_fetch<=1;   
					count_out <= 0;
				end
				
				
				
				default: begin
					//display("DECODE DEFAULT %h", data);
						reg1 <= 4'b1111;
						reg2 <= 4'b1111;
						reg3 <= 4'b1111;
						offset <= 16'b0;
						opcode <= 5'b10000;
						stall <=0;
						instr_fetch<=1;	  
						decrement <= 0;
					end	
			endcase
		end		
	end
end

endmodule 