library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants.all;

entity register_set is
    Port ( 
        I_clk    : in STD_LOGIC;
        I_en     : in STD_LOGIC;
        I_dataD  : in STD_LOGIC_VECTOR (XLENM1 downto 0); -- 要写入REGD的数据
        I_selRS1 : in STD_LOGIC_VECTOR (4 downto 0);      -- 为regrs1选择行
        I_selRS2 : in STD_LOGIC_VECTOR (4 downto 0);      -- 为regrs2选择行
        I_selD   : in STD_LOGIC_VECTOR (4 downto 0);      -- 为REGD选择行
        I_we     : in STD_LOGIC;                          -- REGD的写启用
        O_dataA  : out STD_LOGIC_VECTOR (XLENM1 downto 0);-- Regrs1数据输出
        O_dataB  : out STD_LOGIC_VECTOR (XLENM1 downto 0) -- Regrs2数据输出
    );
end register_set;

architecture Behavioral of register_set is
    type store_t is array (0 to 31) of std_logic_vector(XLENM1 downto 0);
    signal regs: store_t := (others => X"00000000");
    signal dataAout: STD_LOGIC_VECTOR (XLENM1 downto 0) := (others=>'0');
    signal dataBout: STD_LOGIC_VECTOR (XLENM1 downto 0) := (others=>'0');
begin

	process(I_clk, I_en)
	begin
		if rising_edge(I_clk) and I_en='1' then
			dataAout <= regs(to_integer(unsigned(I_selRS1)));
			dataBout <= regs(to_integer(unsigned(I_selRS2)));
			if (I_we = '1') then
				regs(to_integer(unsigned(I_selD))) <= I_dataD;
			end if;
		end if;
	end process;
	
	O_dataA <= dataAout;
	O_dataB <= dataBout;

end Behavioral;
