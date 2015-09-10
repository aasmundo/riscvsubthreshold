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
	
	--Immediate constants--
	
	constant OPCODE_I_TYPE_A   : std_logic_vector(6 downto 0) := "00-0011"; 
	constant OPCODE_I_TYPE_B   : std_logic_vector(6 downto 0) := "1100111"; 
	constant OPCODE_S_TYPE     : std_logic_vector(6 downto 0) := "0100011";
	constant OPCODE_SB_TYPE    : std_logic_vector(6 downto 0) := "1100011";
	constant OPCODE_U_TYPE     : std_logic_vector(6 downto 0) := "0-10111";
	constant OPCODE_UB_TYPE    : std_logic_vector(6 downto 0) := "1101111";
	constant OPCODE_SHAMT_TYPE : std_logic_vector(6 downto 0) := "0010011";
	
	--Execute constants--
	
	constant ID  : std_logic_vector(1 downto 0) := "00";
	constant MEM : std_logic_vector(1 downto 0) := "01";
	constant WB  : std_logic_vector(1 downto 0) := "10";
	

	

end constants;