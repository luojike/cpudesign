library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;
use work.multiplexer_inp_type.all;

-- Entity core:
-- The core CPU + RAM.
-- Integrating the RAM into the core is a bit clumsy. The only
-- reason I'm doing so is because I've omitted the memory controller part.
entity core is
    port (
        clk : in std_logic;                         -- Clock signal.
        reset_pc : in std_logic;

        -- These output are used for inspecting correctness.
        q_alu_op        : out alu_op_t;
        q_alu_br_flag   : out boolean;
        q_alu_res       : out std_logic_vector(31 downto 0);
        q_mem_res       : out std_logic_vector(31 downto 0);
        q_ir            : out std_logic_vector(31 downto 0);
        q_rs1_data      : out std_logic_vector(31 downto 0);
        q_rs2_data      : out std_logic_vector(31 downto 0);
        q_pc_val        : out std_logic_vector(31 downto 0)
    );
end core;

architecture structural of core is
    component registerfile
        port(
            clk : in std_logic;
            rs1 : in std_logic_vector(4 downto 0);
            rs2 : in std_logic_vector(4 downto 0);
            rd : in std_logic_vector(4 downto 0);
            i_data : in std_logic_vector(31 downto 0);
            en_write : in boolean;

            q_rs1 : out std_logic_vector(31 downto 0);
            q_rs2 : out std_logic_vector(31 downto 0)
        );
    end component;

    component mem
        port(
            clk : in std_logic;
            -- For Load.
            i_addr : in std_logic_vector(31 downto 0);
            i_ld_sz : in std_logic_vector(1 downto 0);
            i_sign_ex : in boolean;
    
            -- For Store.
            i_data : in std_logic_vector(31 downto 0);
            i_st_sz : in std_logic_vector(1 downto 0);
            en_write : in boolean;

            q_data : out std_logic_vector(31 downto 0);
            q_ir : out std_logic_vector(31 downto 0)
        );
    end component;

    component multiplexer
        generic (N : natural);
        port(
            selector : in std_logic_vector(N downto 0);                      
            x : in word_arr;
            y : out std_logic_vector(31 downto 0)                            
        );
    end component;

    component pc
        port(
            i_clk : in std_logic;
            i_reset : in std_logic;
            i_mode : in std_logic_vector(1 downto 0);
            i_pc_off : in std_logic_vector(31 downto 0);
            i_abs_addr : in std_logic_vector(31 downto 0);

            q_val : out std_logic_vector(31 downto 0);
            q_val_next : out std_logic_vector(31 downto 0)
        );
    end component;

    component alu
        port(
            i_data1 : in std_logic_vector(31 downto 0); -- Wired to signal [rs1] defined below.
            i_data2 : in std_logic_vector(31 downto 0); -- Wired to signal [rs2] defined below.
            i_op : in alu_op_t;                         -- Wired to signal [alu_op] defined below.
            q_res : out std_logic_vector(31 downto 0);
            q_br : out boolean
        );
    end component;

    component control_unit 
        port(
            ir : in std_logic_vector(31 downto 0);      -- Wired to ir from core's input.
            pc : in std_logic_vector(31 downto 0);      -- Wired to signal [pc_val] defined above.

            br_flag : in boolean;                       -- Wired to signal [alu_br_flag] defined above.

            res_sel : out std_logic_vector(1 downto 0);
            alu_op : out alu_op_t;
            pc_alu_sel : out std_logic_vector(0 downto 0);
            pc_off : out std_logic_vector(31 downto 0);
            pc_mode : out std_logic_vector(1 downto 0);

            rs1 : out std_logic_vector(4 downto 0);
            rs2 : out std_logic_vector(4 downto 0);
            en_write_reg : out boolean;
            rd : out std_logic_vector(4 downto 0);

            en_imm : out std_logic_vector(0 downto 0);  -- Wired to [imm_rs2_sel]
            imm : out std_logic_vector(31 downto 0);  

            en_write_ram : out boolean;              
            ld_sign_ex : out boolean;                
            ld_sz : out std_logic_vector(1 downto 0);
            st_sz : out std_logic_vector(1 downto 0)
        );
    end component;

    signal alu_op : alu_op_t;                               -- ALU operation.
    signal alu_br_flag : boolean;                           -- Conditional branch flag.

    signal alu_mem_pc_sel : std_logic_vector(1 downto 0) := "00";   -- Selector among ALU res, mem load and pc register.
    signal alu_mem_pc_res : std_logic_vector(31 downto 0);  -- Selected value.
    signal alu_res : std_logic_vector(31 downto 0);         -- ALU result.
    signal mem_res : std_logic_vector(31 downto 0);         -- Mem load value.
    signal pc_val_next : std_logic_vector(31 downto 0);     -- Next PC value under normal state.

    signal imm_rs2_sel : std_logic_vector(0 downto 0) := "0";      -- Selector among immediate from IR and register rs2.
    signal rs2_imm_res : std_logic_vector(31 downto 0);     -- Selected value.
    signal ir_imm : std_logic_vector(31 downto 0);          -- immediate extracted from ir(if it's valid).

    signal rs1 : std_logic_vector(4 downto 0) := (others => '0');              -- rs1 index.
    signal rs2 : std_logic_vector(4 downto 0) := (others => '0');              -- rs2 index.
    signal rs1_data : std_logic_vector(31 downto 0) := (others => '0');        -- data read from rs1.
    signal rs2_data : std_logic_vector(31 downto 0) := (others => '0');        -- data read from rs2.
    signal rd : std_logic_vector(4 downto 0) := (others => '0');               -- rd index.

    signal pc_off : std_logic_vector(31 downto 0);          -- PC-relative offset.
    signal pc_mode : std_logic_vector(1 downto 0);          -- normal, relative or absolute.

    -- Gates
    signal en_write_reg : boolean;
    signal en_write_ram : boolean;

    signal ir : std_logic_vector(31 downto 0);              -- Instruction Representation.

    signal pc_alu_sel : std_logic_vector(0 downto 0) := "0";       -- Selector between [pc_val] and [alu_res].
    signal pc_alu_res : std_logic_vector(31 downto 0) := (others => '0');    -- Selected address.
    signal pc_val : std_logic_vector(31 downto 0) := (others => '0');          -- Current PC value.

    signal ld_sz : std_logic_vector(1 downto 0);           -- Load size for mem.
    signal ld_sign_ex : boolean;                            -- Load for size-extended.
    signal st_sz : std_logic_vector(1 downto 0);         -- Store size.

begin

    -- The result is used as a memory address(for loading data or instruction).
    mux_pc_alu : multiplexer
        generic map(N => 0)
        port map(
            selector => pc_alu_sel,
            x(0) => pc_val,
            x(1) => alu_res,
            y => pc_alu_res
        );

    -- The result multiplexer is used for writing rd register.
    mux_alu_mem_pc : multiplexer
        generic map(N => 1)
        port map(
            selector => alu_mem_pc_sel,
            x(0) => alu_res,
            x(1) => mem_res,
            x(2) => pc_val_next,
            y => alu_mem_pc_res
        );

    -- The result multiplexer is used as the 2nd operands to ALU.
    mux_rs2_imm : multiplexer
        generic map(N => 0)
        port map(
            selector => imm_rs2_sel,
            x(0) => rs2_data,
            x(1) => ir_imm,
            y => rs2_imm_res
        );


    c_alu : alu
        port map(
            i_data1 => rs1_data,
            i_data2 => rs2_imm_res,
            i_op => alu_op,
            q_res => alu_res,
            q_br => alu_br_flag
        );

    -- PC register.
    c_pc : pc
        port map(
            i_clk => clk,
            i_reset => reset_pc,
            i_mode => pc_mode,
            i_pc_off => pc_off,
            i_abs_addr => alu_res,      -- Always obtain the absolute target address from ALU.
            q_val => pc_val,
            q_val_next => pc_val_next
        );

    -- Control unit.
    c_control_unit : control_unit
        port map(
            ir => ir,
            pc => pc_val,
            br_flag => alu_br_flag,
            res_sel => alu_mem_pc_sel,
            alu_op => alu_op,
            pc_alu_sel => pc_alu_sel,
            pc_off => pc_off,
            pc_mode => pc_mode,
            rs1 => rs1,
            rs2 => rs2,
            en_write_reg => en_write_reg,
            rd => rd,
            en_imm => imm_rs2_sel,
            imm => ir_imm,
            en_write_ram => en_write_ram,
            ld_sign_ex => ld_sign_ex,
            ld_sz => ld_sz,
            st_sz => st_sz
        );

    -- Registers.
    c_reg_file : registerfile
        port map(
            clk => clk,
            rs1 => rs1,
            rs2 => rs2,
            rd => rd,
            i_data => alu_mem_pc_res,     -- data to write to rd register.
            en_write => en_write_reg,

            q_rs1 => rs1_data,
            q_rs2 => rs2_data
        );

    -- Memory (controller).
    c_mem : mem
        port map(
            clk => clk,
            i_addr => pc_alu_res,
            i_ld_sz => ld_sz,
            i_sign_ex => ld_sign_ex,
            i_data => alu_res,          -- Always write the ALU result to RAM.
            i_st_sz => st_sz,
            en_write => en_write_ram,
            q_data => mem_res,
            q_ir => ir
        );

    -- Write these outputs for inspecting correctness.
    q_alu_op      <= alu_op;
    q_alu_br_flag <= alu_br_flag;
    q_alu_res     <= alu_res;
    q_mem_res     <= mem_res;
    q_ir          <= ir;
    q_rs1_data    <= rs1_data;
    q_rs2_data    <= rs2_data;
    q_pc_val      <= pc_val;

end structural;