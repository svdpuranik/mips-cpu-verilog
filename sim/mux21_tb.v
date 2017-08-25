module mux21_tb;

reg [15:0] in0, in1;
reg select;
wire [15:0]out;

mux21 mux(.in0(in0),.in1(in1),.select(select),.out(out));

initial begin
    in0 <= 0;
    in1 <= 1;
     select <= 0;
    #1;
    $display("In: %b, %b select %b. Out %b.", in0, in1, select, out);
    #1;
    select<= 1;
    #1;
    $display("In: %b, %b select %b. Out %b.", in0, in1, select, out);
    
   end 

endmodule
