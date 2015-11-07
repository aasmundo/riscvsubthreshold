library IEEE;
use IEEE.STD_LOGIC_1164.all;

package constants is 
	--ALU constants--
	constant FUNCT3_WIDTH  : integer := 3;
	constant ALU_OPCODE_WIDTH : integer := 4;
	
	constant ALU_SLL_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0001";	
	constant ALU_SRL_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0101";
	constant ALU_SRA_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "1101";
	constant ALU_ADD_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0000";
	constant ALU_SUB_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "1000";
	constant ALU_SLT_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0010";
	constant ALU_SLTU_OPCODE    : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0011";
	constant ALU_AND_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0111";
	constant ALU_OR_OPCODE      : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0110";
	constant ALU_XOR_OPCODE     : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "0100";
	constant ALU_B_PASS_OPCODE  : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := "1001";
	
	--Other constants--
	
	constant INSTRUCTION_MEM_WIDTH : integer := 12;
	
	--Immediate constants--
	
	--constant OPCODE_I_TYPE_A   : std_logic_vector(6 downto 0) := "00-0011"; --vhdl2008
	constant OPCODE_I_TYPE_A_1   : std_logic_vector(6 downto 0) := "0000011";
	constant OPCODE_I_TYPE_A_2   : std_logic_vector(6 downto 0) := "0010011";
	constant OPCODE_I_TYPE_B   : std_logic_vector(6 downto 0) := "1100111"; 
	constant OPCODE_S_TYPE     : std_logic_vector(6 downto 0) := "0100011";
	constant OPCODE_SB_TYPE    : std_logic_vector(6 downto 0) := "1100011";
	--constant OPCODE_U_TYPE     : std_logic_vector(6 downto 0) := "0-10111"; --vhdl2008
	constant OPCODE_U_TYPE_1     : std_logic_vector(6 downto 0) := "0010111";
	constant OPCODE_U_TYPE_2     : std_logic_vector(6 downto 0) := "0110111";
	constant OPCODE_UB_TYPE    : std_logic_vector(6 downto 0) := "1101111";
	
	--Execute constants--
	
	constant ID  : std_logic_vector(1 downto 0) := "00";
	constant MEM : std_logic_vector(1 downto 0) := "1-"; --vhdl2008
	constant MEM_1 : std_logic_vector(1 downto 0) := "10";
	constant MEM_2 : std_logic_vector(1 downto 0) := "11";
	constant WB  : std_logic_vector(1 downto 0) := "01";
	
	--branch codes--
	
	constant BEQ  : std_logic_vector(2 downto 0) := "000";
	constant BNE  : std_logic_vector(2 downto 0) := "001";
	constant BLT  : std_logic_vector(2 downto 0) := "100";
	constant BGE  : std_logic_vector(2 downto 0) := "101";
	constant BLTU : std_logic_vector(2 downto 0) := "110";
	constant BGEU : std_logic_vector(2 downto 0) := "111";
	

	
	--data-memory--
	constant DATA_MEM_WIDTH : integer := 16;
	
	--misc--
	constant UNKNOWN_32BIT : std_logic_vector(31 downto 0) := "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	
	constant PC_WIDTH : integer := 14;
	
	--branch prediction
	constant PREDICTION_TABLE_SIZE : integer := 6;

	

end constants;