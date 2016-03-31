library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_sltu is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_sltu;

architecture behave of alu_sltu is 
signal sltu_res, sltu_res_gated : std_logic_vector(31 downto 0);
begin 
sltu_res_gated <= sltu_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, sltu_res, sltu_res_gated)
begin
	if(unsigned(A) < unsigned(B)) then sltu_res <= x"00000001";    
    else                               sltu_res <= x"00000000";            
    end if;
    
	C <= sltu_res_gated and (sltu_res_gated'range => pwr_en);
end process;
end behave; 