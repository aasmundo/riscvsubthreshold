library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_subtractor is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_subtractor;

architecture behave of alu_subtractor is 
signal subtraction : std_logic_vector(31 downto 0);
begin 
C <= subtraction when (pwr_en = '1') else UNKNOWN_32BIT;
subtraction <= std_logic_vector(signed(A) - signed(B));
end behave; 