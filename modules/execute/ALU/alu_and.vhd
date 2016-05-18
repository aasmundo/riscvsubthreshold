library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_and is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_and;

architecture behave of alu_and is 
signal and_res : std_logic_vector(31 downto 0);
begin 
C <= and_res when (pwr_en = '1') else UNKNOWN_32BIT;
and_res <= A and B;
end behave; 