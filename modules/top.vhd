library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity top is
	port(
	clk    : in std_logic;
	nreset : in std_logic
	);
end top;


architecture behave of top is

--Instruction fetch
signal branch_or_jump : std_logic;
signal boj_target : std_logic_vector(31 downto 0);
signal stall_IF : std_logic;
signal instruction_IF : std_logic_vector(31 downto 0);

--IFID pipline register
signal instruction_IFID : std_logic_vector(31 downto 0);
signal flush_IFID : std_logic;


--Instruction decode
signal reg1_ID : std_logic_vector(31 downto 0);
signal reg2_ID : std_logic_vector(31 downto 0);
signal imm_ID : std_logic_vector(31 downto 0);
signal is_imm_ID : std_logic;
signal rs1_ID : std_logic_vector(4 downto 0);
signal rs2_ID : std_logic_vector(4 downto 0);
signal rd_ID : std_logic_vector(4 downto 0);
signal mem_we_ID : std_logic;
signal mem_be_ID : std_logic_vector(1 downto 0);
signal wb_src_ID : std_logic;
signal wb_we_ID  : std_logic;
signal is_branch_ID : std_logic;
signal mem_load_unsigned_ID : std_logic;
signal ALU_operation_ID : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0); 

--IDEX pipeline register
signal flush_IDEX : std_logic;
signal ALU_operation_IDEX : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
signal reg1_IDEX : std_logic_vector(31 downto 0);
signal reg2_IDEX : std_logic_vector(31 downto 0);
signal imm_IDEX : std_logic_vector(31 downto 0); 
signal rd_IDEX : std_logic_vector(4 downto 0);
signal rs1_IDEX : std_logic_vector(4 downto 0);
signal rs2_IDEX : std_logic_vector(4 downto 0);
signal is_imm_IDEX : std_logic;
signal mem_we_IDEX : std_logic;
signal mem_be_IDEX : std_logic_vector(1 downto 0);
signal mem_load_unsigned_IDEX : std_logic;
signal wb_src_IDEX : std_logic;
signal wb_we_IDEX  : std_logic;
signal is_branch_IDEX : std_logic;

--Execute
signal ALU_result_EX : std_logic_vector(31 downto 0);
signal mem_rs2_src_EX : std_logic;

--EXMEM pipeline register
signal rd_EXMEM : std_logic_vector(4 downto 0);
signal ALU_result_EXMEM : std_logic_vector(31 downto 0);
signal reg_we_EXMEM : std_logic;
signal flush_EXMEM : std_logic;
signal reg2_EXMEM : std_logic_vector(31 downto 0);
signal mem_we_EXMEM : std_logic;
signal mem_be_EXMEM : std_logic_vector(1 downto 0);
signal is_branch_EXMEM : std_logic;
signal wb_we_EXMEM : std_logic;
signal wb_src_EXMEM : std_logic;
signal mem_load_unsigned_EXMEM : std_logic;
--Memory
signal mem_read_MEM : std_logic_vector(31 downto 0);

--MEMWB pipeline register
signal ALU_result_MEMWB : std_logic_vector(31 downto 0);
signal flush_MEMWB : std_logic;
signal mem_read_MEMWB : std_logic_vector(31 downto 0);
signal wb_src_MEMWB : std_logic;
signal wb_we_MEMWB : std_logic;
signal rd_MEMWB : std_logic_vector(4 downto 0);
signal mem_load_unsigned_MEMWB : std_logic;
signal mem_load_width_MEMWB : std_logic_vector(1 downto 0);
--Write back
signal rd_WB : std_logic_vector(4 downto 0);
signal wb_data_WB : std_logic_vector(31 downto 0);
signal reg_we_WB : std_logic;
signal ALU_result_WB : std_logic_vector(31 downto 0);
begin

flush_IFID <= '0';
flush_IDEX <= '0';
flush_EXMEM <= '0';
flush_MEMWB <= '0';	
mem_rs2_src_EX <= '0';
	
instruction_fetch : entity work.instruction_fetch port map(
	clk => clk,
	nreset => nreset,
	branch_or_jump => branch_or_jump,
	boj_target => boj_target,
	stall => stall_IF,
	instruction_o => instruction_IF
	);
	
IFID_pipline_register : entity work.IFID_preg port map(
	clk => clk,
	flush => flush_IFID,
	instruction_i => instruction_IF,
	instruction_o => instruction_IFID	
	);
	
instruction_decode : entity work.instruction_decode port map(
	clk => clk,
	instr => instruction_IFID,
	wb_reg => rd_MEMWB,
	wb_data => wb_data_WB,
	wb_write => wb_we_MEMWB,
	reg1 => reg1_ID,
	reg2 => reg2_ID,
	imm => imm_ID,
	is_imm => is_imm_ID,
	rs1 => rs1_ID,
	rs2 => rs2_ID,
	rd => rd_ID,
	mem_we => mem_we_ID,
	mem_be => mem_be_ID,
	wb_src => wb_src_ID,
	wb_we => wb_we_ID,
	ALU_operation => ALU_operation_ID,
	is_branch => is_branch_ID,
	mem_load_unsigned => mem_load_unsigned_ID
	);
	
IDEX_pipeline_register : entity work.IDEX_preg port map(
	clk => clk,
	flush => flush_IDEX,
	ALU_operation_in => ALU_operation_ID,
	ALU_operation_out => ALU_operation_IDEX,
	reg1_in => reg1_ID,
	reg2_in => reg2_ID,
	reg2_out => reg2_IDEX,
	reg1_out => reg1_IDEX,
	rs1_in => rs1_ID,
	rs2_in => rs2_ID,	
	rs1_out => rs1_IDEX,
	rs2_out => rs2_IDEX,
	rd_in => rd_ID,
	rd_out => rd_IDEX,
	imm_in => imm_ID,
	imm_out => imm_IDEX,
	is_imm_in => is_imm_ID,
	is_imm_out => is_imm_IDEX,
	mem_we_in => mem_we_ID,
	mem_be_in => mem_be_ID,
	wb_src_in => wb_src_ID,
	wb_we_in => wb_we_ID,
	mem_we_out => mem_we_IDEX,
	mem_be_out => mem_be_IDEX,
	wb_src_out => wb_src_IDEX,
	wb_we_out => wb_we_IDEX,
	is_branch_in => is_branch_ID,
	is_branch_out => is_branch_IDEX,
	mem_load_unsigned_in => mem_load_unsigned_ID,
	mem_load_unsigned_out => mem_load_unsigned_IDEX
	);

Execute : entity work.execute port map(
	ALU_operation => ALU_operation_IDEX,
	reg1 => reg1_IDEX,
	reg2 => reg2_IDEX,
	imm => imm_IDEX,
	is_imm => is_imm_IDEX,
	rs1 => rs1_IDEX,
	rs2 => rs2_IDEX,
	rd => rd_IDEX,
	rd_dest_mem => rd_EXMEM,
	rd_data_mem => ALU_result_EXMEM,
	rd_we_mem => reg_we_EXMEM,
	rd_dest_wb => rd_WB,
	rd_data_wb => ALU_result_WB,
	rd_we_wb => reg_we_WB,
	ALU_result => ALU_result_EX
	);

EXMEM_pipeline_register : entity work.EXMEM_preg port map(
	clk => clk,
	flush => flush_EXMEM,
	ALU_result_in => ALU_result_EX,
	ALU_result_out => ALU_result_EXMEM,
	rs2_data_in => reg2_IDEX,
	rs2_data_out => reg2_EXMEM,
	mem_we_in => mem_we_IDEX,
	mem_we_out => mem_we_EXMEM,
	mem_write_width_in => mem_be_IDEX,	   
	mem_write_width_out => mem_be_EXMEM,
	is_branch_in => is_branch_IDEX,
	is_branch_out => is_branch_EXMEM,
	rd_in => rd_IDEX,
	rd_out => rd_EXMEM,
	rd_we_in => wb_we_IDEX,
	rd_we_out => wb_we_EXMEM,
	wb_src_in => wb_src_IDEX,
	wb_src_out => wb_src_EXMEM,
	mem_load_unsigned_in => mem_load_unsigned_IDEX,
	mem_load_unsigned_out => mem_load_unsigned_EXMEM
	);
	
memory : entity work.memory port map(
	clk => clk,
	ALU_result => ALU_result_EXMEM,
	rs2_data_ex => reg2_EXMEM,
	rs2_data_WB => ALU_result_MEMWB,
	rs2_src => mem_rs2_src_EX,
	mem_write_width => mem_be_EXMEM,
	mem_we => mem_we_EXMEM,
	mem_read_out => mem_read_MEM
	);

MEMWB_pipeline_registers : entity work.MEMWB_preg port map(
	clk => clk,
	flush => flush_MEMWB,
	mem_read_data_in => mem_read_MEM,
	mem_read_data_out => mem_read_MEMWB,
	ALU_data_in => ALU_result_EXMEM,
	ALU_data_out => ALU_result_MEMWB,
	wb_src_in => wb_src_EXMEM,
	wb_src_out => wb_src_MEMWB,
	wb_we_in => wb_we_EXMEM,
	wb_we_out => wb_we_MEMWB,
	rd_in => rd_EXMEM,
	rd_out => rd_MEMWB,
	mem_load_width_in => mem_be_EXMEM,
	mem_load_width_out => mem_load_width_MEMWB,
	mem_load_unsigned_in => mem_load_unsigned_EXMEM,
	mem_load_unsigned_out => mem_load_unsigned_MEMWB
	); 
	
write_back : entity work.write_back port map(
	wb_src => wb_src_MEMWB,
	mem_data => mem_read_MEMWB,
	ALU_data => ALU_result_MEMWB,
	wb_data => wb_data_WB,
	mem_load_width => mem_load_width_MEMWB,
	mem_load_unsigned => mem_load_unsigned_MEMWB
	);
	

	
end behave;