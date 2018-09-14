library ieee;
use ieee.numeric_bit.all;

use work.myprober.all;

entity adder is
  -- `i0`, `i1`, and the carry-in `ci` are inputs of the adder.
  -- `s` is the sum output, `co` is the carry-out.
  port (i0, i1 : in bit; ci : in bit; s : out bit; co : out bit);
end adder;

architecture rtl of adder is
		signal cc: bit;
begin
  --  This full-adder architecture contains two concurrent assignments.
  --  Compute the sum.
  s <= i0 xor i1 xor ci;
  --  Compute the carry.
  cc <= (i0 and i1) or (i0 and ci) or (i1 and ci);
  co <= cc;

  -- for test
  process(cc)
  begin
	if(cc='1') then
		test <= test + 1;
	end if;
  end process;

end rtl;
