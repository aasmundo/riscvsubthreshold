library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu_adder is 
port(
		pwr_en : in std_logic;
		A, B   : in std_logic_vector(31 downto 0);
		C      : out std_logic_vector(31 downto 0)
	);
end alu_adder;

architecture behave of alu_adder is 
signal addition, addition_gated : std_logic_vector(31 downto 0);
begin 
addition_gated <= addition when (pwr_en = '1') else UNKNOWN_32BIT;

seq : process(A,B,pwr_en, addition, addition_gated)
begin
	addition <= std_logic_vector(signed(A) + signed(B));
	
	C <= addition_gated and (addition'range => not pwr_en);
end process;
end behave; 