library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity instruction_fetch is
	port(
	clk : in std_logic;	
	nreset : in std_logic;
	
	imem_we	: in std_logic;
	imem_data : in std_logic_vector(31 downto 0);
	imem_write_address : in std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	
	--from other stages
	branch : in std_logic;
	branch_target_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	stall : in std_logic;
	
	--to IFID preg
	instruction_o : out std_logic_vector(31 downto 0);
	branch_target_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	current_PC : out std_logic_vector(PC_WIDTH - 1 downto 0);
	
	--Branch prediction
	PC_incr_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_taken : out std_logic
	--**--
	
	);
end instruction_fetch;

architecture behave of instruction_fetch is
signal PC_we : std_logic;
signal PC_in, PC_out : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_incr : std_logic_vector(PC_WIDTH - 1 downto 0);
signal instruction : std_logic_vector(31 downto 0);
signal SB_type_imm : std_logic_vector(11 downto 0);
signal imem_address : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
begin

branch_taken <= '0';
PC_incr_out <= PC_incr;
current_PC <= PC_out;
	
combi : process(PC_incr, branch_target_in, branch, PC_in, imem_we, PC_out, imem_write_address)

begin
	case(branch) is
		when '0'    => PC_in <= PC_incr;
		when '1'    => PC_in <= branch_target_in;
		when others => PC_in <= (others => 'X');
	end case;
	
	case (imem_we) is
		when '0' => imem_address <= PC_out(INSTRUCTION_MEM_WIDTH - 1 downto 0);
		when '1' => imem_address <= imem_write_address;
		when others => imem_address <= PC_out(INSTRUCTION_MEM_WIDTH - 1 downto 0); 
	end case;
end process;
	
	
PC_we <= not stall;
instruction_o <= instruction;
SB_type_imm <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);

PC : entity work.PC port map(
	clk => clk,
	we => PC_we,
	nreset => nreset,
	PC_in => PC_in,
	PC_out => PC_out
	);

PC_incrementer : entity work.PC_increment port map(
	input => PC_out,
	output => PC_incr
	);
	
branch_target_adder : entity work.branch_target_adder port map(
	PC_i => PC_out,
	PC_o => branch_target_out,
	imm => SB_type_imm
	);
	
instruction_memory : entity work.SP_32bit generic map(
address_width => INSTRUCTION_MEM_WIDTH) 
port map (
clk => clk,
address => imem_address,
data_in => imem_data,
data_out => instruction,
we => imem_we
);

	
	
end behave;