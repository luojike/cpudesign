library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;
use work.pc.all;

-- Entity core:
-- The core CPU that consists of components defined in different files.
entity core is
    port (
        clk : in std_logic;                         -- Clock signal.
        ir : in std_logic_vector(31 downto 0);      -- The instruction to be interpreted.

        reset_pc : in std_logic;
    );
end core;

architecture structural of main is
    component pc port(
        i_clk : in std_logic;
        i_reset : in std_logic;
        i_mode : in std_logic_vector(1 downto 0);
        i_pc_off : in std_logic_vector(31 downto 0);
        i_abs_addr : in std_logic_vector(31 downto 0);

        q_val : out std_logic_vector(31 downto 0);
        q_val_next : out std_logic_vector(31 downto 0);
    );
    end component;
    -- Corresponding signals.
    signal pc_val : std_logic_vector(31 downto 0);
    signal pc_val_next : std_logic_vector(31 downto 0);
    signal pc_mode : std_logic_vector(1 downto 0);
    signal pc_off : std_logic_vector(31 downto 0);


    component alu port(
        i_data1 : in std_logic_vector(31 downto 0); -- Wired to signal [rs1] defined below.
        i_data2 : in std_logic_vector(31 downto 0); -- Wired to signal [rs2] defined below.
        i_op : in alu_op_t;                         -- Wired to signal [alu_op] defined below.
        q_res : out std_logic_vector(31 downto 0);
        q_br : out boolean
    );
    end component;
    -- Corresponding signals.
    signal alu_br_flag : boolean;

    component control_unit port(
        ir : in std_logic_vector(31 downto 0);      -- Wired to ir from core's input.
        pc : in std_logic_vector(31 downto 0);      -- Wired to signal [pc_val] defined above.

        br_flag : in boolean;                       -- Wired to signal [alu_br_flag] defined above.

        res_sel : out std_logic_vector(1 downto 0);
        alu_op : out alu_op_t;                     
        pc_off : out std_logic_vector(31 downto 0);
        pc_mode : out std_logic_vector(1 downto 0);

        rs1 : out std_logic_vector(4 downto 0);
        rs2 : out std_logic_vector(4 downto 0);
        en_write_reg : out boolean;
        rd : out std_logic_vector(4 downto 0);

        en_imm : out std_logic_vector(0 downto 0);
        imm : out std_logic_vector(31 downto 0);  

        en_write_ram : out boolean;              
        ld_sign_ex : out boolean;                
        ld_sz : out std_logic_vector(1 downto 0);
        st_sz : out std_logic_vector(1 downto 0)
    );
    end component;
    
    signal rs1 : std_logic_vector(4 downto 0);
    signal rs2 : std_logic_vector(4 downto 0);
    signal rd : std_logic_vector(4 downto 0);
    signal alu_op : alu_op_t;
    signal res_sel : std_logic_vector(1 downto 0);
    signal 
end structural;