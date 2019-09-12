library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
    port(
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
end entity;

architecture mem_behav of mem is
    constant BYTE_SZ : std_logic_vector(1 downto 0) := "00";
    constant HALFW_SZ : std_logic_vector(1 downto 0) := "01";
    constant WRD_SZ : std_logic_vector(1 downto 0) := "10";

    type memtype is array(natural range<>) of std_logic_vector(7 downto 0);
    signal memdata: memtype(4095 downto 0) := (
        -- LW x1, x0, 12
        0 => X"83",
        1 => X"20",
        2 => X"C0",
        3 => X"00",

        -- ADDI x2, x1, 2
        4 => X"13",
        5 => X"81",
        6 => X"20",
        7 => X"00",

        -- Holes.
        8 => X"00",
        9 => X"00",
        10 => X"00",
        11 => X"00",
        
        12 => X"02",
        others => X"11"
    );

begin
    -- Load instructions.
    load_data: process(i_addr, memdata, i_ld_sz)
        variable i: integer;
    begin
        i := to_integer(unsigned(i_addr));
        -- Little-endian
        case i_ld_sz is
            when WRD_SZ =>
                q_data <= memdata(i + 3) & memdata(i + 2) & memdata(i + 1) & memdata(i);
            when HALFW_SZ =>
                q_data(15 downto 0) <= memdata(i + 1) & memdata(i);
                case i_sign_ex is
                    when true =>
                        -- Sign-extended.
                        q_data(31 downto 16) <= (others => q_data(15));
                    when others =>
                        -- Zero-extended.
                        q_data(31 downto 16) <= (others => '0');
                end case;
            when BYTE_SZ =>
                q_data(7 downto 0) <= memdata(i);
                case i_sign_ex is
                    when true =>
                        -- Sign-extended.
                        q_data(31 downto 8) <= (others => q_data(7));
                    when others =>
                        -- Zero-extended.
                        q_data(31 downto 8) <= (others => '0');
                end case;
            when others =>
                null;
        end case;
    end process load_data;

    -- Asynchronously read ir.
    load_ir: process(i_addr, memdata)
        variable i: integer;
    begin
        i := to_integer(unsigned(i_addr));
        if (i <= 4095 and i >= 0) then
            q_ir <= memdata(i + 3) & memdata(i + 2) & memdata(i + 1) & memdata(i);
        end if;
    end process load_ir;

    -- Write is limitted.
    store_data: process(clk, i_addr, i_data, i_st_sz, en_write)
        variable i: integer;
    begin
        i := to_integer(unsigned(i_addr));

        -- Write to RAM only takes place upon rising_edge.
        if rising_edge(clk) then
            if (en_write = true) then
                case i_st_sz is
                    when BYTE_SZ =>
                        memdata(i) <= i_data(7 downto 0);
                    when HALFW_SZ =>
                        memdata(i) <= i_data(7 downto 0);
                        memdata(i + 1) <= i_data(15 downto 8);
                    when WRD_SZ =>
                        memdata(i) <= i_data(7 downto 0);
                        memdata(i + 1) <= i_data(15 downto 8);
                        memdata(i + 2) <= i_data(23 downto 16);
                        memdata(i + 3) <= i_data(31 downto 24);
                    when others =>
                end case;
            end if;
        end if;
    end process store_data;
end;