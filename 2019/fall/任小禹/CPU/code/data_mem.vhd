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
			memwrite:in std_logic;
			funct3:in std_logic_vector(2 downto 0)
			);
end entity;

architecture mem_behav of data_mem is
		type memtype is array(natural range<>) of std_logic_vector(7 downto 0);
		signal memdata: memtype(1023 downto 0) := (
			0 => X"F3",
			1 => X"F2",
			2 => X"01",
			3 => X"80",
			
			4 => X"04",
			5 => X"05",
			6 => X"06",
			7 => X"07",
			others => X"00"
		);

begin
		read_or_write: process(data_addr, memread,memwrite,clk)
				variable i: integer;
		begin
		if(rising_edge(clk)) then
			i := to_integer(unsigned(data_addr));
			if (memread='1') then
				-- assume little-endian
				if(funct3="010"or funct3="110") then     --32bit signed/unsigned
					data_read <= memdata(i+3) & memdata(i+2) & memdata(i+1) & memdata(i);
				elsif(funct3="001") then   --16bit signed
					data_read(15 downto 0) <= memdata(i+1) & memdata(i);
					data_read(31 downto 16) <=(others=>memdata(i+1)(7));
				elsif(funct3="000") then  --8bit signed
					data_read(7 downto 0) <=  memdata(i);
					data_read(31 downto 8) <=(others=>memdata(i)(7));
				elsif(funct3="100") then  --8bit unsigned
					data_read <= X"000000" & memdata(i);
				elsif(funct3="101") then  --16bit unsigned
					data_read <= X"0000" & memdata(i+1) & memdata(i);
				--elsif(funct3="110") then
				end if;
			elsif
				(memwrite='1') then
					memdata(i) <= data_write(7 downto 0);
					if(funct3="001") then
						memdata(i+1) <= data_write(15 downto 8);
					elsif(funct3="010") then
						memdata(i+3) <= data_write(31 downto 24);
						memdata(i+2) <= data_write(23 downto 16);
						memdata(i+1) <= data_write(15 downto 8);
					end if;
			else
				data_read <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			end if;
		end if;
		end process ;
end;