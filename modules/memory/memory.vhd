library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity memory is
	port(
	clk : in std_logic;
	
	ALU_result : in std_logic_vector(31 downto 0);
	rs2_data_ex : in std_logic_vector(31 downto 0);
	rs2_data_wb : in std_logic_vector(31 downto 0);
	rs2_src : in std_logic;
	mem_write_width : in std_logic_vector(1 downto 0);
	mem_we : in std_logic;
	
	is_branch : in std_logic;
	funct3 : in std_logic_vector(2 downto 0);
	is_jump : in std_logic;
	new_PC : out std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_target : in std_logic_vector(PC_WIDTH - 1 downto 0);
	control_transfer : out std_logic;
	

	branched : in std_logic;
	PC_incr : in std_logic_vector(PC_WIDTH - 1 downto 0);
	
	--branch_prediction
	branch_out : out std_logic;
	
	--testbench input
	tb_mem_we : in std_logic;
	tb_mem_data : in std_logic_vector(31 downto 0);
	tb_mem_be : in std_logic_vector(1 downto 0);
	tb_mem_write_addr : in std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
	
	--data memory interface
	bram_mem_be : out std_logic_vector(1 downto 0);
	bram_addr : out std_logic_vector(DATA_MEM_WIDTH - 1 downto 0);
	bram_we : out std_logic;
	bram_data_in : out std_logic_vector(31 downto 0)
	);
end memory;
	
architecture behave of memory is
signal rs2_data : std_logic_vector(31 downto 0);
signal branch : std_logic;
signal incorrect_branch : std_logic;
signal correct_PC : std_logic_vector(PC_WIDTH - 1 downto 0);
--pragma synthesis_off
--performance counter
signal branches, is_branches, wrong_predictions, prediction_rate : integer := 0;
--pragma synthesis_on
begin 
--pragma synthesis_off	
performance : process(clk)
begin
	if(clk'event and clk = '1') then
		if(branch = '1' and is_branch = '1') then
			branches <= branches + 1;
		end if;
		if(is_branch = '1') then
			is_branches <= is_branches + 1;
		end if;
		if(incorrect_branch = '1') then
			wrong_predictions <= wrong_predictions + 1;
		end if;
		prediction_rate <= (10000 * wrong_predictions) / (is_branches + 1);
	end if;
end process;
--pragma synthesis_on
--branch predictor output
branch_out <= branch;

data_mem_input : process(tb_mem_we, tb_mem_data, tb_mem_be, tb_mem_write_addr, mem_write_width, ALU_result, mem_we, rs2_data)
begin
	if(tb_mem_we = '0') then
		 bram_mem_be <= mem_write_width;
		 bram_addr <= ALU_result(DATA_MEM_WIDTH - 1 downto 0);
   	   	 bram_we <= mem_we;
		 bram_data_in <= rs2_data; 
	else
		 bram_mem_be <= tb_mem_be;
		 bram_addr <= tb_mem_write_addr;
   	   	 bram_we <= tb_mem_we;
		 bram_data_in <= tb_mem_data;
	end if;
end process;
	
	
	
rs2_src_process : process(rs2_src, rs2_data_ex, rs2_data_wb) 
begin
	if(rs2_src = '1') then rs2_data <= rs2_data_wb;
	else 				   rs2_data <= rs2_data_ex;
	end if;
end process;


branch_control : entity work.branch_control port map(
	ALU_result => ALU_result,
	is_branch => is_branch,
	funct3 => funct3,
	branch => branch	
);

process(is_jump, ALU_result, branch_target, branch, is_jump, incorrect_branch, correct_PC, branched, is_branch, PC_incr)

begin
	if(branch /= branched) then incorrect_branch <= '1';
	else						incorrect_branch <= '0';
	end if;
	if(branch = '1') then correct_PC <= branch_target;
	else 				  correct_PC <= PC_incr;
	end if;
	case (is_jump) is
		when '1' => new_PC <= ALU_result(PC_WIDTH - 1 downto 0);
		when others => new_PC <= correct_PC;
	end case;
	control_transfer <= (is_branch and incorrect_branch) or is_jump;
end process;



end behave;