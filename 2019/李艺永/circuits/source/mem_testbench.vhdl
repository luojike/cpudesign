library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_testbench is
end mem_testbench;

architecture behav of mem_testbench is
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

    signal clk : std_logic := '0';
    signal i_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal i_ld_sz : std_logic_vector(1 downto 0);
    signal i_sign_ex : boolean;
    signal i_data : std_logic_vector(31 downto 0);
    signal i_st_sz : std_logic_vector(1 downto 0);
    signal en_write : boolean;
    signal q_data : std_logic_vector(31 downto 0);
    signal q_ir : std_logic_vector(31 downto 0);
begin
    c_mem : mem
        port map(
            clk => clk,
            i_addr => i_addr,
            i_ld_sz => i_ld_sz,
            i_sign_ex => i_sign_ex,
            i_data => i_data,
            i_st_sz => i_st_sz,
            en_write => en_write,
            q_data => q_data,
            q_ir => q_ir
        );

    clk <=  not clk after 10 ns;
    
    en_write <= false;

    process
    begin
        i_addr <= std_logic_vector(to_unsigned(0, 32));
        wait for 50 ns;

        i_addr <= std_logic_vector(to_unsigned(10, 32));

        wait for 50 ns;

        i_addr <= std_logic_vector(to_unsigned(20, 32));

        wait for 50 ns;

    end process;
end behav;