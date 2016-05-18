library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_sll is 
port(
		pwr_en : in std_logic;
		A      : in std_logic_vector(31 downto 0);
		B      : in std_logic_vector(4 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_sll;

architecture behave of alu_sll is 
signal sll_res : std_logic_vector(31 downto 0);
begin 
C <= sll_res when (pwr_en = '1') else UNKNOWN_32BIT;
sll_res <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B))));
end behave; 