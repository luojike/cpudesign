library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
    port(
        clk : in std_logic;                             -- Controls write
        addrbus: in std_logic_vector(31 downto 0);      -- The address to access.
        databus: inout std_logic_vector(31 downto 0);   -- The data to write to or read from.
        en_read: in std_logic;
        en_write: in std_logic
    );
end entity;

architecture mem_behav of mem is
    type memtype is array(natural range<>) of std_logic_vector(7 downto 0);
    signal memdata: memtype(4095 downto 0) := (
        0 => X"04",
        1 => X"00",
        2 => X"00",
        3 => X"00",
        4 => X"08",
        5 => X"00",
        6 => X"00",
        7 => X"00",
        others => X"11"
    );

begin
    -- do_read must not use a clk for synchronization here, because
    -- in that case, instruction read will need 4 clocks to finish.
    do_read: process(addrbus, en_read)
        variable i: integer;
    begin
        i := to_integer(unsigned(addrbus));
        if (en_read = '1') then
            -- assume little-endian
            databus <= memdata(i+3) & memdata(i+2) & memdata(i+1) & memdata(i);
        else
            databus <= (others => 'Z');
        end if;
    end process do_read;

    do_write: process(clk, addrbus, en_write)
        variable i: integer;
    begin
        -- Write to RAM only takes place upon rising_edge.
        if rising_edge(clk) then
            i := to_integer(unsigned(addrbus));
            if (en_write = '1') then
                memdata(i) <= databus(7 downto 0);
                memdata(i + 1) <= databus(15 downto 8);
                memdata(i + 2) <= databus(23 downto 16);
                memdata(i + 3) <= databus(32 downto 24);
            end if;
        end if;
    end process do_write;
end;