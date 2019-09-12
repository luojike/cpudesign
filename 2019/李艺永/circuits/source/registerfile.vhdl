library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Entity registerfile:
-- Controls read to rs1 and rs2 and write to rd register
entity registerfile is
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
end registerfile;

architecture behav of registerfile is
    -- The actual type of register storage.
    -- TODO: array(1 to 32).
    type RegBlock is array(0 to 32) of std_logic_vector(31 downto 0);
    -- The actual register storage.
    signal reg_blocks : RegBlock := (
        -- Initialize all registers to 0
        others => (others => '0')
    );

begin
    update: process(clk, rd, rs1, rs2, reg_blocks)
    begin
        -- Update result of rs1 register
        if (unsigned(rs1) /= 0) then
            q_rs1 <= reg_blocks(to_integer(unsigned(rs1)));
        else
            -- register x0 is hardwired with all bits equals to 0.
            q_rs1 <= (others => '0');
        end if;

        -- Update result of rs2 register
        if (unsigned(rs2) /= 0) then
            q_rs2 <= reg_blocks(to_integer(unsigned(rs2)));
        else
            -- register x0 is hardwired with all bits equals to 0.
            q_rs2 <= (others => '0');
        end if;

        -- Synchronously update rd on certain condition upon rising edge.
        -- Clk is important.
        if rising_edge(clk) then
            if (en_write = true and (unsigned(rd) /= 0)) then
                reg_blocks(to_integer(unsigned(rd))) <= i_data;
            end if;
        end if;
    end process update;
end behav;