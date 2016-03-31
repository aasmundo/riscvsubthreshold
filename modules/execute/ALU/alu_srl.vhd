library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_srl is 
port(
		pwr_en : in std_logic;
		A      : in std_logic_vector(31 downto 0);
		B      : in std_logic_vector(4 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_srl;

architecture behave of alu_srl is 
signal srl_res, srl_res_gated : std_logic_vector(31 downto 0);
begin 
srl_res_gated <= srl_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, srl_res, srl_res_gated)
begin
	srl_res <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B))));
	
	C <= srl_res_gated and (srl_res_gated'range => pwr_en);
end process;
end behave; 