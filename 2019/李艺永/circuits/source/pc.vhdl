library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.opcodes.all;

-- Entity pc:
-- Represents the pc register
entity pc is
    port(
        i_clk : in std_logic;
        i_reset : in std_logic;
        i_mode : in std_logic_vector(1 downto 0); -- See below the arch body.
        i_pc_off : in std_logic_vector(31 downto 0); -- The offset to add.

        q_val : out std_logic_vector(31 downto 0); -- The content of pc register.
    );
end pc;

architecture behav of pc is
    -- The actual storage.
    signal val : std_logic_vector(31 downto 0);
    -- The next val. This is to avoid cyclics.
    signal val_next : std_logic_vector(31 downto 0);
    signal read_next : std_logic := '0';
    signal read_next_next : std_logic;

begin
    -- Upon rising_clock, update pc value and the flags.
    update_pc: process(clk, i_reset)
    begin
        if (i_reset = '1') then
            val <= (others => '0');
        elsif (rising_edge(clk)) then
            if (read_next = '1') then
                if (i_mode = NORMAL) then
                    val <= val_next;
                elsif (i_mode = RELATIVE) then
                    val <= std_logic_vector(signed(val_next) + signed(i_pc_off));
                elsif (i_mode = ABSOLUTE) then
                    val(31 downto 1) <= i_pc_off(31 downto 1);
                    val(0) <= '0';
                end if;
            end if;
        end if;
    end process update_pc;

    update_read_next: process(clk)
    begin
        if (rising_edge(clk)) then
            -- this value will be read on next time.
            read_next <= read_next_next;
        end if;
    end process update_read_next;

    -- These assignments will run on both rising_edge & falling_edge.
    read_next_next <= not read_next;
    val_next <= std_logic_vector(unsigned(val) + 1);

    q_val <= val;

end behav;
