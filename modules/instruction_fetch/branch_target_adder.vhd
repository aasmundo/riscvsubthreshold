library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity branch_target_adder is
port(
		PC_i  : in  std_logic_vector(PC_WIDTH - 1 downto 0);
		imm   : in  std_logic_vector(19 downto 0);
		PC_o  : out std_logic_vector(PC_WIDTH - 1 downto 0)
	);
end branch_target_adder;

architecture behave of branch_target_adder is
signal signed_imm : signed(20 downto 0);
signal signed_PC : signed(PC_WIDTH downto 0);
begin

combi : process(PC_i, imm, signed_imm, signed_PC)
begin
	signed_imm <= signed(imm & '0');
	signed_PC <= signed('0' & PC_i);
	PC_o <= std_logic_vector(resize(unsigned(signed_PC + signed_imm), PC_o'length));
end process;

end behave;