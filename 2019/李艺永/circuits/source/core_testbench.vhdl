library ieee;
use ieee.std_logic_1164.all;

entity core_testbench is
end entity;

architecture behav of core_testbench is
    component core is
        port (
            clk : in std_logic;
            reset_pc : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset_pc : std_logic;

begin
    c_core : core
        port map(
            clk => clk,
            reset_pc => reset_pc
        );

    clk <= not clk after 50 ns;

    process
    begin
        wait for 300 ns; 
        reset_pc <= '1';
    end process;

end behav;