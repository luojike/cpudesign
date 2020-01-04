# CPU实验报告

班级：智能1602

学号：201608010629

姓名：冶占清

## 实验目标

实现单周期CPU的设计

## 实验要求

- 硬件设计采用VHDL或Verilog语言，软件设计采用C/C++或SystemC语言，其它语言例如Chisel、MyHDL等也可选
- 实验报告采用markdown语言，或者直接上传PDF文档
- 实验最终提交所有代码和文档

## 实验内容

### RISC-V指令集介绍

**RV32I指令集包含了六种基本指令格式，分别是：**

R类型指令：用于寄存器到寄存器操作

I类型指令：用于短立即数和访存load操作

S类型指令：用于访存store操作

B类型指令：用于条件跳转操作

U类型指令：用于长立即数

J类型指令：用于无条件跳转

简单算术操作指令介绍
一共有15条指令分别是：add、addi、addiu、addu、sub、subu、clo、clz、slt、slti、sltiu、sltu、mul、mult、multu

1. add、addu、sub、subu、slt、sltu指令
add、addu、sub、subu、slt、sltu指令格式为： image 由指令格式可以看出这六条指令指令码都是6'b000000即SPECIAL类，而且指令的第6~10bit都是0，根据指令的功能码(0~5bit)来判断是那一条指令

ADD(功能码是6'b100000):加法运算，用法：add rd,rs,rt；作用：rd <- rs+rt，将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行加法运算，结果保存到地址为rd的通用寄存器中。如果加法运算溢出，那么会产生溢出异常，同时不保存结果。
ADDU(功能码是6'b100001):加法运算，用法：addu rd,rs,rt; 作用：rd <-rs+rd,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行加法运算，结果保存到rd的通用寄存器中。不进行溢出检查，总是将结果保存到目的寄存器。
SUB(功能码是6'b100010):减法运算，用法：sub rd,rs,rt; 作用：rd <- rs-rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行减法运算，结果保存到地址为rd的通用寄存器中。如果减法运算溢出，那么产生溢出异常，同时不保存结果。
SUBU(功能码是6'b100011):减法运算，用法：subu rd,rs,rt; 作用：rd <- rs-rt将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值进行减法运算，结果保存到地址为rd的通用寄存器中。不进行溢出检查，总是将结果保存到目的寄存器。
SLT(功能码是6'b101010):比较运算，用法：slt rd,rs,rt; 作用：rd <- (rs<rt)将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值按照有符号数进行比较，若前者小于后者，那么将1保存到地址为rd的通用寄存器，若前者大于后者，则将0保存到地址为rd的通用寄存器中
SLTU(功能码是6'b101011):比较运算，用法：sltu rd,rs,rt; 作用：rd <- (rs<rt)将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值按照无符号数进行比较，若前者小于后者，那么将1保存到地址为rd的通用寄存器，若前者大于后者，则将0保存到地址为rd的通用寄存器中
2. addi、addiu、slti、sltiu指令
addi、addiu、slti、sltiu指令格式为： image 由指令格式可以看出，依据指令码(26~31bit)判断是哪一种指令

ADDI(指令码是6'b001000):加法运算，用法：addi rt,rs,immediate; 作用：rt <- rs+(sign_extended)immediate,将指令中16位立即数进行符号扩展，与地址为rs的通用寄存器进行加法运算，结果保存到地址为rt的通用寄存器。如果加法运算溢出，则产生溢出异常，同时不保存结果。
ADDIU(指令码是6'b001001):加法运算，用法：addiu rt,rs,immediate; 作用：rt <- rs+(sign_extended)immediate,将指令中16位立即数进行符号扩展，与地址为rs的通用寄存器进行加法运算，结果保存到地址为rt的通用寄存器。不进行溢出检查，总是将结果保存到目的寄存器。
SLTI(功能码是6'b001010):比较运算，用法：slti rt,rs,immediate; 作用：rt <- (rs<(sign_extended)immediate)将指令中的16位立即数进行符号扩展，与地址为rs的通用寄存器的值按照有符号数进行比较，若前者小于后者，那么将1保存到地址为rt的通用寄存器，若前者大于后者，则将0保存到地址为rt的通用寄存器中
SLTIU(功能码是6'b001011):比较运算，用法：sltiu rt,rs,immediate; 作用：rt <- (rs<(sign_extended)immediate)将指令中的16位立即数进行符号扩展，与地址为rs的通用寄存器的值按照无符号数进行比较，若前者小于后者，那么将1保存到地址为rt的通用寄存器，若前者大于后者，则将0保存到地址为rt的通用寄存器中
3. clo、clz指令
clo、clz的指令格式： image 由指令格式可以看出，这两条指令的指令码(26~31bit)都是6'b011100,即是SPECIAL2类；而且第6~10bit都为0，根据指令中的功能码(0~5bit)判断是哪一条指令

CLZ(功能码是6'b100000):计数运算，用法：clz rd,rs; 作用：rd <- coun_leading_zeros rs,对地址为rs的通用寄存器的值，从最高位开始向最低位方向检查，直到遇到值为“1”的位，将该为之前“0”的个数保存到地址为rd的通用寄存器中，如果地址为rs的通用寄存器的所有位都为0(即0x00000000),那么将32保存到地址为rd的通用寄存器中
CLO(功能码是6'b100001):计数运算，用法：clo,rd,rs; 作用：rd <- coun_leading_zeros rs对地址为rs的通用寄存器的值，从最高位开始向最低位方向检查，直到遇到值为“0”的位，将该为之前“1”的个数保存到地址为rd的通用寄存器中，如果地址为rs的通用寄存器的所有位都为1(即0xFFFFFFFF),那么将32保存到地址为rd的通用寄存器中
4. multu、mult、mul指令
multu、mult、mul的指令格式： image 由指令格式可以看出，mul指令的指令码(26~31bit)都是6'b011100,即是SPECIAL2类，mult和multu这两条指令的指令码(26~31bit)都是6'b000000,即是SPECIAL类；有着不同的功能码(0~5bit)

mul(指令码是SPECIAL2,功能码是6'b000010):乘法运算，用法：mul,rd,rs,st; 作用：rd <- rs * rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值作为有符号数相乘，乘法结果低32bit保存到地址为rd的通用寄存器中
mult(指令码是SPECIAL,功能码是6'b011000):乘法运算，用法：mult,rs,st; 作用：{hi,lo} <- rs * rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值作为有符号数相乘，乘法结果低32bit保存到LO寄存器中，高32bit保存到HI寄存器中
multu(指令码是SPECIAL,功能码是6'b011001):乘法运算，用法：mult,rs,st; 作用：{hi,lo} <- rs * rt,将地址为rs的通用寄存器的值与地址为rt的通用寄存器的值作为无符号数相乘，乘法结果低32bit保存到LO寄存器中，高32bit保存到HI寄存器中
**RISC-V指令集编码格式**

![](./RV32I.PNG)

**RISC-V指令**

![](./RV32_1.PNG)

![](./RV32_2.PNG)

## CPU设计代码

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity mycpu is
	port(
			clk: in std_logic;
			LOAD: in std_logic;
			STORE: in std_logic;
			LUI: in std_logic;
			AUIPC: in std_logic;
			RI: in std_logic;
			RR: in std_logic;
			JAL: in std_logic;
			JALR: in std_logic;
			BE : in std_logic;
			funct3: in std_logic_vector(2 downto 0);
			rs1: in std_logic_vector(4 downto 0);
			rs2: in std_logic_vector(4 downto 0);
			rd: in std_logic_vector(4 downto 0);
			mem: in std_logic_vector(31 downto 0);
			imm: in std_logic_vector(11 downto 0);
			imm1: in std_logic_vector(19 downto 0);
			q: in std_logic_vector(7 downto 0);
			src1: out std_logic_vector(31 downto 0);
			src2: out std_logic_vector(31 downto 0);
			OUTA: out std_logic_vector(31 downto 0);
			wrimem: out std_logic_vector(31 downto 0);
			JUM: out std_logic_vector(7 downto 0);
			JUD: out std_logic
);
end mycpu;

architecture behav of mycpu is
	type regfile is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal regs:regfile;
	signal lo:std_logic:='0';
	signal srcc1:std_logic_vector(31 downto 0);
	signal srcc2:std_logic_vector(31 downto 0);
	signal tem1:bit_vector(31 downto 0);
	signal count:integer range 0 to 31;
	signal count1:integer range 0 to 31;
	begin
	srcc1<= regs(to_integer(unsigned(rs1)));
	src1 <= srcc1;
	OUTA <= regs(1);
	srcc2<= regs(to_integer(unsigned(rs2)));
	src2 <= srcc2;
	tem1 <=to_bitvector(srcc1);
	count<=to_integer(unsigned(imm(4 downto 0)));
	count1 <= to_integer(unsigned(srcc2));
	process(clk)
	variable mem1:std_logic_vector(7 downto 0);
	variable tem:std_logic_vector(31 downto 0);
	variable mem2:std_logic_vector(15 downto 0);
	variable imm2:signed(31 downto 0);
	variable tem2:bit_vector(31 downto 0);
	variable tem3:std_logic_vector(7 downto 0);
	variable tem4:std_logic_vector(32 downto 0);
	variable tem5:std_logic_vector(32 downto 0);
	variable tem6:std_logic_vector(32 downto 0);
	begin
		if(clk'event and clk='1') then
			if(LOAD='1') then
				case lo is
					when '0'=>
						lo<='1';
					when '1'=>
						lo<='0';
				end case;
				if(lo='1') then
					case funct3 is
						when "000"=>--LB
							mem1:=mem(7 downto 0);
							tem:=std_logic_vector(resize(signed(mem1),tem'LENGTH));
							regs(to_integer(unsigned(rd)))<=tem;
						when "001"=>--LH
							mem2:=mem(15 downto 0);
							tem:=std_logic_vector(resize(signed(mem2),tem'LENGTH));
							regs(to_integer(unsigned(rd)))<=tem;
						when "010"=>--LW
							regs(to_integer(unsigned(rd)))<=mem;
						when "100"=>--LBU
							mem1:=mem(7 downto 0);
							regs(to_integer(unsigned(rd)))<="000000000000000000000000"&mem1;
						when "101"=>--LHU
							mem2:=mem(15 downto 0);
							regs(to_integer(unsigned(rd)))<="0000000000000000"&mem2;
						when others=>
					end case;
				end if;
			elsif(STORE='1') then
				case lo is
					when '0'=>
						lo<='1';
					when '1'=>
						lo<='0';
				end case;
				if(lo='0') then
					case funct3 is
						when "000"=>--SB
							mem1:=srcc2(7 downto 0);
							wrimem<="000000000000000000000000"&mem1;
						when "001"=>--SH
							mem2:=srcc2(15 downto 0);
							wrimem<="0000000000000000"&mem2;
						when "010"=>--SW
							wrimem<=srcc2;
						when others=>
							wrimem<=(others=>'Z');
					end case;
				else
					wrimem<=(others=>'Z');
				end if;
			elsif(LUI='1') then--LUI
				regs(to_integer(unsigned(rd)))<=imm1&"000000000000";
			elsif(AUIPC='1') then--AUIPC
				tem:=imm1&"000000000000";
				regs(to_integer(unsigned(rd)))<=imm1&"000000000000";
				JUM<=tem(7 downto 0);
			elsif(RI='1') then
				case funct3 is
					when "000"=>--ADDI
						regs(to_integer(unsigned(rd)))<=(imm+srcc1);
					when "010"=>--SLTI
						imm2:=resize(signed(imm), imm2'length);
					if(signed(srcc1)<imm2) then
						regs(to_integer(unsigned(rd)))<=(others=>'1');
					else
						regs(to_integer(unsigned(rd)))<=(others=>'0');
					end if;
					when "011"=>--SLTIU
						if(srcc1<"00000000000000000000"&imm) then
							regs(to_integer(unsigned(rd)))<=(others=>'1');
						else
							regs(to_integer(unsigned(rd)))<=(others=>'0');
						end if;
					when "100"=>--XORI
						imm2:=resize(signed(imm), imm2'length);
						regs(to_integer(unsigned(rd)))<=(srcc1 xor std_logic_vector(imm2));
					when "110"=>--ORI
						imm2:=resize(signed(imm), imm2'length);
						regs(to_integer(unsigned(rd)))<=(srcc1 or std_logic_vector(imm2));
					when "111"=>--ANDI
						imm2:=resize(signed(imm), imm2'length);
						regs(to_integer(unsigned(rd)))<=(srcc1 and std_logic_vector(imm2));
					when "001"=>--SLLI
						tem2:=tem1 sll count;
						regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
					when "101"=>
						if(imm(11 downto 5)="0000000") then--SRLI
							tem2:=tem1 srl count;
							regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
						else--SRAI
							tem2:=tem1 sra count;
							regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
						end if;
				end case;
			elsif(RR='1') then
				case funct3 is
					when "000"=>
						if(imm(11 downto 5)="0000000") then--ADD
							tem4:=std_logic_vector(resize(signed(srcc1),tem4'LENGTH));
							tem5:=std_logic_vector(resize(signed(srcc2),tem5'LENGTH));
							tem6:=std_logic_vector(signed(tem4)+signed(tem5))(32 downto 0);
							if(tem6(32)='1' and tem6(31)='0') then
								regs(to_integer(unsigned(rd)))<="10000000000000000000000000000000";
							elsif(tem6(32)='0' and tem6(31)='1') then
								regs(to_integer(unsigned(rd)))<="01111111111111111111111111111111";
							else
								regs(to_integer(unsigned(rd)))<=tem6(31 downto 0);
							end if;
						else--SUB
							tem4:=std_logic_vector(resize(signed(srcc1),tem4'LENGTH));
							tem5:=std_logic_vector(resize(signed(srcc2),tem5'LENGTH));
							tem6:=std_logic_vector(signed(tem4)-signed(tem5))(32 downto 0);
							if(tem6(32)='1' and tem6(31)='0') then
								regs(to_integer(unsigned(rd)))<="10000000000000000000000000000000";
							elsif(tem6(32)='0' and tem6(31)='1') then
								regs(to_integer(unsigned(rd)))<="01111111111111111111111111111111";
							else
								regs(to_integer(unsigned(rd)))<=tem6(31 downto 0);
							end if;
						end if;
					when "001"=>--SLL
						tem2:=tem1 sll count1;
						regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
					when "010"=>--SLT
						if(signed(srcc1)<signed(srcc2)) then
							regs(to_integer(unsigned(rd)))<=(others=>'1');
						else
							regs(to_integer(unsigned(rd)))<=(others=>'0');
						end if;
					when "011"=>--SLTU
						if(srcc1<srcc2) then
							regs(to_integer(unsigned(rd)))<=(others=>'1');
						else
							regs(to_integer(unsigned(rd)))<=(others=>'0');
						end if;
					when "100"=>--XOR
						regs(to_integer(unsigned(rd)))<=(srcc1 xor srcc2);
					when "101"=>
						if(imm(11 downto 5)="0000000") then--SRL
							tem2:=tem1 srl count1;
							regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
						else--SRA
							tem2:=tem1 sra count1;
							regs(to_integer(unsigned(rd)))<=to_stdlogicvector(tem2);
						end if;
					when "110"=>--OR
						regs(to_integer(unsigned(rd)))<=(srcc1 or srcc2);
					when "111"=>--AND
						regs(to_integer(unsigned(rd)))<=(srcc1 and srcc2);
				end case;
			elsif(JAL='1') then--JAL
				imm2:=resize(signed(imm1), imm2'length);
				tem3:=std_logic_vector(imm2*2)(7 downto 0);
				JUM<=tem3;
				regs(to_integer(unsigned(rd)))<="000000000000000000000000"&tem3;
			elsif(JALR='1') then--JALR
				imm2:=resize(signed(imm), imm2'length);
				tem3:=std_logic_vector(signed(imm2)+signed(srcc1))(7 downto 0);
				JUM<=tem3;
				regs(to_integer(unsigned(rd)))<="000000000000000000000000"&tem3;
			elsif(BE='1') then
				case funct3 is
					when "000"=>--BEQ
						if(srcc1=srcc2) then
							imm2:=resize(signed(imm), imm2'length);
							JUM<=std_logic_vector(imm2*2)(7 downto 0);
							JUD<='1';
						else
							JUD<='0';
						end if;
					when "001"=>--BNE
						if(srcc1/=srcc2) then
							imm2:=resize(signed(imm), imm2'length);
							JUM<=std_logic_vector(imm2*2)(7 downto 0);
							JUD<='1';
						else
							JUD<='0';
						end if;
					when "100"=>--BLT
						if(signed(srcc1)<signed(srcc2)) then
							imm2:=resize(signed(imm), imm2'length);
							JUM<=std_logic_vector(imm2*2)(7 downto 0);
							JUD<='1';
						else
							JUD<='0';
						end if;
					when "101"=>--BGE
						if(signed(srcc1)>signed(srcc2)) then
							imm2:=resize(signed(imm), imm2'length);
							JUM<=std_logic_vector(imm2*2)(7 downto 0);
							JUD<='1';
						else
							JUD<='0';
						end if;
					when "110"=>--BLTU
						if(srcc1<srcc2) then
							imm2:=resize(signed(imm), imm2'length);
							JUD<='1';
						else
							JUD<='0';
						end if;
							when "111"=>--BGEU
						if(srcc1>srcc2) then
							imm2:=resize(signed(imm), imm2'length);
							JUM<=std_logic_vector(imm2*2)(7 downto 0);
							JUD<='1';
						else
							JUD<='0';
						end if;
					when others=>
				end case;
			end if;
	end if;
end process;
end behav;
```

## 测试

### 测试平台

|模块|配置|备注|
|:--:|:--:|:--:|
|CPU|Core i5-6700U||
|操作系统|Windows10 专业版||
|仿真软件|quartus 9.1||


### 测试结果

**ADD**

测试所用的指令为：00000000001000010000000010110011

仿真结果为：

![](./cpu/1.PNG)

分析：这条指令是将寄存器2的数与自身相加存入寄存器1中，由于寄存器2中未写入数值，相加结果为0，寄存器1显示为0

测试指令：00000000000100010000000010110011

仿真结果：

![](./cpu/2.PNG)

分析：首先在寄存器1与2中都写入0111111111111111111111111111110，故当寄存器1的值与寄存器2的值相加时，加法溢出。结果显示此时加法已溢出，并摒弃了最高位，该指令正确执行

**ADDI**

测试所用的指令为：00000010000100010000000010010011

仿真结果为：

![](./cpu/3.PNG)

分析：该指令的意思是将指令的前12位（也就是立即数）与寄存器2中存储的数值相加，所得结果存入寄存器1中。由于寄存器2中未写入数值，故寄存器1中显示的数值为该立即数的数值，该指令正确执行 

**SUB**

测试所用的指令为：01000000001000010000000010110011

仿真结果为：

![](./cpu/4.PNG)

分析：该指令将寄存器1的值与寄存器2的值相减，所得结果存入寄存器1中。由于两个寄存器中的值均为0，故寄存器1显示的值为0

测试指令：

00000000001100001000000010010011

00000000000100010000000100010011

01000000000100010000000010110011

仿真结果为：

![](./cpu/5.PNG)

分析：首先给寄存器1赋值3，给寄存器2赋值1，再使用SUB指令使寄存器2的值减寄存器1的值的结果存入寄存器1中，因此减法计算是溢出的，高位为1，所得结果为-2，故该指令正确执行

**LUI**

测试所用的指令为：00011000100000100000000010110111

仿真结果为：

![](./cpu/6.PNG)

分析：这条指令是将20位立即数移至寄存器1的前20位，而寄存器后12位置0。从结果可知，此时立即数已向前移位12位，后12位置0，该指令正确执行

**XOR**

测试所用的指令为：00000000000100000110000010110011

仿真结果为：

![](./cpu/7.PNG)

分析：这条指令的意思是将寄存器1中的值与寄存器2的值进行异或运算，所得结果存入寄存器1中。由于寄存器2中未写入值，故异或结果为寄存器1中的值，即LUI指令执行之后的结果，该指令正确执行

**XORI**

测试所用的指令为：00000010000100010100000010010011

仿真结果为：

![](./cpu/8.PNG)

分析：该指令是将寄存器2与立即数进行异或运算，并将结果存入寄存器1中。由于寄存器2的值为0，故结果为立即数的值，该指令正确执行

**OR**

测试所用的指令为：00000000001100001110000010110011

仿真结果为：

![](./cpu/9.PNG)

分析：该指令是将寄存器1的值与寄存器3的值进行或运算，所得结果存入寄存器1中。由于寄存器3中的值为0，故显示结果为寄存器1中的值，即XORI指令执行结果，该指令正确执行

**ORI**

测试所用的指令为：00000100000100100110000010010011

仿真结果为：

![](./cpu/10.PNG)

分析：该指令是将寄存器4中的值与立即数进行OR运算，所得结果存入寄存器1中。由于寄存器4中未写入值，故所得结果为立即数的值，该指令正确执行

**AND**

测试所用的指令为：00000000011000001111000010110011

仿真结果为：

![](./cpu/11.PNG)

分析：该指令是将寄存器6与寄存器15的值进行AND运算，由于这两个寄存器中未写入数值，故AND结果为0，该指令正确执行

**ANDI**

测试所用的指令为：00000010100101000111000010010011

仿真结果为：

![](./cpu/12.PNG)

分析：该指令是将寄存器8的值与立即数进行AND运算，所得结果存入寄存器1中。由于寄存器8中值为0，故进行AND运算后所得结果为0，该指令正确执行

**SLL**

测试所用的指令为：

00000000001100001000000010010011

00000000000100010000000100010011

00000000000100010001000010110011

仿真结果为：

寄存器1赋值：

![](./cpu/13.PNG)

寄存器2赋值：

![](./cpu/14.PNG)

左移：

![](./cpu/15.PNG)

分析：这三条指令首先对寄存器1与寄存器2进行赋值，然后在将寄存器2的值左移寄存器1中的值，并将结果存入寄存器1中。寄存器2中的值为1，左移三位之后为8，该指令正确执行

## 结果分析

从测试结果可以看出编写的cpu能够完成指令的工作，达到了实验的目的。

