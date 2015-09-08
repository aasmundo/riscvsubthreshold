library IEEE;
use IEEE.STD_LOGIC_1164.all;

package constants is 
	--ALU constants--
	constant FUNCT3_WIDTH  : integer := 3;
	
	constant ALU_SLL_OPCODE     : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "001";	
	constant ALU_SRL_SRA_OPCODE : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "101";
	constant ALU_ADD_SUB_OPCODE : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "000";
	constant ALU_SLT_OPCODE     : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "010";
	constant ALU_SLTU_OPCODE    : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "011";
	constant ALU_AND_OPCODE     : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "111";
	constant ALU_OR_OPCODE      : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "110";
	constant ALU_XOR_OPCODE     : std_logic_vector(FUNCT3_WIDTH - 1 downto 0) := "100";
	
	--Other constants--
	
	constant INSTRUCTION_MEM_WIDTH : integer := 8;
	
	

end constants;