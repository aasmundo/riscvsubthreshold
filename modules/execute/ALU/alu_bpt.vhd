library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_bpt is 
port(
		pwr_en : in std_logic;
		B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_bpt;

architecture behave of alu_bpt is 
signal bpt_res : std_logic_vector(31 downto 0);
begin 
C <= bpt_res when (pwr_en = '1') else UNKNOWN_32BIT;
bpt_res <= B;
end behave; 