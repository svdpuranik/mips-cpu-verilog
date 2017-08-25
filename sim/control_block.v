module control_block(clk, rst, opcode, mem_reg, reg_write, branch, mem_read, mem_write, mem_enable, instr_fetch_in,
                     ALU_op, ALU_src, reg_dst, offset, offset_val, reg3_addin,reg3_addout, instr_fetch_out, branch_flush, branch_decode_flush);

input [4:0] opcode;
input rst, clk, instr_fetch_in, branch_flush;
input [15:0]offset;
input [3:0] reg3_addin;

output reg [4:0]ALU_op;
output reg mem_reg, reg_write;  //Select the appropriate Memory for Register Selection and Address Selection
output reg branch, mem_read, mem_write, mem_enable; // 
output reg ALU_src, reg_dst, instr_fetch_out, branch_decode_flush;
output reg [15:0]offset_val;
output reg [3:0] reg3_addout;


localparam  push=0,    pop=1,    sub_sp=2,      cmp=3,       movs=4,      mov=5,   ldr=6,   str=7, 
            ldr_nop=8, add_sp=9, branch_nc= 10, adds_3op=11, branch_c=12, strb=13, ldrb=14, adds_2op=15, NOP = 16;

always @(posedge clk) begin

	
	if(rst) begin
			//$display("Reset %d:", opcode);
       			//Set the Control Block
			mem_reg    <= 0;   // Take Data from the ALU
			reg_write  <= 0;   // Write to Register
			branch     <= 0;   //
			mem_read   <= 1;   //
			mem_write  <= 0;   //
			mem_enable <= 1;
			ALU_op     <= opcode;
			ALU_src    <= 0;   // For Reg_data_2
			reg_dst    <= 0;   // Register_Destination	- To mux for selection of Destination Register  
			offset_val <= 0;
			reg3_addout <= 0;
			instr_fetch_out<=1;
			branch_decode_flush <= 1'b0;
   		end
	
	else if(branch_flush) begin
			/*mem_reg    <= 1;   // Take Data from the ALU
			reg_write  <= 0;   // 
			branch     <= 0;   //
			mem_read   <= 1;   //
			mem_write  <= 0;   //
			mem_enable <= 1;
			ALU_op     <= 5'b10000;
			ALU_src    <= 1;   // For Reg_data_2
			reg_dst    <= 1;   // Register_Destination*/
			//if(~count_out) Intr_fetch <= 1;
			branch_decode_flush <= 1'b0;	
		end
				
	else begin
		//if(clk) begin
			reg3_addout<=reg3_addin;
			offset_val<=offset;	
			instr_fetch_out<=instr_fetch_in;		
			//if(~count_out) 	Intr_fetch <= 1;
		//$display("CONTROL BLOCK NOP %d %d", count_in, count_out);				
		case(opcode)
			push: begin
					//$display("CONTROL BLOCK Push:%d", opcode);		
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU
					reg_write  <= 0;   // Write to SP to Register-13
					branch     <= 0;   //
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;
					ALU_op     <= opcode;
					ALU_src    <= 0;   // For Reg_data_2
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
		   		end
      			add_sp: begin
				   //Set the Control Block
					//$display("Add :%d", opcode);
					mem_reg    <= 1;   // Take Data from the ALU
					reg_write  <= 1;   // Write to Register
					branch     <= 0;   //
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3 
				   	branch_decode_flush<=1'b0;
				end 
	   		pop:begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU
					reg_write  <= 1;   // Write to SP to Register-13
					branch     <= 0;   //
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;
					ALU_op     <= opcode;
					ALU_src    <= 0;   // For Reg_data_2
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
					 //to be changed to 1
					//count_out <= count_in;
				end
			sub_sp:begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 1;   // Write to SP to Register-13
					branch     <= 0;   //
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For reg_dat2 - 0; Immediate Value - 1
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end
			cmp:begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 0;   // No write needed to memory
					branch     <= 0;   // 
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end	
			movs:begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 1;   // write needed to memory
					branch     <= 0;   // 
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end	

			branch_c:begin
					//Set the Control Block
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 0;   // write needed to register file
					branch     <= 1;   // Branching needed
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
					branch_decode_flush <= 1'b1;
				   	
					//$display("Inside Branch C");
				end

			mov:begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 1;   // write needed to register file
					branch     <= 0;   // 
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 0;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end	
	
			ldr:begin
					//Set the Control Block
					mem_reg    <= 0;   // Take Data from the memory for writing
					reg_write  <= 1;   // write needed to register file
					branch     <= 0;   // No branching
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
					
				end
			
			str:begin
					//Set the Control Block
					mem_reg    <= 0;   // Take Data from the ALU for writing
					reg_write  <= 0;   // write needed to register file
					branch     <= 0;   // 
					mem_read   <= 0;   //
					mem_write  <= 1;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
					
				end
			
			branch_nc:begin
					//$display("Inside Branch NC");
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 0;   // write needed to register file
					branch     <= 1;   // Branching needed
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
					branch_decode_flush <= 1'b1;
				   	
				end

			ldr_nop:begin
					//Set the Control Block
					mem_reg    <= 0;   // Take Data from the memory for writing
					reg_write  <= 1;   // write needed to register file
					branch     <= 0;   // No branching
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
					
				end

			adds_3op:begin
					//Set the Control Block
					//$display("Add :%d", opcode);
					mem_reg    <= 1;   // Take Data from the ALU
					reg_write  <= 1;   // Write to Register
					branch     <= 0;   //
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3 
				   	branch_decode_flush<=1'b0;
				end
			strb:begin
					//Set the Control Block
					mem_reg    <= 0;   // Take Data from the ALU for writing
					reg_write  <= 0;   // write needed to register file
					branch     <= 0;   // 
					mem_read   <= 0;   //
					mem_write  <= 1;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 0;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end
			ldrb:begin
					//Set the Control Block
					mem_reg    <= 0;   // Take Data from the memory for writing
					reg_write  <= 1;   // write needed to register file
					branch     <= 0;   // No branching
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 0;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end
			adds_2op:begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU for writing
					reg_write  <= 1;   // write needed to register file
					branch     <= 0;   // 
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;   // No mem enable required
					ALU_op     <= opcode;
					ALU_src    <= 1;   // For 0- Reg_data2 1- Immediate Value
					reg_dst    <= 1;   // Register_Destination	- 0 - reg2, 1 - reg3  
				   	branch_decode_flush<=1'b0;
				end
	
			default: begin
					//Set the Control Block
					mem_reg    <= 1;   // Take Data from the ALU
					reg_write  <= 0;   // 
					branch     <= 0;   //
					mem_read   <= 1;   //
					mem_write  <= 0;   //
					mem_enable <= 1;
					ALU_op     <= 5'b10000;
					ALU_src    <= 1;   // For Reg_data_2
					reg_dst    <= 1;   // Register_Destination*/
					//if(~count_out) Intr_fetch <= 1;
					branch_decode_flush<=1'b0;	
				end		
	   		endcase
	//end
 	//$display("CONTROL BLOCK opcode<=%h offset_val<=%h mem_reg<=%b reg_write<=%b branch<=%b mem_read<=%b mem_write<=%b mem_enable<=%b ALU_src<=%h reg_dst<=%b, reg3<=%h",
                  // opcode, offset_val, mem_reg, reg_write, branch, mem_read, mem_write, mem_enable, ALU_src, reg_dst, reg3_addout); 
   end
end 



endmodule

