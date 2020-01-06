library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rxymem is
generic( data_width: natural:=32;
		 addr_width: natural:=8);
		port(
			clk:in std_logic;
			addrbus: in std_logic_vector((addr_width-1) downto 0);
			databus: out std_logic_vector((data_width-1) downto 0);
			we: in std_logic
			);
end entity;

architecture mem_behav of rxymem is
		type memtype is array(natural range<>) of std_logic_vector(7 downto 0);--address by byte
		signal memdata: memtype((2**addr_width-1) downto 0) ;
		attribute ram_init_file : string;
		attribute ram_init_file of memdata: signal is "rxymem.mif";

begin
		process(clk,addrbus,we)
				variable i: integer;
		begin
			i := to_integer(unsigned(addrbus));
			if(rising_edge(clk))then
				if (we='1') then
					-- assume little-endian
					databus <= memdata(i+3) & memdata(i+2) & memdata(i+1) & memdata(i);
				else
					databus <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
				end if;
			end if;
		end process;
end;