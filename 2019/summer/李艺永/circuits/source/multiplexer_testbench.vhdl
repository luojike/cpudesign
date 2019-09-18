library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.multiplexer_inp_type.all;

entity multiplexer_testbench is
end multiplexer_testbench;

architecture behav of multiplexer_testbench is
    component multiplexer
    generic (N : natural);
    port(
        selector : in std_logic_vector(N downto 0);                      
        x : in word_arr;
        y : out std_logic_vector(31 downto 0)                            
    );
    end component;

    signal selector : std_logic_vector(0 downto 0);
    signal x1 : std_logic_vector(31 downto 0);
    signal x2 : std_logic_vector(31 downto 0);
    signal y : std_logic_vector(31 downto 0);
begin

    c_mux : multiplexer
        generic map(N => 0)
        port map(
            selector => selector,
            x(0) => x1,
            x(1) => x2,
            y => y
        );

    process
    begin
        wait for 50 ns;
        x1 <= (others => '1');

        wait for 50 ns;
        selector <= "1";

        x1 <= (
            0 => '1',
            1 => '1',
            others => '0'
        );

        wait for 50 ns;
        selector <= "0";
    end process;
end behav;