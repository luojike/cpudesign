library ieee;
use ieee.std_logic_1164.all;
--下降沿触发的八位数据寄存器
entity Register_Data_8bits is
port(a:in std_logic_vector(7 downto 0);--input
	 clk,ld:in std_logic;--clock pulse, enable(1 is effective)
	 x:out std_logic_vector(7 downto 0));--output
end Register_Data_8bits;

architecture behavior of Register_Data_8bits is
begin
	process(a,clk,ld)
	begin
		if (ld='1') then
			if(clk'event and clk='0') then 
			x<=a;
			end if;
		end if;
	end process;
end behavior;
		