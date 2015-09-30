library IEEE;
use IEEE.STD_LOGIC_1164.all; 

library work;
use work.constants.all;

entity branch_control is
	port(
	is_branch : in std_logic;
	funct3 : in std_logic_vector(FUNCT3_WIDTH - 1 downto 0);
	ALU_result : in std_logic_vector(31 downto 0);
	branch : out std_logic
	);
end branch_control;

architecture behave of branch_control is
signal ALU_res_zero : std_logic;
begin
	
combi: process(ALU_result, funct3, is_branch)
begin 
	case ALU_result is
		when x"00000000" => ALU_res_zero <= '1';
		when others => ALU_res_zero <= '0';
	end case;
	
	case funct3 is
		when BEQ => branch <= ALU_res_zero and is_branch;
		when BNE => branch <= not ALU_res_zero and is_branch;
		when BLT | BLTU => branch <= ALU_res_zero and is_branch;
		when BGE | BGEU => branch <= not ALU_res_zero and is_branch;
		when others => branch <= '0';
	end case;
	
end process;
	
end behave;