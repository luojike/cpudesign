library ieee;
use ieee.std_logic_1164.all;

package regsprober is
	type regfile is array(natural range<>) of std_logic_vector(31 downto 0);
	signal regsview : regfile(31 downto 0);
end package regsprober;
