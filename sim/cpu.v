module cpu(clk, reset, addr_tb, en, rd_en, wr_en, dout_cpu, din_cpu);

output reg [11:0]addr_tb;
output reg [15:0]dout_cpu;
output reg en, rd_en, wr_en;
wire mem_en, mem_read, mem_write;
wire [15:0]addr, alu_out;
input clk, reset;
input [15:0]din_cpu;
wire [15:0] new_pc, n_pc, branch_pc, instruction, Reg_out, Reg_data1, Reg_data2, Reg_data4, signed_value, ALU_mux, instr_out, ALU_out, demux_reg ;
wire ALU_src, mem_reg, mem_regout, reg_dst, reg_dst_out, reg_write, branch, stall, decrement, instr_fetch, instr_fetch_cb_in, instr_fetch_alu_in, instr_fetch_alu_out, mem_read_alu_in, mem_write_alu_in, branch_cb_reset, branch_decode_flush, branch_decode_reflush, cmp_r_alu_in, cmp_r_alu_out; 
wire [3:0]reg1, reg2,reg3, reg4, wr_reg, branch_cond, branch_cond_o, rlist_size, rlist_size_o, count_out, count_in, reg3_buf, reg3_acc, reg3_cb_o,  apsr_o, apsr_i;
wire [4:0] opcode, opcode_o, opcode_reg, opcode_control,opcode_control2, opcode_reg2, ALU_op;
reg [15:0]din;
wire [15:0]offset,Reg_data2_out, offset_o, offset_reg, offset_control, offset_control2, offset_reg2, offset_alu_in, imm_val;
wire [7:0]reg_list, reg_list_o;

//4096*2B=8192B
parameter MEM_DEPTH = 2**12;
parameter ADDR_WIDTH = $clog2(MEM_DEPTH);
parameter [1:0] INCREMENT_BY = 2'b10;

wire [15:0] pc_out;
//wire [ADDR_WIDTH-1:0] addr;

mux21 m1(
	.in0(new_pc), 
	.in1(branch_pc),   //pc_from_execute
	.select(branch),    //memory_stage_pc_sel
	.out(n_pc)
);

pc p1(	
	.clk(clk),
	.pc_in(n_pc), 
  	.reset(reset), 
  	.pc_out(pc_out)
);

mux21 m5(
	.in0(alu_out), 
	.in1(pc_out), 		//Value of reg3 from Decode
	.select(instr_fetch_alu_out), 
	.out(addr)
);


pc_increment pc_inc1(
	.pc_current (pc_out),
	.stall(stall),
	.decrement(decrement),
	.pc_next(new_pc)
);



branch b1(
	.reset(reset), 
	.pc(new_pc), 
	.Imm_val(imm_val), 
	.branch(branch), 
	.branch_con(branch_con),
	.pc_branch(branch_pc)
);

decode d1(
	.clk(clk),
	.data(instr_out), //din
	.reset(reset),
	.branch_flush(branch),
	.reg1(reg1), 
	.reg2(reg2),
	.reg3(reg3),
	.reg4(reg4),	
	.r_list(reg_list),		//8-bit value 
	.r_list_size(rlist_size),	//4-bit value
	.cond(branch_cond),		//4-bit value
	.offset(offset), 
	.opcode(opcode),
	.stall(stall),
        .instr_fetch(instr_fetch_cb_in),
	.count_in(count_in),
	.count_out(count_out),
	.decrement(decrement),
	.branch_decode_flush(branch_decode_flush),
	.branch_decode_reflush(branch_decode_reflush)
);

decrement_count dc1(
.in(count_out),
.out(count_in)
);

control_block ctrl1(
	.clk(clk),
	.rst(reset), 
	.opcode(opcode), 
	.instr_fetch_in(instr_fetch_cb_in),
	.mem_reg(mem_reg), 
	.reg_write(reg_write), 
	.branch(branch_ctrl), 
	.mem_read(mem_read_alu_in), 
	.mem_write(mem_write_alu_in), 
	.mem_enable(mem_en), 
	.ALU_op(ALU_op), 
	.ALU_src(ALU_src), 
	.reg_dst(reg_dst),
	.offset(offset),
	.offset_val(offset_alu_in),
	.reg3_addin(reg3),
	.reg3_addout(reg3_cb_o),
	.instr_fetch_out(instr_fetch_alu_in),
	.branch_flush(branch),
	.branch_decode_flush(branch_decode_flush)
	);

inverter inv1(
.in(branch),
.out(branch_rst_flush)
);

register_file rf1(
	.clock(clk),
	.rst(reset),
	.WE(reg_write_out),
	.InData(Reg_out),
	.WrReg(wr_reg),
	.ReadA(reg1),
	.ReadB(reg2),
	.ReadC(reg4),	
	.OutA(Reg_data1),
	.OutB(Reg_data2),
	.OutC(Reg_data4)
);

inverter inv2(
.in(cmp_r_alu_out),
.out(cmp_r_alu_in)
);

alu a1(
	.rst(reset), 
	.clk(clk), 
	.branch(branch_ctrl),
	.opcode(ALU_op), 
	.inA(Reg_data1), 
	.inB(ALU_mux),
	.inC(Reg_data4),
	.in_apsr(apsr_o),
	.instr_fetch_in(instr_fetch_alu_in),
	.in_pc(pc_out),
	.wreg_loc_in(reg3_cb_o), 
	.wreg_en_in(reg_write),
	.mem_reg_in(mem_reg),
	.out(alu_out), 
	.out_apsr(apsr_i),
	.wreg_loc_out(reg3_acc),
	.wreg_en_out(reg_write_out),
	.mem_reg_out(mem_regout),
	.branch_con(branch_con),
	.instr_fetch_out(instr_fetch_alu_out),
	.reg_dst_in(reg_dst),
	.reg_dst_out(reg_dst_out),
	.mem_read_in(mem_read_alu_in),
	.mem_read_out(mem_read),
	.mem_write_in(mem_write_alu_in),
	.mem_write_out(mem_write),
	.rst_branch_flush(branch_rst_flush), 
	.branch_flush(branch),
	.offset_in(offset_alu_in),
	.offset_out(imm_val),
	.cmp_r_in(cmp_r_alu_in), 
	.cmp_r_out(cmp_r_alu_out),
	.regdata2_in(Reg_data2),
	.regdata2_out(Reg_data2_out)
);

decode_reflush dr1(
.clk(clk),
.rst(reset),
.rst_branch_flush(branch),
.branch_decode_reflush(branch_decode_reflush)
);
//Mux for ALU Op2
mux21 m2(
	.in0(Reg_data2), 
	.in1(offset_alu_in), //(signed_val) 
	.select(ALU_src), 
	.out(ALU_mux)
);

//Mux for MemReg selection
mux21 m3(
	.in0(demux_reg), 
	.in1(alu_out), 
	.select(mem_regout), 
	.out(Reg_out)
);

mux21_4bit m6(
	.inA(reg2), 
	.inB(reg3_acc), 		//Value of reg3 from Accumulator
	.sel(reg_dst_out), 			//reg_dst
	.out(wr_reg)

);


demux12 m4(
	.in(din), 
	.sel(instr_fetch_alu_out), //.sel(instr_fetch) 
	.outA(demux_reg), 
	.outB(instr_out)
);

apsr ap1(
	.rst(reset),
	.clk(clk),
	.in(apsr_i),
	.out(apsr_o)
); 
//always@(posedge reset)
	//addr_tb<=0;
always@(*) begin
	addr_tb = addr>>1; 
	din = {din_cpu[7:0], din_cpu[15:8]};
	dout_cpu = {Reg_data2_out[7:0], Reg_data2_out[15:8]};
end


always@(mem_en, mem_read, mem_write) begin
	en=mem_en; 
	rd_en=mem_read; 
	wr_en=mem_write;
	end
endmodule
