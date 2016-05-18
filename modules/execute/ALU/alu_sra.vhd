library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_sra is 
port(
		pwr_en : in std_logic;
		A      : in std_logic_vector(31 downto 0);
		B      : in std_logic_vector(4 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_sra;

architecture behave of alu_sra is 
signal sra_res : std_logic_vector(31 downto 0);
begin 
C <= sra_res when (pwr_en = '1') else UNKNOWN_32BIT;
sra_res <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));
end behave; 