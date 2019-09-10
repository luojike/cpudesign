`timescale 1ns / 1ps

module BRANCH(ReadData1, ReadData2, opCode, funct3, zero);
	input [31:0] ReadData1, ReadData2;
	input [6:0] opCode;
	input [2:0] funct3;
	output zero;
	
	reg zero;
	
	always @(ReadData1 or ReadData2 or funct3)
		begin
			if(opCode == 7'b1100011)begin
				case(funct3)
					//BNE
					3'b001:begin
					zero = (ReadData1 != ReadData2)? 1 : 0;
					end
				endcase
			end
			else zero = 0;
		end
endmodule
