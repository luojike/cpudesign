library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity data_mem is
		port(
			clk: in std_logic;
			data_addr: in std_logic_vector(31 downto 0);
			data_read: out std_logic_vector(31 downto 0);
			data_write: in std_logic_vector(31 downto 0);
			memread:in std_logic;
			memwrite:in std_logic
			);
end entity;
architecture mem_behav of data_mem is
type memtype is array(natural range<>) of std_logic_vector(7 downto 0);
signal memdata: memtype(1023 downto 0) := (
			0 => X"00",
			1 => X"01",
			2 => X"02",
			3 => X"03",
			4 => X"04",
			5 => X"05",
			6 => X"06",
			7 => X"07",
			others => X"00"
		);
begin
		do_read: process(data_addr, memread,memwrite,clk)
		variable i: integer;
		begin
		if(rising_edge(clk)) then
			i := to_integer(unsigned(data_addr));
			if (memread='1') then
			data_read <= memdata(i+3) & memdata(i+2) & memdata(i+1) & memdata(i);
			elsif
				(memwrite='1') then
				memdata(i+3) <= data_write(31 downto 24);
				memdata(i+2) <= data_write(23 downto 16);
				memdata(i+1) <= data_write(15 downto 8);
				memdata(i) <= data_write(7 downto 0);
			else
				data_read <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			end if;
		end if;
		end process do_read;
end;
