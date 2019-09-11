library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package multiplexer_inp_type is
    type word_arr is array (natural range <>) of std_logic_vector(31 downto 0);
end package multiplexer_inp_type;

library ieee;
use work.multiplexer_inp_type.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity 
entity multiplexer is
    generic(N : natural);
    port(
        selector : in std_logic_vector(N downto 0);                         -- Selector as an index.
        x : in word_arr;   -- Input array.
        y : out std_logic_vector(31 downto 0)                               -- Selected result.
    );
end multiplexer;

architecture behav of multiplexer is
begin
    y <= x(to_integer(unsigned(selector)));
end behav;