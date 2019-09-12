library ieee;
use ieee.std_logic_1164.all;
use work.opcodes.all;

entity core_testbench is
end entity;

architecture behav of core_testbench is
    component core is
        port (
            clk : in std_logic;                         -- Clock signal.
            reset_pc : in std_logic;
    
            q_alu_op        : out alu_op_t;
            q_alu_br_flag   : out boolean;
            q_alu_res       : out std_logic_vector(31 downto 0);
            q_mem_res       : out std_logic_vector(31 downto 0);
            q_ir            : out std_logic_vector(31 downto 0);
            q_rs1_data      : out std_logic_vector(31 downto 0);
            q_rs2_data      : out std_logic_vector(31 downto 0);
            q_pc_val        : out std_logic_vector(31 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal reset_pc : std_logic;

    signal ir : std_logic_vector(31 downto 0);

    signal alu_op : alu_op_t;
    signal rs1_data : std_logic_vector(31 downto 0);
    signal rs2_data : std_logic_vector(31 downto 0);
    signal alu_res : std_logic_vector(31 downto 0);
    signal alu_br_flag : boolean;

    signal mem_res : std_logic_vector(31 downto 0);
    signal pc_val  : std_logic_vector(31 downto 0);

begin
    c_core : core
        port map(
            clk => clk,
            reset_pc => reset_pc,
            q_alu_op      => alu_op     ,
            q_alu_br_flag => alu_br_flag,
            q_alu_res     => alu_res    ,
            q_mem_res     => mem_res    ,
            q_ir          => ir         ,
            q_rs1_data    => rs1_data   ,
            q_rs2_data    => rs2_data   ,
            q_pc_val      => pc_val     
        );

    clk <= not clk after 50 ns;

    process
    begin
        wait for 300 ns;
        reset_pc <= '1';
        wait for 200 ns;
        
    end process;

end behav;