/**
Intruction Fetch module
*/

module fetch(reset, clk, en, rd_en, wr_en, memory_stage_pc_sel, pc_from_execute, new_pc, instruction);

input wire clk, memory_stage_pc_sel, reset, en, rd_en, wr_en;
input wire [15:0] pc_from_execute;
output wire [15:0] new_pc, instruction;

//4096*2B=8192B
parameter MEM_DEPTH = 2**12;
parameter ADDR_WIDTH = $clog2(MEM_DEPTH);
parameter [1:0] INCREMENT_BY = 2'b10;

wire [15:0] pc_out, pc_incremented;
wire [ADDR_WIDTH-1:0] addr;

//Instantiate the modules

mux21 m1 (.in0(pc_incremented), 
	  .in1(pc_from_execute), 
	  .select(memory_stage_pc_sel), 
	  .out(new_pc));

pc p1 (.pc_in(new_pc), 
       .reset(reset), 
       .pc_out(pc_out));

memory mem1 (.clk(clk),
	     .en(en),
	     .rd_en(rd_en),
	     .wr_en(wr_en),
	     .addr(addr),
	     .din(pc_out),
	     .dout(instruction));

pc_increment pc_inc1(.pc_current (pc_out),
	      .stall(1'b0),
	      .increment_by(INCREMENT_BY),
	      .pc_next(new_pc));

endmodule 