library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_or is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_or;

architecture behave of alu_or is 
signal or_res, or_res_gated : std_logic_vector(31 downto 0);
begin 
or_res_gated <= or_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, or_res, or_res_gated)
begin
	or_res <= A or B;
	
	C <= or_res_gated and (or_res_gated'range => pwr_en);
end process;
end behave; 