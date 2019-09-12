library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc_mem_testbench is
end pc_mem_testbench;

architecture behav of pc_mem_testbench is
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

    component mem
    port (
        -- Input.
        clk : in std_logic;                             -- Controls write.
        -- For Load.
        i_addr : in std_logic_vector(31 downto 0);      -- Address to access.
        i_ld_sz : in std_logic_vector(1 downto 0);      -- The size to load: BYTE_SZ, HALFW_SZ, or WRD_SZ.
        i_sign_ex : in boolean;                         -- True for reading sign-extended value, false for reading unsigned.

        -- For Store.
        i_data : in std_logic_vector(31 downto 0);      -- Input data to store in [i_addr].
        i_st_sz : in std_logic_vector(1 downto 0);      -- The size to store. Same as [i_ld_sz].
        en_write : in boolean;                          -- Write gate.

        -- Output.
        q_data : out std_logic_vector(31 downto 0);     -- The 4-byte data output.
        q_ir : out std_logic_vector(31 downto 0)        -- The instruction to load.
    );
    end component;

    signal i_ld_sz : std_logic_vector(1 downto 0);
    signal i_sign_ex : boolean;
    signal i_data : std_logic_vector(31 downto 0);
    signal i_st_sz : std_logic_vector(1 downto 0);
    signal en_write : boolean;
    signal q_data : std_logic_vector(31 downto 0);
    signal q_ir : std_logic_vector(31 downto 0);

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

    c_mem : mem
        port map(
            clk => clk,
            i_addr => q_val,
            i_ld_sz => i_ld_sz,
            i_sign_ex => i_sign_ex,
            i_data => i_data,
            i_st_sz => i_st_sz,
            en_write => en_write,
            q_data => q_data,
            q_ir => q_ir
        );

    clk <= not clk after 50 ns;

    process
    begin
        wait for 600 ns;
        i_reset <= '1', '0' after 300 ns;
    end process;
end behav;