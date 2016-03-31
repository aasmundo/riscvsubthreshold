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
signal xor_res, xor_res_gated : std_logic_vector(31 downto 0);
begin 
xor_res_gated <= xor_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, xor_res, xor_res_gated)
begin
	xor_res <= A xor B;
	
	C <= xor_res_gated and (xor_res_gated'range => pwr_en);
end process;
end behave; 