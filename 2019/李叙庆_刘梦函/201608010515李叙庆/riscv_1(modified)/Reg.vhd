library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
port(
	clk:in std_logic;
	rst:in std_logic;
	rs1:in std_logic_vector(4 downto 0);  --rs1
	rs2:in std_logic_vector(4 downto 0);  --rs2

	rd_write_ctr:in std_logic;
	rd:in std_logic_vector(4 downto 0);  --rd
	rd_write_data:in std_logic_vector(31 downto 0);  --rd write in

	data_rs1:out std_logic_vector(31 downto 0);  --rs1 read out
	data_rs2:out std_logic_vector(31 downto 0)   --rs2 read out
	);
end reg;

architecture reg_behav of reg is
	type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
	signal regs: regfile(31 downto 0);
	begin
		
		data_rs1 <= std_logic_vector(regs(to_integer(unsigned(rs1)))) ;
		data_rs2 <= std_logic_vector(regs(to_integer(unsigned(rs2)))) ;
		
		wrt:process(clk) --Ê±ÖÓÉÏÉýÑØÐ´Èë
		variable i: integer;
		variable k: integer;
		begin
			i := to_integer(unsigned(rd));
			if(rising_edge(clk)) then
				if(rst='1') then
					-- reset all regs to 0 except reg[0]
					for k in 1 to 31 loop
						regs(k) <= X"00000000";  -- reset to 0
					end loop;
				elsif(rd_write_ctr='1' and i /= 0) then
					regs(i) <= rd_write_data;
				end if;
			end if;
		end process;
		
end reg_behav;