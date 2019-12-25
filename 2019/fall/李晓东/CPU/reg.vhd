library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity reg is
	port(rest,clk:in std_logic;
		 reg_en: in std_logic_vector(1 downto 0);
		 dr_sel,sr_sel,reg_sel: in std_logic_vector(3 downto 0);
		 from_mem,from_alu: in std_logic_vector(15 downto 0);
		 dr_out,sr_out,reg_out: out std_logic_vector(15 downto 0));
	end reg;
architecture regbank of reg is
	subtype WORD is std_logic_vector(15 downto 0); 
    type   REGISTERARRAY   is array ( 0 to 15 ) of WORD;
	signal reg_bank: REGISTERARRAY;
begin
	dr_out<= reg_bank(conv_integer(dr_sel));
	sr_out<= reg_bank(conv_integer(sr_sel));
	reg_out<=reg_bank(conv_integer(reg_sel));
	process(rest,clk,reg_en)
			variable i: integer range 0 to 15;
	begin
		if rest='0' then
			for i in 0 to 15 loop
		  		reg_bank(i)<="0000000000000000";
			end loop;
		elsif clk'event and clk='1' then
			if reg_en="01" then
			reg_bank(conv_integer(dr_sel))<=from_alu;			
			elsif reg_en="10" then
			reg_bank(conv_integer(dr_sel))<=from_mem;
			end if;
		end if; 
	end process;
end regbank;