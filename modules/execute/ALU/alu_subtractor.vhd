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
signal subtraction, subtraction_gated : std_logic_vector(31 downto 0);
begin 
subtraction_gated <= subtraction when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, subtraction, subtraction_gated)
begin
	subtraction <= std_logic_vector(signed(A) - signed(B));
	
	C <= subtraction_gated and (subtraction_gated'range => pwr_en); 
end process;
end behave; 