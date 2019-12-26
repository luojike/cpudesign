library IEEE;
use IEEE.STD_LOGIC_1164. ALL;

entity CPU is
port(
--rw_address :out std_logic_vector(4 downto 0);
--ra_address :out std_logic_vector(4 downto 0);
--rb_address :out std_logic_vector(4 downto 0);
--ra:out std_logic_vector(31 downto 0);
--rb:out std_logic_vector(31 downto 0);
--aluzero:out std_logic;
--pc_address: out std_logic_vector(31 downto 0);
clkzong: in std_logic;
rst: in std_logic;
--ALUout:out std_logic_vector(31 downto 0);
DMdata:out std_logic_vector(31 downto 0);
--RFwin:out
std_logic_vector(31 downto 0);
--ALUinB:out std_logic_vector(31 downto 0);
--RegDst1 ,RegWrite 1,ALUSrc 1,MemtoReg 1,MemWritel,SEControll:out std_ logic;
--NPCControll:out std_logic_vector(1 downto 0);
--ALUControll:out std_logic_vector(2 downto 0);
jdb18:out std_logic_vector(31 downto 0);
jdb8:out std_logic_vector(31 downto 0);
jdb1 6:out std_logic_vector(31 downto 0);
jdb17:out std_logic vector(31 downto 0); .
Zhiling:out std_logic_vector(31 downto 0));
end CPU;

architecture Behavioral of CPU is
component CU
port(
op:in std_logic_vector(5 downto 0);
func:in std_logic_vector(5 downto 0);
RegDst,RegWrite, ALUSrc,MemtoReg, MemWrite,SEControl:out std_logic;
NPCControl:out std_logic_vector(1 downto 0);
ALUControl:out std_logic_vector(2 downto 0));
end component;

component NPC
port(
input:in std_logic_vector(31 downto 0);
offset:in std_logic_vector(31 downto 0);
pc:in std_logic_vector(31 downto 0);
nNPCcontrol:in std_logic_vector(1 downto 0);
ALUZero:in std_logic;
npc1:out std_logic_vector(31 downto 0));
end component;

component PC
port(clk,clr:in std_logic;
	pc_in:in std_logic_vector(31 downto 0);
	pc_out:out std_logic_vector(31 downto 0));
end component;

component dm
PORT(clka:in std_logic;
	wea:in std_logic_vector(0 downto 0);
	addra:in std_logic_vector(7 downto 0);
	dina:in std_logic_vector(31 downto 0);
	douta:out std_logic_vector(31 downto 0));
end component;

component im
port(a:in std_logic_vector(7 downto 0); .
       spo:out std_logic_vector(31 downto 0));
end component;

component SE
port(
	a:in std_logic_vector(15 downto 0);
	s:in std_logic;
	y:out std_logic_vector(31 downto 0));
end component;

component mux32
port(
	A,B:in std_logic_vector(31 downto 0);
	s:in std_logic;
	Z:out std_logic_vector(31 downto 0));
end component;

component mux5
port(
	A,B:in std_logic vector(4 downto 0);
	s:in std_logic; 
	Z:out std_logic_vector(4 downto 0));
end component; 

component rf
	port(clk,we:in std_logic;
	ra,rb,rw:in std_logic_vector(4 downto 0);
	rd:in std logic vector(31 downto 0);
	qa,qb:out std_logic_vector(31 downto 0);
	jdb1,jdb2,jdb3,jdb4:out std_logic_vector(31 downto 0));
end component;

component alu
port(ALUA,ALUB:in std_logic_vector(31 downto 0); --操作数
	aluc:in std_logic_vector(2 downto 0);--alu控制: 00 加法，01 减法，10或运算
	alu_out:out std_logic_vector(31 downto 0);--al输出
	zero:out std_logic);--零标志位: alu 结果为零zero=1
	end component;
	signal x4,x6,x7,x8,x9,x17:STD_ logic;--定 义内部连接信号
	signal x5:std_logic_vector(0 downto 0);
	signal x3,x13,x14,x15,x16,x18,x19,x20,xa,xb,xc xd:std_logic_vector(31 downto 0);
	signal x1,x2:std_logic_vector(31 downto 0);
	signal x10:std_logic_vector(1 downto 0);
	signal xll:std_logic_vector(2 downto 0);
	signal x12:std_logic_vector(4 downto 0);

begin
pc1:PC PORT MAP(clk=>clkzong,clr=>rst,pc_in=>x1,pc_out=>x2);
im1:IM PORT MAP(a=>x2(9 downto 2),spo=>x3);
cul:CU PORT MAP(op=>x3(31 downto 26),func=>x3(5 downto 0),
RegDst=> x7,RegWrite=>x8,ALUSrc=>x9,MemtoReg=>x6,MemWrite=>x5(0),SEControl=>x4,NPCControl=>x10,ALUControl=>x11);
mux1:MUX5 PORT MAP(A=>x3(15 downto 11),B=>x3(20 downto 16),s=>x7,z=>x12);
rf1:rf PORT MAP(clk=>clkzong,we=>x8,ra=>x3(25 downto 21),rb=>x3(20 downto 16),rw=>x12,rd=>x13,qa=>x14,qb=>x15,jdb1=>xa,jdb2=>xb,jdb3=>xc jdb4=> xd);
alul:ALU PORT MAP(ALUa=>x14,ALUb=>x16,aluc= >x11,zero=>x17,ALu out=>x18);
mux2:mux32 PORT MAP(a=>x15,b=>x19,s=>x9,z=>x16);
mux3:mux32 PORT MAP(a=>x18,b=>x20,s=>x6,z=>x13);
dml:DM PORT MAP(addra=>x18(7 downto 0),dina=>x15,wea=>x5,clka=>clkzong,douta=>x20);
npc2:NPC PORT MAP(input=>x3,ffset=>x19,pc=>x2 ,nNPCControl=>x10,ALUzero=>x17,NPC1=>x1);
sel:se port map(a=>x3(15 downto 0),s=>x4,y=>x19);
--ALUout<=x18;
DMdata<=x20;
--RFwin<=x13;
--ALUinB<=x16;
Zhiling<=x3;
--RegDst1<=x7;
--RegWrite1<=x8;
--ALUSrcl<=x9;
--MemtoReg1<=x6;
--MemWrite1<=x5(0);
--SEControll<= x4; .
--NPCControl1<=x10;
--ALUControll<=x11;
--PC_ address<= x1;
--aluzero<=x17;
--ra<=x14;
--rb<=x15;
jdb18<=xa;
jdb8<= xb;
jdb16<=xc; .
jdb17<=xd;
--ra_address<=x3(25 downto 21 );
--rb_address<=x3(20 downto 16);
--rW_address<=x12;
end Behavioral;
