# 实验报告

## 实验名称（RISC-V基本指令集模拟器设计与实现）

班级：数媒1501 学号：201526010219 姓名：曹昕奕

## 实验目标

设计一个单周期的CPU并进行仿真，验证所实现指令的正确性。

## 实验要求

* 采用VHDL/Verilog编写程序
* CPU每条指令单个周期执行完


## 实验内容

### CPU指令集

CPU的指令集请见[这里](https://riscv.org/specifications/)，其中基本指令集共有_47_条指令。

### Verilog程序框架

Verilog程序编写分几个模块，例如：
1.ALU.v（完成ALU类型的指令的执行）
2.BRANCH.v（完成BRANCH类型指令的执行）
3.LOAD.v（完成LOAD类型指令的执行）
4.controlUnit.v（获取控制信号）
5.PC.v（更改并获取地址）
6.signZeroExtend.v（获取扩展后的立即数）
7.DataMemory.v（数据存储单元）
8.instructionMemory.v（指令存储单元）
9.registerFile.v（寄存器文件单元）
10.singleStyleCPU.v（顶层模块）

对CPU程序的框架设计如下：

1.ALU.v
```verilog
`timescale 1ns / 1ps
 
module ALU(ReadData1, ReadData2, inExt, opCode, shamt, ALUSrcB, ALUOp, /*zero,*/ result);
    input [31:0] ReadData1, ReadData2, inExt;
    input [6:0] opCode;
    input [4:0] shamt;
	 input ALUSrcB;
	 input [2:0] ALUOp;
	 //output zero;
	 output [31:0] result;
	 
	 //reg zero;
	 reg [31:0] result;
	 wire [31:0] B;
	 assign B = ALUSrcB? inExt : ReadData1;
	 
	 always @(ReadData1 or ReadData2 or inExt or ALUSrcB or ALUOp or B)
	     begin
		  if(opCode == 7'b0010011)begin
		      case(ALUOp)
				    // ADDI
					 3'b000: begin					 
						 result = ReadData2 + B;
						  //zero = (result == 0)? 1 : 0;
					 end
					 // SLLI
					 3'b001: begin
						result = ReadData2 << shamt;
						  //zero = (result == 0)? 1 : 0;
					 end
		      endcase
		   end
		   else if(opCode == 7'b0110011)begin
				case(ALUOp)
					// SLT
					 3'b010: begin
						result = (ReadData2 < ReadData1)? 1 : 0;
					end
				endcase
			end
			else if(!opCode)begin
				result = 0;
			end
		  end
endmodule

```
该模块设置了3个32位的输入信号（ReadData1, ReadData2, inExt），分别表示rs寄存器的值、rt寄存器的值和扩展后的立即数的值；设置了7位的输入信号opCode、5位的输入信号shamt、3位的输入信号ALUOp（其实就是后面的funct3子集）以及输入的控制信号ALUSrcB。该模块根据控制信号ALUSrcB来判断ALU命令时ADD类型还是ADDI类型选择rs寄存器的值或立即数的值。在always下，根据opCode可以判断是否ALU类型的译码而是否继续往下执行，最后根据ALUOp（funct3）执行相应的指令内容。

2.BRANCH.v
```verilog
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
```
指令模块之间基本差不多，对应的输入信号和输出信号即可，BRANCH模块则是根据rs和rt寄存器里面的值是否相等将控制信号置为1或0，zero为1并且PCSrc为1会执行跳转指令（后面会提及到）。


3.LOAD.v
```verilog
`timescale 1ns / 1ps

module LOAD(ReadData2, inExt, funct3, DataOut, DataIn, DataMemRW, InstructionMemory, opCode, curPC);
	input [31:0] ReadData2, inExt;
	input [6:0] opCode;
	input [2:0] funct3;
	input [31:0] DataIn, InstructionMemory, curPC;
	 input DataMemRW;
	output reg [31:0] DataOut;
	reg [31:0] memory[0:31];
	
	wire [31:0] DAddr;
	wire [15:0] Data;
	
	assign DAddr = ReadData2 + inExt;
	
	// read data
	 always @(DataMemRW) begin
	 if (DataMemRW == 0)  begin
			memory[curPC] = InstructionMemory;
		end
	 end
	
	
	always @(ReadData2 or inExt or DAddr or funct3)
		begin
		 if(opCode == 7'b0000011)
		 begin
			case(funct3)
				3'b001://LH
					begin
						DataOut = memory[DAddr];
						DataOut[31:16] = DataOut[15]? 16'hffff : 16'h0000;
					end
			endcase
		 end
		end
		
		
	always @(DataMemRW or DAddr or DataIn)
	     begin
		      if (DataMemRW) memory[DAddr] = DataIn;
		  end
		
endmodule

```
LOAD指令单元模块会有一点不同，因为除了本身有数据存储模块外，还需要一个指令存储模块，所以LOAD模块里面会包含有存储功能，以方便当指令是读功能的时候，可以读取相应所需要的内容。所以在该模块里面声明了memory来存储指令内容。


4.controlUnit.v
```verilog
`timescale 1ns / 1ps
 
module controlUnit(opCode, funct3, zero, PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut, ALUOp);
    input [6:0] opCode;
    input [2:0] funct3;
	 input zero;
	 output PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut;
	 output [2:0] ALUOp;
	 
	 assign PCWre = (opCode == 7'b1111111)? 0 : 1;
	 assign ALUSrcB = (opCode == 7'b0010011 || opCode == 7'b0100011 || opCode == 7'b0000011)? 1 : 0;
	 assign ALUM2Reg = (opCode == 7'b0000011)? 1 : 0;
	 assign RegWre = (opCode == 7'b0110011 || opCode == 7'b0010011 ||opCode == 7'b0000011)? 1 : 0;
	 assign InsMemRW = 0;
	 assign DataMemRW = (opCode == 7'b0100011)? 1 : 0;
	 assign ExtSel = (opCode == 7'b0010011 || opCode == 7'b0100011 || opCode == 7'b0000011 || opCode== 7'b1100011)? 1 : 0;
	 assign PCSrc = (opCode == 7'b1100011 && zero == 1)? 1 : 0;
	 assign RegOut = (opCode == 7'b0001111)? 0 : 1;
	 assign ALUOp[2] = funct3[2];
	 assign ALUOp[1] = funct3[1];
	 assign ALUOp[0] = funct3[0];
	 
endmodule

```
该模块是获取各功能的控制信号，PCWre和zero同时置为1时执行PC←PC+4+(sign-extend)immediate操作；ALUSrcB为1时获取来自sign或zero扩展的立即数，相关指令：addi、ori、sw、lw，否则获取来自寄存器堆rs输出，相关指令：add、sub、or、and、move、beq；ALUM2Reg为1时获取来自数据存储器（Data MEM）的输出，相关指令：lw、lh等，否则来自ALU运算结果的输出，相关指令：add、addi、sub、ori、or、and、move；RegWre为1时寄存器组写使能，相关指令：add、addi、sub、ori、or、and、move、lw等，否则无写寄存器组寄存器，相关指令：sw、halt；InsMemRW为0时读指令存储器(Ins. Data)，初始化为0；DataMemRW为1时写数据存储器，相关指令：sw等，否则读数据存储器，相关指令：lw等；ExtSel为1时进行立即数符号扩展，相关指令：addi、sw、lw、beq等，否则进行零扩展；RegOut为1时写寄存器组寄存器的地址，来自rd字段，相关指令：add、sub、and、or、move等，否则写寄存器组寄存器的地址，来自rt字段。


5.PC.v
```verilog
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
```
简单的时钟输入信号和重置输入信号，根据控制信号判断地址修改的时候是否跟立即数有关。


6.signZeroExtend.v
```verilog
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

```
扩充立即数的单元模块，此处只处理了Itype类型和Btype类型的立即数。


7.DataMemory.v
```verilog
`timescale 1ns / 1ps
 
module dataMemory(DAddr, DataIn, DataMemRW, DataOut , InstructionMemory, opCode, curPC);
    input [31:0] DAddr, DataIn, InstructionMemory, curPC;
    input [6:0] opCode;
	 input DataMemRW;
	 output reg [31:0] DataOut;
	 reg [31:0] memory[0:31];
	 
	 
	 // read data
	 always @(DataMemRW) begin
	 if (DataMemRW == 0)  begin
			memory[curPC] = InstructionMemory;
			DataOut = memory[curPC];
		end
	 end
	 
	 
	 // write data
	 /*integer i;
	 initial begin
	     for (i = 0; i < 32; i = i+1) memory[i] <= 0;
	 end*/
	 always @(DataMemRW or DAddr or DataIn)
	     begin
		      if (DataMemRW) memory[DAddr] = DataIn;
		  end
 
endmodule

```
和LOAD单元模块的存储数据一样，这里增加了每次时钟周期查看当前存储的数据的功能，即输出信号DataOut。


8.instructionMemory.v
```verilog
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
	 // beq $2,$7,-5 (转01C)
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

```
这里是取指、译码的地方，输出信号包含op、rs标号、rd标号、rt标号、指令码、立即数、funct3和shamt。


registerFile.v
```verilog
`timescale 1ns / 1ps
 
module registerFile(clk, RegWre, RegOut, rs, rt, rd, ALUM2Reg, dataFromALU, dataFromRW, Data1, Data2);
    input clk, RegOut, RegWre, ALUM2Reg;
	 input [4:0] rs, rt, rd;
	 input [31:0] dataFromALU, dataFromRW;
	 output [31:0] Data1, Data2;
	 
	 wire [4:0] writeReg;
	 wire [31:0] writeData;
	 assign writeReg = RegOut? rd : rt;
	 assign writeData = ALUM2Reg? dataFromRW : dataFromALU;
	 
	 reg [31:0] register[0:31];
	 integer i;
	 initial begin
	     for (i = 0; i < 32; i = i+1) register[i] <= 1;
	 end
	 
	 // output
	 assign Data1 = register[rs];
	 assign Data2 = register[rt];
	 
	 // Write Reg
	 always @(posedge clk) 
	 begin
	     if (RegWre && writeReg) register[writeReg] = writeData;  // 防止数据写入0号寄存器
	 end
 
endmodule

```
该单元模块基本功能就是将rs、rt寄存器里面的指赋值给输出信号。除此之外，根据控制信号判断存储到的寄存器编号是根据rt还是rd，存储的内容是根据ALU算法还是基于读算法来写入数据。


10.singleStyleCPU.v
```verilog
//`include "controlUnit.v"
//`include "dataMemory.v"
//`include "ALU.v"
//`include "instructionMemory.v"
//`include "registerFile.v"
//`include "signZeroExtend.v"
//`include "PC.v"
`timescale 1ns / 1ps
 
module SingleCycleCPU(
    input clk, Reset,
	 output wire [6:0] opCode,
	 output wire [2:0] funct3,
	 output wire [4:0] shamt, rs, rt, rd,
	 output wire [31:0] Out1, Out2, curPC, Result,
	 //test
	 output wire [31:0] DMOut, DMOut2,I_ExtOut,
	 output wire zero
	 );
	 
	 wire [2:0] ALUOp;
	 wire [31:0] /*I_ExtOut, DMOut*/InstructionMemory, B_ExtOut;
	 wire [11:0] I_immediate, B_immediate;
	 wire /*zero,*/ PCWre, PCSrc, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, RegOut;
	 
	 // module ALU(ReadData1, ReadData2, inExt, ALUSrcB, ALUOp, zero, result);
	 ALU alu(Out1, Out2, I_ExtOut, opCode, shamt, ALUSrcB, ALUOp, /*zero,*/ Result);
	 // module BRANCH(ReadData1, ReadData2, opCode, funct3, zero);
	 BRANCH branch(Out1, Out2, opCode, funct3, zero);
	 //module LOAD(ReadData2, inExt, funct3, DataOut, DataIn, DataMemRW, InstructionMemory, opCode, curPC);
	 LOAD load(Out2, I_ExtOut, funct3, DMOut2, Out2, DataMemRW, InstructionMemory, opCode, curPC);
	 // module PC(clk, Reset, PCWre, PCSrc, immediate, Address);
	 PC pc(clk, Reset, PCWre, PCSrc, B_ExtOut, curPC);
	 // module controlUnit(opCode, funct3, zero, PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut, ALUOp);
	 controlUnit control(opCode, funct3, zero, PCWre, ALUSrcB, ALUM2Reg, RegWre, InsMemRW, DataMemRW, ExtSel, PCSrc, RegOut, ALUOp);
	 // module dataMemory(DAddr, DataIn, DataMemRW, DataOut, InstructionMemory, opCode, curPc);
	 dataMemory datamemory(Result, Out2, DataMemRW, DMOut, InstructionMemory, opCode, curPC);
	 /* module instructionMemory(
    input [31:0] pc,
    input InsMemRW,
	 input [5:0] op, 
	 input [4:0] rs, rt, rd,
	 output [15:0] immediate);*/
	 instructionMemory ins(curPC, InsMemRW, opCode, rs, rt, rd, funct3, shamt, I_immediate, B_immediate, InstructionMemory);
	 // module registerFile(clk, RegWre, RegOut, rs, rt, rd, ALUM2Reg, dataFromALU, dataFromRW, Data1, Data2);
	 registerFile registerfile(clk, RegWre, RegOut, rs, rt, rd, ALUM2Reg, Result, DMOut, Out1, Out2);
    // module signZeroExtend(I_immediate, ExtSel, out);
	 signZeroExtend ext(I_immediate, B_immediate, ExtSel, I_ExtOut, B_ExtOut);
 
 
endmodule

```
这个是顶层模块，是整个CPU的控制模块，通过连接各个子模块来达到运行CPU的目的。

## 测试

### 测试平台

CPU在如下机器上进行了测试：

| 部件     | 配置                             | 备注   |
| :--------|:----------------:               | :-----: |
| CPU      | Intel(R) Core(TM)i7-4720HQ      |        |
| 内存     | DDR3 8GB                         |        |
| 操作系统  | Windows 8.1                     | 中文版 |
|Quartus ii| Version 9.0 Build 184 04/29/2009|       |

### 测试记录


CPU运行过程的截图如下：

最开始显示了两个时钟周期，分别为ADDI和SLLI指令，Result为结果值Out1是rs寄存器的取值，Out2是rt寄存器的取值，curPC是地址，opCode是译码，rs、rt、rd是寄存器的标号，DMOut是存储数据那里输出的指令集，DMOut2是执行LOAD指令的读取。
![图1]()

![图9](./SLT.png)

## 分析和结论

从测试记录来看，CPU实现了对二进制指令的读入，指令功能的模拟，CPU和存储器状态的输出。

根据分析结果，可以认为编写的CPU实现了所要求的功能，完成了实验目标。

