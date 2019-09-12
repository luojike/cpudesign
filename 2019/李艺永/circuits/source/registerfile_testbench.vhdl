library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerfile_testbench is
end registerfile_testbench;

architecture behav of registerfile_testbench is
    component registerfile
        port(
            clk : in std_logic;                     -- Needed for writing rd.
            rs1 : in std_logic_vector(4 downto 0);  -- The index of rs1
            rs2 : in std_logic_vector(4 downto 0);  -- The index of rs2
            rd : in std_logic_vector(4 downto 0);   -- The index of rd
            i_data : in std_logic_vector(31 downto 0);  -- The data to write to rd
            en_write : in boolean;  -- Indicates whether to write rd

            q_rs1 : out std_logic_vector(31 downto 0);  -- The result of reading from rs1
            q_rs2 : out std_logic_vector(31 downto 0)   -- The result of reading from rs2
        );
    end component;
    signal clk : std_logic := '0';
    signal rs1 : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2 : std_logic_vector(4 downto 0) := (others => '0');
    signal rd : std_logic_vector(4 downto 0);
    signal i_data : std_logic_vector(31 downto 0);
    signal en_write : boolean;
    signal q_rs1 : std_logic_vector(31 downto 0);
    signal q_rs2 : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;
begin
    c_reg : registerfile
        port map(
            clk => clk,
            rs1 => rs1,
            rs2 => rs2,
            rd => rd,
            i_data => i_data,
            en_write => en_write,
            q_rs1 => q_rs1,
            q_rs2 => q_rs2
        );

    clk <=  '1' after clk_period when clk = '0' else
    '0' after clk_period when clk = '1';

    process
    begin
        wait for 50 ns;

        rd <= std_logic_vector(to_unsigned(5, 5));

        wait for 50 ns;
        
        rs1 <= std_logic_vector(to_unsigned(5, 5));
        rs2 <= std_logic_vector(to_unsigned(3, 5));
        
    end process;

end behav;