library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity idc is
	port(
	ir : in std_logic_vector(31 downto 0);
	count :in std_logic;
    funct3:  out std_logic_vector(2 downto 0);
	imm: out std_logic_vector(11 downto 0);
	rs1: out std_logic_vector(4 downto 0) ;
	rs2: out std_logic_vector(4 downto 0);
	rd : out std_logic_vector(4 downto 0);
	imm1: out std_logic_vector(19 downto 0);
	load: out std_logic;
	store: out std_logic;
	lui: out std_logic;
	auipc: out std_logic;
	ri : out std_logic;
	rr : out std_logic;
	jal: out std_logic;
	jalr: out std_logic;
	be : out std_logic;
	ldir : out std_logic;
	XL,DL,CS : out std_logic
	);
end idc;
architecture behav of idc is
	signal opcode:  std_logic_vector(6 downto 0);
	begin
	CS<='0';
    rs1<=ir(19 downto 15);
    rs2<=ir(24 downto 20);
    rd<=ir(11 downto 7);
	funct3<=ir(14 downto 12);
	opcode<=ir(6 downto 0);
	with opcode select
	imm<= ir (31 downto 20) when "0000011"|"1100111"|"0010011",
	      ir(31 downto 25)&ir(11 downto 7) when "0100011",
	      ir(31)&ir(7)&ir(30 downto 25)&ir(11 downto 8) when "1100011" ,
	      (others=>'Z') when others;
	with opcode select
	imm1<= ir(31 downto 12) when "0110111"|"0010111",
	       ir(31)&ir(19 downto 12)&ir(20)&ir(30 downto 21) when "1101111",
	       (others=>'Z') when others;
	with opcode select
	ldir<='0' when "0000011"|"0100011", 
	          '1' when others;
	load<='1' when opcode="0000011" else '0';
	store<='1' when opcode="0100011" else '0';
	lui<='1' when opcode="0110111" else '0';
	auipc<='1' when opcode="0010111" else '0';
	ri<='1' when opcode="0010011" else '0';
	rr<='1' when opcode="0110011" else '0';
	jal<='1' when opcode="1101111" else '0';
	jalr<='1' when opcode="1100111" else '0';
	be<='1' when opcode="1100111" else '0';
	process(count)
    begin
    if(count='0' and opcode="0100011") then
    DL<='0';
	XL<='1';
	else
    DL<='1';
	XL<='0';
    end if;
    end process;
end behav;