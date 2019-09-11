`timescale 1ns / 1ps
 
module instructionMemory(
    input [31:0] pc,
    input InsMemRW,
	 output [6:0] op, 
	 output [4:0] rs, rt, rd,
	 output [2:0] funct3,
	 output [4:0] shamt,
	 output [11:0] I_immediate,
	 output [11:0] B_immediate,
	 output [31:0] InstructionMemory);
	 
	 wire [31:0] mem[0:15];
	 
	 assign mem[0] = 32'h00000000;
    // ADDI  $1,$2,8
	 assign mem[1] = 32'h00808113;
	 // SLLI  $2,$4,2
	 assign mem[2] = 32'h00211213;
	 // BNE  $2,$4 (to 20)
	 assign mem[3] = 32'h00021163;
	 // 
	 assign mem[4] = 32'h00000000;
	 // SLT  $4,$2,$2
	 assign mem[5] = 32'h00412133;
	 // LH
	 assign mem[6] = 32'h00341503;
	 // 
	 assign mem[7] = 32'h00000000;
	 // 
	 assign mem[8] = 32'h00000000;
	 // sw  
	 assign mem[9] = 32'h00000000;
	 // lw  
	 assign mem[10] = 32'h00000000;
	 // beq $2,$7,-5 (ת01C)
	 assign mem[11] = 32'h00000000;
	 // halt
	 assign mem[12] = 32'hFC000000;
	 
	 assign mem[13] = 32'h00000000;
	 assign mem[14] = 32'h00000000;
	 assign mem[15] = 32'h00000000;
	 
	 // output
	 assign op = mem[pc[5:2]][6:0];
	 assign rs = mem[pc[5:2]][24:20];
	 assign rt = mem[pc[5:2]][19:15];
	 assign rd = mem[pc[5:2]][11:7];
	 assign InstructionMemory = mem[pc[5:2]][31:0];
	 assign I_immediate = mem[pc[5:2]][31:20];
	 assign B_immediate[11] = mem[pc[5:2]][31];
	 assign B_immediate[10] = mem[pc[5:2]][7];
	 assign B_immediate[9:4] = mem[pc[5:2]][30:25];
	 assign B_immediate[3:0]= mem[pc[5:2]][11:8];
	 assign funct3 = mem[pc[5:2]][14:12];
	 assign shamt = I_immediate[4:0];
 
endmodule
