`timescale 1ns / 1ps
 
module signZeroExtend(I_immediate, B_immediate, ExtSel, I_out, B_out);
    input [11:0] I_immediate, B_immediate;
	 input ExtSel;
	 output [31:0] I_out, B_out;
	 
	 assign I_out[11:0] = I_immediate;
	 assign I_out[31:12] = ExtSel? (I_immediate[11]? 20'hfffff : 20'h00000) : 20'h00000;
	 
	 assign B_out[0] = 0;
	 assign B_out[11:1] = B_immediate[10:0];
	 assign B_out[31:12] = ExtSel? (B_immediate[11]? 20'hfffff : 20'h00000) : 20'h00000;
 
endmodule
