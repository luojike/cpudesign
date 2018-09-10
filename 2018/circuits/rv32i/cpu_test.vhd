LIBRARY ieee;                                                
USE ieee.std_logic_1164.all;                                 
USE ieee.numeric_std.all;

ENTITY cpu_test IS  
END cpu_test;

ARCHITECTURE cpu_test_arch OF cpu_test IS  

-- constants
constant clk_period : time := 20 ns;

-- signals                                                     
SIGNAL clk : STD_LOGIC;  
SIGNAL reset : STD_LOGIC;  
SIGNAL inst_addr : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL inst: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL data_addr : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL data_in : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL data_out : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL data_read : STD_LOGIC;
SIGNAL data_write : STD_LOGIC;

TYPE mem is array(natural range <>) of std_logic_vector(31 downto 0);
signal data_ram : mem(1023 downto 0);
--constant inst_rom : mem(1023 downto 0) := (
--                                            0=>X"00000000";
--											  1=>X"00000004";
--											  -- ........
--											  others=>X"00000000";
--                                          );
 
COMPONENT cpu  
    PORT (  
    clk : IN STD_LOGIC;  
    reset : IN STD_LOGIC;  
    inst_addr : STD_LOGIC_VECTOR(31 downto 0);
    inst: STD_LOGIC_VECTOR(31 downto 0);
    data_addr : STD_LOGIC_VECTOR(31 downto 0);
    data_in : STD_LOGIC_VECTOR(31 downto 0);
    data_out : STD_LOGIC_VECTOR(31 downto 0);
    data_read : STD_LOGIC;
    data_write : STD_LOGIC
    );  
END COMPONENT;

BEGIN  
    cpu1 : cpu  
    PORT MAP (  
-- list connections between master ports and signals  
    clk => clk,  
    reset => reset,  
    inst_addr => inst_addr,  
    inst => inst,
    data_addr => data_addr,
    data_in => data_in,
    data_out => data_out,
    data_read => data_read,
    data_write => data_write
    );
 
for_reset : PROCESS                                                
-- variable declarations                                       
BEGIN                                                         
        reset <= '1';
        wait for 5*clk_period;
        reset <= '0';
        WAIT;                                                         
END PROCESS for_reset;                                             

clk_gen : process  
begin  
    clk<='1';  
    wait for clk_period/2;  
    clk<='0';  
    wait for clk_period/2;  
end process clk_gen;  


inst_fetch : PROCESS(inst_addr)
-- optional sensitivity list                                    
-- (        )                                                   
-- variable declarations                                       
BEGIN                                                           
       case inst_addr is
           when X"00000000" => inst <= X"00000000";
           when X"00000004" => inst <= X"00000004";
           -- .......
           when others => inst <= X"00000000";
       end case;
END PROCESS inst_fetch;                                            

read_data: PROCESS(data_addr, data_read)
begin
    if data_read='1' then
        data_in <= data_ram(TO_INTEGER(UNSIGNED(data_addr)));
    else
        data_in <= X"00000000";
    end if;
end process read_data;

write_data: PROCESS(data_addr, data_write, data_out)
begin
    if data_write='1' then
        data_ram(TO_INTEGER(UNSIGNED(data_addr))) <= data_out;
    end if;
end process write_data;

END cpu_test_arch;
