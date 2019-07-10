library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity dse is
	port(
	clk:in std_logic;
	q:in std_logic_vector(7 downto 0);
	funct3:in std_logic_vector(2 downto 0);
	load: in std_logic;
	store: in std_logic;
	imm:in std_logic_vector(11 downto 0);
	src1:in std_logic_vector(31 downto 0);
	address:out std_logic_vector(7 downto 0)
	);
end dse;
architecture behav of dse is
signal lx:std_logic:='0';
signal imm1:std_logic_vector(31 downto 0);
	begin
    --imm1 <= resize(imm, imm1'length);
	process(clk)
	begin
		if(clk'event and clk='1') then
		if(load='1') then
		if(lx='0') then
		address<=std_logic_vector(imm+src1)(7 downto 0);
		else
		address<=q;
		end if;
	    case lx is
		when '0'=>
		lx<='1';
		when '1'=>
		lx<='0';
		end case;
		elsif(store='1') then
		if(lx='0') then
		address<=std_logic_vector(imm+src1)(7 downto 0);
		else
		address<=q;
		end if;
	    case lx is
		when '0'=>
		lx<='1';
		when '1'=>
		lx<='0';
		end case;
		else
		address<=q;
		end if;
		end if;
    end process;
end behav;


