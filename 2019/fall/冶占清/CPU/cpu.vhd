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

