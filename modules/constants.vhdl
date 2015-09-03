library IEEE;
use IEEE.STD_LOGIC_1164.all;

package constants is 
	--ALU constants--
	constant ALU_OPCODE_WIDTH   : integer := 4;
	
	constant ALU_UNSIGNED_POS   : integer := 3;
	
	constant ALU_SRL_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "001";	
	constant ALU_SLL_SRA_OPCODE : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "101";
	constant ALU_ADD_SUB_OPCODE : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "000";
	constant ALU_SLT_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "010";
	constant ALU_SLTU_OPCODE    : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "011";
	constant ALU_AND_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "111";
	constant ALU_OR_OPCODE      : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "110";
	constant ALU_XOR_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 2 downto 0) := "100";
	
	--Other constants--
	
	constant INSTRUCTION_MEM_WIDTH : integer := 8;
	
	

end constants;