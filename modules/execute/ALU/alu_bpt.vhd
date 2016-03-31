library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_bpt is 
port(
		pwr_en : in std_logic;
		B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_bpt;

architecture behave of alu_bpt is 
signal bpt_res, bpt_res_gated : std_logic_vector(31 downto 0);
begin 
bpt_res_gated <= bpt_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(B,pwr_en, bpt_res, bpt_res_gated)
begin
	bpt_res <= B;
	
	C <= bpt_res_gated and (bpt_res_gated'range => pwr_en);
end process;
end behave; 