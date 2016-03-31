library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_slt is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_slt;

architecture behave of alu_slt is 
signal slt_res, slt_res_gated : std_logic_vector(31 downto 0);
begin 
slt_res_gated <= slt_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, slt_res, slt_res_gated)
begin
	if(signed(A) < signed(B))     then  slt_res <= x"00000001";    
    else                                slt_res <= x"00000000";    
    end if;
    
	C <= slt_res_gated and (slt_res_gated'range => pwr_en);
end process;
end behave; 