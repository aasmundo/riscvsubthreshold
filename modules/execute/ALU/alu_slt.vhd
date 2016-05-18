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
signal slt_res : std_logic_vector(31 downto 0);
begin 
C <= slt_res when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, slt_res)
begin
	if(signed(A) < signed(B))     then  slt_res <= x"00000001";    
    else                                slt_res <= x"00000000";    
    end if;
end process;
end behave; 