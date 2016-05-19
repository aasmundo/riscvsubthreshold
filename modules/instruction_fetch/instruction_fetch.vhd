library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity instruction_fetch is
	port(
	clk : in std_logic;	   
	pwr_en : in std_logic;
	nreset : in std_logic;
	
	
	init_sleep : in std_logic;
	sleep      : in std_logic;
	
	--from other stages
	control_transfer : in std_logic;
	new_PC : in std_logic_vector(PC_WIDTH - 1 downto 0);
	stall : in std_logic;
	
	--to IFID preg
	instruction_o : out std_logic_vector(31 downto 0);
	branch_target_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	current_PC : out std_logic_vector(PC_WIDTH - 1 downto 0);
	branched : out std_logic;
	
	--Branch prediction
	PC_incr_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_MEM : in std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_MEM : in std_logic;
	is_branch_MEM : in std_logic;
	--**-- 
	
	--instruction memory interface
	imem_address : out std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	instruction  : in std_logic_vector(31 downto 0)
	
	);
end instruction_fetch;

architecture behave of instruction_fetch is
signal PC_we : std_logic;
signal PC_in, PC_out, PC_next : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_incr : std_logic_vector(PC_WIDTH - 1 downto 0);
signal SB_type_imm : std_logic_vector(11 downto 0);
signal UJ_type_imm : std_logic_vector(19 downto 0);
signal relevant_imm : std_logic_vector(19 downto 0);
signal control_target : std_logic_vector(PC_WIDTH - 1 downto 0);
signal is_branch : std_logic;
signal branch_prediction : std_logic;
signal JAL_opcode : std_logic;
signal branch_opcode : std_logic;
begin


PC_incr_out <= PC_incr;
current_PC <= PC_out;
SB_type_imm <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);
UJ_type_imm <= instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21); 
branch_target_out <= control_target;
imem_address <= PC_next(INSTRUCTION_MEM_WIDTH - 1 downto 0);

combi : process(PC_incr, new_PC, control_transfer, UJ_type_imm, PC_in, PC_out, SB_type_imm, UJ_type_imm, instruction, control_target, branch_prediction, is_branch, JAL_opcode)

begin
	if (instruction(6 downto 0) = "1101111") then JAL_opcode <= '1';
	else JAL_opcode <= '0';
	end if;
	
	if (instruction(6 downto 0) = "1100011") then branch_opcode <= '1';
	else branch_opcode <= '0';
	end if;

	
	case (JAL_opcode) is
		when '1' => relevant_imm <= UJ_type_imm;
		when others => relevant_imm <= std_logic_vector(resize(signed(SB_type_imm), relevant_imm'length));
	end case;
end process;


PC_input : process(control_transfer, instruction(6 downto 0), branch_prediction, PC_incr, control_target, new_PC, JAL_opcode, branch_opcode, PC_incr_MEM, init_sleep)

begin
	branched <= '0';
	PC_in <= PC_incr;
	if(control_transfer = '1') then
		PC_in <= new_PC;
	elsif(init_sleep = '1') then
		PC_in <= PC_incr_MEM;
	elsif(JAL_opcode = '1') then
		PC_in <= control_target;
	elsif(branch_opcode = '1' and branch_prediction = '1') then
		PC_in <= control_target;  
		branched <= '1';
	end if;
	
end process;


	
PC_we <= (not (stall or sleep)) or init_sleep;

instruction_o <= instruction;

PC : entity work.PC port map(
	clk => clk,
	pwr_en => pwr_en,
	we => PC_we,
	nreset => nreset,
	PC_in => PC_in,
	PC_next => PC_next,
	PC_out => PC_out
	);

PC_incrementer : entity work.PC_increment port map(
	input => PC_out,
	output => PC_incr
	);
	
boj_target_adder : entity work.branch_target_adder port map(
	PC_i => PC_out,
	PC_o => control_target,
	imm => relevant_imm
	);
	

	branch_predictor_pg : entity work.branch_predictor_pg generic map(
	prediction_window => PREDICTION_TABLE_SIZE)
	port map(
	pwr_en => pwr_en,
	clk => clk,
	nreset => nreset,
	PC_incr_IF => PC_incr(PREDICTION_TABLE_SIZE + 1 downto 2),
	PC_incr_MEM => PC_incr_MEM(PREDICTION_TABLE_SIZE + 1 downto 2),
	prediction => branch_prediction,
	branch_MEM => branch_MEM,
	is_branch_MEM => is_branch_MEM
	);
	


	
	
end behave;