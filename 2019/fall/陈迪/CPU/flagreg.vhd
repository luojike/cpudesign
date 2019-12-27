library ieee;
use ieee.std_logic_1164.all;
entity flagreg is
	port(reset,clk : in std_logic;
	     flag_en   : in std_logic_vector(1 downto 0);
	     c,s,z,o   : in std_logic;
	     c_flag,s_flag,z_flag,o_flag : out std_logic);
end flagreg;
architecture bhv of flagreg is
begin
	process(reset,clk)
	begin
		if reset='0' then
			c_flag<='0';
			s_flag<='0';
			z_flag<='0';
			o_flag<='0';
		elsif clk'event and clk='1' then
			if flag_en="01" then
				c_flag<=c;
				s_flag<=s;
				z_flag<=z;
				o_flag<=o;
			elsif flag_en="10" then
				c_flag<='0';
				s_flag<=s;
				z_flag<=z;
				o_flag<=o;
			elsif flag_en="11" then
				c_flag<='1';
				s_flag<=s;
				z_flag<=z;
				o_flag<=o;
			end if;
		end if;
	end process;
end bhv;	
				