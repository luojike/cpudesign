library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc_testbench is
end pc_testbench;

architecture behav of pc_testbench is
    component pc
        port(
            i_clk : in std_logic;
            i_reset : in std_logic;
            i_mode : in std_logic_vector(1 downto 0);       -- See below the arch body.
            i_pc_off : in std_logic_vector(31 downto 0);    -- The offset to add.
            i_abs_addr : in std_logic_vector(31 downto 0);  -- The absolute address wired directly from ALU.

            q_val : out std_logic_vector(31 downto 0);      -- The val of pc register.
            q_val_next : out std_logic_vector(31 downto 0)  -- The next val of pc register in NORMAL mode. Used in branches.
        );
    end component;

    signal clk : std_logic := '0';
    signal i_reset : std_logic := '0';
    signal i_mode : std_logic_vector(1 downto 0);
    signal i_pc_off : std_logic_vector(31 downto 0);
    signal i_abs_addr : std_logic_vector(31 downto 0);
    signal q_val : std_logic_vector(31 downto 0);
    signal q_val_next : std_logic_vector(31 downto 0);
begin
    c_pc : pc
    port map(
        i_clk => clk,
        i_reset => i_reset,
        i_mode => i_mode,
        i_pc_off => i_pc_off,
        i_abs_addr => i_abs_addr,
        q_val => q_val,
        q_val_next => q_val_next
    );

    clk <= not clk after 10 ns;

    process
    begin
        -- Test for reset
        wait for 50 ns;
        i_reset <= '1';
        wait for 10 ns;
        i_reset <= '0';
        wait for 40 ns;

        -- Test for PC-relative jump.
        i_mode <= "01";
        i_pc_off <= std_logic_vector(to_unsigned(8, 32));  -- forward 8 bytes.
        wait for 50 ns;
    end process;
end behav;