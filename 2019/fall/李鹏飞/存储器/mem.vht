-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "11/15/2019 15:23:44"
                                                            
-- Vhdl Test Bench template for design  :  mem
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;   
USE ieee.numeric_std.all;                             

ENTITY mem_vhd_tst IS
END mem_vhd_tst;

ARCHITECTURE mem_arch OF mem_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL addrbus : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL databus : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL read : STD_LOGIC;
SIGNAL write : STD_LOGIC;
CONSTANT td: time := 50 ns;
COMPONENT mem
	PORT (
	addrbus : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	databus : BUFFER STD_LOGIC_VECTOR(31 DOWNTO 0);
	read : IN STD_LOGIC;
	write : IN STD_LOGIC
	);
END COMPONENT;


BEGIN
	i1 : mem
	PORT MAP (
-- list connections between master ports and signals
	addrbus => addrbus,
	databus => databus,
	read => read,
	write => write
	);
	
	read <='1' , '0' after 12*td;
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once    
	for i in 0 to 15 loop
		addrbus <= std_logic_vector(to_unsigned(i, 32));  
		wait for td;
	end loop;		  
WAIT;  
                                                     
END PROCESS init;                                           
                                          
END mem_arch;
