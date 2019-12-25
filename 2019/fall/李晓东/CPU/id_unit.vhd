library ieee;
use ieee.std_logic_1164.all;


entity id_unit is 
              port( s: in std_logic;
                    c_flag : in std_logic;
                    s_flag :in std_logic;
                    z_flag : in std_logic;
                    o_flag :in std_logic;
                    ir: in std_logic_vector(15 downto 0);
                    mem_wr :out std_logic;
                    jmp_relv :out std_logic;
                    reg_en :out std_logic_vector(1 downto 0);
                    flag_en :out std_logic_vector(1 downto 0);
                    addr_sel : out std_logic_vector(2 downto 0);
                    sp_en :out std_logic_vector(1 downto 0);
                    dr_sel :out std_logic_vector(3 downto 0);
                    sr_sel :out std_logic_vector(3 downto 0);
                    alu_func: out std_logic_vector(3 downto 0));
end id_unit;

architecture behav of id_unit is
SIGNAL OP : STD_LOGIC_VECTOR(7 DOWNTO 0);
begin 
          
              dr_sel <= ir(7DOWNTO 4);
              sr_sel <= ir(3 DOWNTO 0);
              alu_func <= ir(11 DOWNTO 8);
              OP <= ir(15 DOWNTO 8);
              mem_wr <='1' WHEN S ='0'  AND OP = "10010000"  ELSE            
                      '1'  when S ='1'  AND OP =  "10100000" ELSE             
                      '0';

              reg_en <="01" when s='0' and op(7 downto 4)="0000" and op(3 downto 0)/="0010" and op(3 downto 0)/="1100" else
                     "10" when s='0' and (op="11010000"or op="10000000" or op="10110000") else
                     "00";


              flag_en <="10" when s='0' and op="00010000" else
                      "11"when s='0' and op= "00100000"else
                      "01"when s='0' and op(7 downto 4)="0000" and op(3 downto 0)/="1010" and op(3 downto 0)/="1111" else
                      "00";
               
              jmp_relv <= '1' WHEN OP = "00110000" ELSE                   -- JMP
                '1' WHEN OP = "00110001" AND c_flag = '1' ELSE   -- JC
                '1' WHEN OP = "00110010" AND c_flag = '0' ELSE  -- JNC
                '1' WHEN OP = "00110011" AND s_flag = '1' ELSE   -- JS
                '1' WHEN OP = "00110100" AND s_flag = '0' ELSE  -- JNS
                '1' WHEN OP = "00110101" AND z_flag = '1' ELSE   -- JZ
                '1' WHEN OP = "00110110" AND z_flag = '0' ELSE  -- JNZ
                '1' WHEN OP = "00110111" AND o_flag = '1' ELSE   -- JO
                '1' WHEN OP = "00111000" AND o_flag = '0' ELSE  -- JNO
                '0';
             

              sp_en<="01" when s='0' and op="10100000" else
                "10" when s='0' and op="10110000" else
                 "00";

             addr_sel<="000" when s='0' and op="10100000"else
                     "001"when s='0' and op="10110000" else
                     "010"when s='0' and op="10010000"else
                     "011"when s='0' and op="10000000"else
                     "100"when s='1' or (s='0' and (op="11000000" or op="11010000")) else
                     "111";

end behav;
