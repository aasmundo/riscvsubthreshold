library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.numeric_std.all;

entity branch_target_adder is
port(
		PC_i  : in  std_logic_vector(31 downto 0);
		imm   : in  std_logic_vector(11 downto 0);
		PC_o  : out std_logic_vector(31 downto 0)
	);
end branch_target_adder;

architecture behave of branch_target_adder is
signal signed_imm : signed(12 downto 0);
begin

combi : process(PC_i, imm, signed_imm)
begin
	signed_imm <= signed(imm & '0');
	PC_o <= std_logic_vector(signed(PC_i) + signed_imm);

end process;

end behave;