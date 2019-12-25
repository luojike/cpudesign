library ieee;
use ieee.std_logic_1164.all;
entity debug_unit is
	port(reg_sel : in std_logic_vector(5 downto 0);
		 reg : in std_logic_vector(15 downto 0);
		 ir : in std_logic_vector(15 downto 0);
		 pc : in std_logic_vector(15 downto 0);
		 sp : in std_logic_vector(15 downto 0);
		 debug_out  : out std_logic_vector(15 downto 0));
	end debug_unit;
architecture bhv of debug_unit is
begin
	PROCESS (reg_sel,reg,ir,pc,sp)
	VARIABLE tmp: STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        IF reg_sel(5 DOWNTO 4) = "00" THEN
            tmp := reg;
        ELSE
            CASE reg_sel IS
                WHEN "111111" => tmp := ir;
                WHEN "111110" => tmp := pc;
                WHEN "010000" => tmp := sp;
                WHEN OTHERS => tmp := x"0000";
            END CASE;
        END IF;
        debug_out <= tmp;
	end process;
end bhv;