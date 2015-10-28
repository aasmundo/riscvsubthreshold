library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity top is
	port(
	clk    : in std_logic;
	nreset : in std_logic;
	imem_we : in std_logic;
	imem_data : in std_logic_vector(31 downto 0);
	imem_write_address : in std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	instruction : out std_logic_vector(31 downto 0)
	);
end top;


architecture behave of top is
signal stall : std_logic;


--Instruction fetch
signal branch_IF : std_logic;
signal branch_target_IF : std_logic_vector(PC_WIDTH - 1 downto 0);
signal stall_IF : std_logic;
signal instruction_IF : std_logic_vector(31 downto 0);
signal PC_incr_IF : std_logic_vector(PC_WIDTH - 1 downto 0);
signal current_PC_IF : std_logic_vector(PC_WIDTH - 1 downto 0);

--IFID pipline register
signal instruction_IFID : std_logic_vector(31 downto 0);
signal flush_IFID : std_logic;
signal branch_target_IFID : std_logic_vector(PC_WIDTH - 1 downto 0);
signal current_PC_IFID : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_incr_IFID  : std_logic_vector(PC_WIDTH - 1 downto 0);

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
signal wb_src_ID : std_logic_vector(1 downto 0);
signal wb_we_ID  : std_logic;
signal is_branch_ID : std_logic;
signal mem_load_unsigned_ID : std_logic;
signal ALU_operation_ID : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
signal reg_or_PC_ID : std_logic;
signal is_jump_ID : std_logic; 
signal stall_ID : std_logic;


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
signal wb_src_IDEX : std_logic_vector(1 downto 0);
signal wb_we_IDEX  : std_logic;
signal is_branch_IDEX : std_logic;
signal branch_target_IDEX : std_logic_vector(PC_WIDTH - 1 downto 0);
signal current_PC_IDEX : std_logic_vector(PC_WIDTH - 1 downto 0);
signal reg_or_PC_IDEX : std_logic;
signal is_jump_IDEX : std_logic;
signal PC_incr_IDEX  : std_logic_vector(PC_WIDTH - 1 downto 0);

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
signal wb_src_EXMEM : std_logic_vector(1 downto 0);
signal mem_load_unsigned_EXMEM : std_logic;
signal funct3_EXMEM : std_logic_vector(2 downto 0);
signal branch_target_EXMEM : std_logic_vector(PC_WIDTH - 1 downto 0);
signal current_PC_EXMEM : std_logic_vector(PC_WIDTH - 1 downto 0); 
signal is_jump_EXMEM : std_logic;
signal PC_incr_EXMEM  : std_logic_vector(PC_WIDTH - 1 downto 0);
--Memory
signal mem_read_MEM : std_logic_vector(31 downto 0);
signal control_transfer_MEM : std_logic;
signal new_PC_MEM : std_logic_vector(PC_WIDTH - 1 downto 0);
--MEMWB pipeline register
signal ALU_result_MEMWB : std_logic_vector(31 downto 0);
signal flush_MEMWB : std_logic;
signal mem_read_MEMWB : std_logic_vector(31 downto 0);
signal wb_src_MEMWB : std_logic_vector(1 downto 0);
signal wb_we_MEMWB : std_logic;
signal rd_MEMWB : std_logic_vector(4 downto 0);
signal mem_load_unsigned_MEMWB : std_logic;
signal mem_load_width_MEMWB : std_logic_vector(1 downto 0);
signal current_PC_MEMWB : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_incr_MEMWB  : std_logic_vector(PC_WIDTH - 1 downto 0);
--Write back
signal rd_WB : std_logic_vector(4 downto 0);
signal wb_data_WB : std_logic_vector(31 downto 0);
signal reg_we_WB : std_logic;
signal ALU_result_WB : std_logic_vector(31 downto 0);
begin

instruction <= instruction_IFID;	
	
mem_rs2_src_EX <= '0';

stall <= stall_ID and nreset;
stall_IF <= stall;
flush_IFID <= control_transfer_MEM or not nreset;
flush_IDEX <= control_transfer_MEM or stall or not nreset;
flush_EXMEM <= control_transfer_MEM or not nreset;
flush_MEMWB <= not nreset;

instruction_fetch : entity work.instruction_fetch port map(
	clk => clk,
	nreset => nreset,
	control_transfer => control_transfer_MEM,
	new_PC => new_PC_MEM,
	branch_target_out => branch_target_IF,
	stall => stall_IF,
	instruction_o => instruction_IF,
	imem_data => imem_data,
	imem_we => imem_we,
	imem_write_address => imem_write_address,
	current_PC => current_PC_IF,
	PC_incr_out => PC_incr_IF
	);
	
IFID_pipline_register : entity work.IFID_preg port map(
	clk => clk,
	flush => flush_IFID,
	stall => stall,
	instruction_i => instruction_IF,
	instruction_o => instruction_IFID,
	branch_target_in => branch_target_IF,
	branch_target_out => branch_target_IFID,
	current_PC_in => current_PC_IF,
	current_PC_out => current_PC_IFID,
	PC_incr_in => PC_incr_IF,
	PC_incr_out => PC_incr_IFID
	);
	
instruction_decode : entity work.instruction_decode port map(
	clk => clk,
	nreset => nreset,
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
	mem_load_unsigned => mem_load_unsigned_ID,
	ex_rd => rd_IDEX,
	ex_wb_src => wb_src_IDEX,
	stall => stall_ID,
	reg_or_PC => reg_or_PC_ID,
	is_jump => is_jump_ID
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
	mem_load_unsigned_out => mem_load_unsigned_IDEX,
	branch_target_in => branch_target_IFID,
	branch_target_out => branch_target_IDEX,
	current_PC_in => current_PC_IFID,
	current_PC_out => current_PC_IDEX,
	reg_or_PC_in => reg_or_PC_ID,
	reg_or_PC_out => reg_or_PC_IDEX,
	is_jump_in => is_jump_ID,
	is_jump_out => is_jump_IDEX,
	PC_incr_in => PC_incr_IFID,
	PC_incr_out => PC_incr_IDEX
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
	rd_we_mem => wb_we_EXMEM,
	rd_dest_wb => rd_MEMWB,
	rd_data_wb => wb_data_WB,
	rd_we_wb => wb_we_MEMWB,
	ALU_result => ALU_result_EX,
	current_PC => current_PC_IDEX,
	reg_or_PC => reg_or_PC_IDEX
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
	mem_load_unsigned_out => mem_load_unsigned_EXMEM,
	branch_target_in => branch_target_IDEX,
	branch_target_out => branch_target_EXMEM,
	is_jump_in => is_jump_IDEX,
	is_jump_out => is_jump_EXMEM,
	PC_incr_in => PC_incr_IDEX,
	PC_incr_out => PC_incr_EXMEM
	);
funct3_EXMEM <= mem_load_unsigned_EXMEM & mem_be_EXMEM;	
memory : entity work.memory port map(
	clk => clk,
	ALU_result => ALU_result_EXMEM,
	rs2_data_ex => reg2_EXMEM,
	rs2_data_WB => ALU_result_MEMWB,
	rs2_src => mem_rs2_src_EX,
	mem_write_width => mem_be_EXMEM,
	mem_we => mem_we_EXMEM,
	mem_read_out => mem_read_MEM,
	funct3 => funct3_EXMEM,
	control_transfer => control_transfer_MEM,
	branch_target => branch_target_EXMEM,
	new_PC => new_PC_MEM,
	is_branch => is_branch_EXMEM,
	is_jump => is_jump_EXMEM
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
	mem_load_unsigned_out => mem_load_unsigned_MEMWB,
	PC_incr_in => PC_incr_EXMEM,
	PC_incr_out => PC_incr_MEMWB
	); 
	
write_back : entity work.write_back port map(
	wb_src => wb_src_MEMWB,
	mem_data => mem_read_MEMWB,
	ALU_data => ALU_result_MEMWB,
	wb_data => wb_data_WB,
	mem_load_width => mem_load_width_MEMWB,
	mem_load_unsigned => mem_load_unsigned_MEMWB,
	PC_incr => PC_incr_MEMWB
	);
	

	
end behave;