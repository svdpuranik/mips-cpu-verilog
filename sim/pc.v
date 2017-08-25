/**
Program Counter Register
*/

module pc (clk, pc_in, reset, pc_out);

input [15:0] pc_in;
input reset, clk;
output reg [15:0] pc_out;

always @ (posedge clk) begin

if (reset) begin
    pc_out <= 16'h0000;
    //$display("PC Reset %h", pc_out);	
end

else begin
    pc_out <= pc_in;
    $display("PC %h", pc_out);
end

end

endmodule 
