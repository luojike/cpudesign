`timescale 1ns / 1ps
 
module PC(clk, Reset, PCWre, PCSrc, immediate, Address);
    input clk, Reset, PCWre, PCSrc;
	 input [31:0] immediate;
	 output [31:0] Address;
	 reg [31:0] Address;
	 
	 /*initial begin
	     Address = 0;
	 end*/
	 
	 always @(posedge clk or negedge Reset)
	     begin
		      if (Reset == 0) begin
				    Address = 0;
				end
				else if (PCWre) begin
				    if (PCSrc) Address = Address + 4 + immediate*2;
					 else Address = Address + 4;
				end
		  end
 
endmodule
