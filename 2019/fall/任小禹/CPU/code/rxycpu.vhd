LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY rxycpu IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		pause :  IN  STD_LOGIC;
		aluresult :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		clk_div :  OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
		data1 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		data2 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		instruction :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_read :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		pcaddr :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END rxycpu;

ARCHITECTURE bdf_type OF rxycpu IS 

ATTRIBUTE black_box : BOOLEAN;
nATTRIBUTE noopt : BOOLEAN;

COMPONENT busmux_0
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_0: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_0: COMPONENT IS true;

COMPONENT busmux_1
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_1: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_1: COMPONENT IS true;

COMPONENT reg
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 rd_write_ctr : IN STD_LOGIC;
		 rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rd_write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rs1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 data_rs1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 data_rs2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT time5
	PORT(clk_in : IN STD_LOGIC;
		 clk_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT control
	PORT(opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		 Branch : OUT STD_LOGIC;
		 MemRead : OUT STD_LOGIC;
		 MemtoReg : OUT STD_LOGIC;
		 MemWrite : OUT STD_LOGIC;
		 ALUSrc : OUT STD_LOGIC;
		 RegWrite : OUT STD_LOGIC;
		 ALUOp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 pause : IN STD_LOGIC;
		 pc_src : IN STD_LOGIC;
		 imm : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT data_mem
	PORT(clk : IN STD_LOGIC;
		 memread : IN STD_LOGIC;
		 memwrite : IN STD_LOGIC;
		 data_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 data_write : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 funct3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 data_read : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imm
	PORT(ins : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 imm_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ins_mem
	PORT(addrbus : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 databus : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu_control
	PORT(aluop : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 funct3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 funct7 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		 aluctr : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(clk : IN STD_LOGIC;
		 alu_ctr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 data1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 data2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 alu_res : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	alusrc :  STD_LOGIC;
SIGNAL	branch :  STD_LOGIC;
SIGNAL	clk_div_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	imm :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ins :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mrd :  STD_LOGIC;
SIGNAL	mtor :  STD_LOGIC;
SIGNAL	mwrt :  STD_LOGIC;
SIGNAL	pas :  STD_LOGIC;
SIGNAL	rst :  STD_LOGIC;
SIGNAL	rwc :  STD_LOGIC;
SIGNAL	rwd :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	zero :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 
aluresult <= SYNTHESIZED_WIRE_12;
data1 <= SYNTHESIZED_WIRE_10;
data2 <= SYNTHESIZED_WIRE_11;
pcaddr <= SYNTHESIZED_WIRE_7;



b2v_inst : reg
PORT MAP(clk => SYNTHESIZED_WIRE_0,
		 rst => rst,
		 rd_write_ctr => rwc,
		 rd => ins(11 DOWNTO 7),
		 rd_write_data => rwd,
		 rs1 => ins(19 DOWNTO 15),
		 rs2 => ins(24 DOWNTO 20),
		 data_rs1 => SYNTHESIZED_WIRE_10,
		 data_rs2 => SYNTHESIZED_WIRE_13);


b2v_inst10 : time5
PORT MAP(clk_in => clk,
		 clk_out => clk_div_ALTERA_SYNTHESIZED);


b2v_inst12 : control
PORT MAP(opcode => ins(6 DOWNTO 0),
		 Branch => branch,
		 MemRead => mrd,
		 MemtoReg => mtor,
		 MemWrite => mwrt,
		 ALUSrc => alusrc,
		 RegWrite => rwc,
		 ALUOp => SYNTHESIZED_WIRE_8);


b2v_inst14 : pc
PORT MAP(clk => clk_div_ALTERA_SYNTHESIZED(0),
		 rst => rst,
		 pause => pas,
		 pc_src => SYNTHESIZED_WIRE_1,
		 imm => imm,
		 pc_out => SYNTHESIZED_WIRE_7);


SYNTHESIZED_WIRE_0 <= clk_div_ALTERA_SYNTHESIZED(1) OR clk_div_ALTERA_SYNTHESIZED(4);


b2v_inst2 : data_mem
PORT MAP(clk => clk_div_ALTERA_SYNTHESIZED(3),
		 memread => mrd,
		 memwrite => mwrt,
		 data_addr => SYNTHESIZED_WIRE_12,
		 data_write => SYNTHESIZED_WIRE_13,
		 funct3 => ins(14 DOWNTO 12),
		 data_read => SYNTHESIZED_WIRE_5);


b2v_inst3 : imm
PORT MAP(ins => ins,
		 imm_out => imm);


b2v_inst4 : busmux_0
PORT MAP(sel => mtor,
		 dataa => SYNTHESIZED_WIRE_12,
		 datab => SYNTHESIZED_WIRE_5,
		 result => rwd);


b2v_inst5 : busmux_1
PORT MAP(sel => alusrc,
		 dataa => SYNTHESIZED_WIRE_13,
		 datab => imm,
		 result => SYNTHESIZED_WIRE_11);


SYNTHESIZED_WIRE_1 <= branch AND zero;


b2v_inst7 : ins_mem
PORT MAP(addrbus => SYNTHESIZED_WIRE_7,
		 databus => ins);


b2v_inst8 : alu_control
PORT MAP(aluop => SYNTHESIZED_WIRE_8,
		 funct3 => ins(14 DOWNTO 12),
		 funct7 => ins(31 DOWNTO 25),
		 aluctr => SYNTHESIZED_WIRE_9);


b2v_inst9 : alu
PORT MAP(clk => clk_div_ALTERA_SYNTHESIZED(2),
		 alu_ctr => SYNTHESIZED_WIRE_9,
		 data1 => SYNTHESIZED_WIRE_10,
		 data2 => SYNTHESIZED_WIRE_11,
		 zero => zero,
		 alu_res => SYNTHESIZED_WIRE_12);

rst <= reset;
pas <= pause;
clk_div <= clk_div_ALTERA_SYNTHESIZED;
instruction <= ins;
mem_data_read <= rwd;

END bdf_type;