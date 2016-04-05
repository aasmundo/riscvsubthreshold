library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_xor is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_xor;

architecture behave of alu_xor is 
signal xor_res : std_logic_vector(31 downto 0);
begin 
C <= xor_res when (pwr_en = '1') else UNKNOWN_32BIT;
xor_res <= A xor B;
end behave; 