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
signal and_res, and_res_gated : std_logic_vector(31 downto 0);
begin 
and_res_gated <= and_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, and_res, and_res_gated)
begin
	and_res <= A and B;
	
	C <= and_res_gated and (and_res_gated'range => pwr_en); 
end process;
end behave; 