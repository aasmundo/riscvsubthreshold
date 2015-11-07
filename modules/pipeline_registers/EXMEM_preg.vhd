library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity EXMEM_preg is
	port(
	clk, flush : in std_logic;
	
	ALU_result_in : in std_logic_vector(31 downto 0);
	ALU_result_out : out std_logic_vector(31 downto 0);
	rs2_data_in : in std_logic_vector(31 downto 0);
	rs2_data_out : out std_logic_vector(31 downto 0);
	rs2_adr_in : in std_logic_vector(4 downto 0);
	rs2_adr_out : out std_logic_vector(4 downto 0);
	
	branch_target_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
	branch_target_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
	
	PC_incr_in :  in std_logic_vector(PC_WIDTH - 1 downto 0);
	PC_incr_out :  out std_logic_vector(PC_WIDTH - 1 downto 0);
	
	
	
	
	-- MEM control --
	mem_we_in : in std_logic;
	mem_we_out : out std_logic;
	mem_write_width_in : in std_logic_vector(1 downto 0);
	mem_write_width_out : out std_logic_vector(1 downto 0);
	is_branch_in : in std_logic;
	is_branch_out : out std_logic;
	is_jump_in : in std_logic;
	is_jump_out : out std_logic;
	
	
	-- WB control --
	rd_in : in std_logic_vector(4 downto 0);
	rd_we_in : in std_logic;
	rd_out : out std_logic_vector(4 downto 0);
	rd_we_out : out std_logic;
	wb_src_in : in std_logic_vector(1 downto 0);
	wb_src_out : out std_logic_vector(1 downto 0);
	mem_load_unsigned_in : in std_logic;  
	mem_load_unsigned_out : out std_logic;
	branched_in : in std_logic;
	branched_out : out std_logic
	);
end EXMEM_preg;	  


architecture behave of EXMEM_preg is

begin
	
	
seq : process(clk, flush)
begin
	if(clk'event and clk = '1') then
		if(flush = '1') then
			rd_we_out <= '0';
			mem_we_out <= '0';
			is_branch_out <= '0';
			is_jump_out <= '0';
			rd_out <= "00000";
			rs2_adr_out <= "00000";
			branched_out <= '0';
		else
			branched_out <= branched_in;
			rd_we_out <= rd_we_in;
			mem_we_out <= mem_we_in;
			is_branch_out <= is_branch_in;
			is_jump_out <= is_jump_in;
			rd_out <= rd_in;
			rs2_adr_out <= rs2_adr_in;
		end if;					  
		ALU_result_out <= ALU_result_in;
		rs2_data_out <= rs2_data_in;  
		wb_src_out <= wb_src_in;
		mem_write_width_out <= mem_write_width_in;
		mem_load_unsigned_out <= mem_load_unsigned_in;
		branch_target_out <= branch_target_in;
		PC_incr_out <= PC_incr_in;
	end if;
end process;
end behave;