library ieee;
library lpm;
use ieee.std_logic_1164.all;
USE LPM.LPM_COMPONENTS.ALL;
entity alu is
	port(alu_func: in std_logic_vector(3 downto 0);
	 alu_a,alu_b : in std_logic_vector(15 downto 0);
	        c_in : in std_logic;
	       alu_o : out std_logic_vector(15 downto 0);
	     c,s,z,o : out std_logic);
end alu;
architecture bhv of alu is
COMPONENT lpm_add_sub
GENERIC(lpm_width: NATURAL;
    lpm_direction: STRING;
         lpm_type: STRING;
         lpm_hint: STRING);
PORT(dataa: IN  STD_LOGIC_VECTOR(lpm_width - 1 DOWNTO 0);
     datab: IN  STD_LOGIC_VECTOR(lpm_width - 1 DOWNTO 0);
       cin: IN  STD_LOGIC;
    result: OUT STD_LOGIC_VECTOR(lpm_width - 1 DOWNTO 0);
      cout: OUT STD_LOGIC;
  overflow: OUT STD_LOGIC);
END COMPONENT;
	SIGNAL addsub_cin: STD_LOGIC;
    SIGNAL addsub_c  : STD_LOGIC;
    SIGNAL addsub_o  : STD_LOGIC;
    SIGNAL addsub_a  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL addsub_b  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL addsub_r  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL r         : STD_LOGIC_VECTOR(15 DOWNTO 0);
begin
ALU_ADDSUB: lpm_add_sub
GENERIC MAP(lpm_width => 16,
        lpm_direction => "ADD",
             lpm_type => "LPM_ADD_SUB",
             lpm_hint => "ONE_INPUT_IS_CONSTANT = NO,CIN_USED = YES")
PORT MAP(dataa => addsub_a,
         datab => addsub_b,
           cin => addsub_cin,
        result => addsub_r,
          cout => addsub_c,
      overflow => addsub_o);

		addsub_a <= alu_a;
    	addsub_b <= alu_b     WHEN alu_func = "0000" ELSE
                alu_b     WHEN alu_func = "0011" ELSE
                X"0000"   WHEN alu_func = "0101" ELSE
                NOT alu_b WHEN alu_func = "0001" ELSE
                NOT alu_b WHEN alu_func = "0010" ELSE
                NOT alu_b WHEN alu_func = "0100" ELSE
                X"1111"    WHEN alu_func = "0110" ELSE
                "XXXXXXXXXXXXXXXX";
    	addsub_cin <= '0'        WHEN alu_func = "0000" ELSE
                  c_in       WHEN alu_func = "0011" ELSE 
                  '1'        WHEN alu_func = "0101" ELSE
                  '1'        WHEN alu_func = "0100" ELSE
                  '1'        WHEN alu_func = "0010" ELSE
                  NOT c_in   WHEN alu_func = "0100" ELSE 
                  '0'        WHEN alu_func = "0110" ELSE
                  'X';
		r <= addsub_r                       WHEN alu_func = "0000"  ELSE
         addsub_r                       WHEN alu_func = "0011"  ELSE
         addsub_r                       WHEN alu_func = "0101"  ELSE
         addsub_r                       WHEN alu_func = "0100"  ELSE
         addsub_r                       WHEN alu_func = "0010"  ELSE
         addsub_r                       WHEN alu_func = "0100"  ELSE
         addsub_r                       WHEN alu_func = "0110"  ELSE
         alu_a(14 DOWNTO 0) & '0'       WHEN alu_func = "0111"  ELSE
         alu_a(15) & alu_a(15 DOWNTO 1) WHEN alu_func = "1000"  ELSE
         '0' & alu_a(15 DOWNTO 1)       WHEN alu_func = "1001"  ELSE
         alu_b                          WHEN alu_func = "1010"  ELSE
         alu_a AND alu_b                WHEN alu_func = "1011"  ELSE
         alu_a AND alu_b                WHEN alu_func = "1100" ELSE
         alu_a OR  alu_b                WHEN alu_func = "1101"   ELSE
         alu_a XOR alu_b                WHEN alu_func = "1110"  ELSE
         NOT alu_a                      WHEN alu_func = "1111"  ELSE
         "XXXXXXXXXXXXXXXX";
    c <= addsub_c     WHEN alu_func = "0000" ELSE
         addsub_c     WHEN alu_func = "0011" ELSE
         NOT addsub_c WHEN alu_func = "0100" ELSE
         NOT addsub_c WHEN alu_func = "0010" ELSE
         NOT addsub_c WHEN alu_func = "0100" ELSE
         c_in         WHEN alu_func = "0101" ELSE
         c_in         WHEN alu_func = "0110" ELSE
         alu_a(15)    WHEN alu_func = "0111" ELSE
         alu_a(0)     WHEN alu_func = "1000"  ELSE
         alu_a(0)     WHEN alu_func = "1001" ELSE
         '0';
    o <= addsub_o                WHEN alu_func = "0000" ELSE
         addsub_o                WHEN alu_func = "0011" ELSE
         addsub_o                WHEN alu_func = "0101" ELSE
         addsub_o                WHEN alu_func = "0100" ELSE
         addsub_o                WHEN alu_func = "0010" ELSE
         addsub_o                WHEN alu_func = "0100" ELSE
         addsub_o                WHEN alu_func = "0110" ELSE
         alu_a(15) XOR alu_a(14) WHEN alu_func = "0111" ELSE
         '0'                     WHEN alu_func = "1000"  ELSE
         alu_a(15)               WHEN alu_func = "1001" ELSE
         '0';
    s <= r(15);
    z <= '1' WHEN r = X"0000" ELSE
         '0';
    alu_o <= r;  	
end bhv;