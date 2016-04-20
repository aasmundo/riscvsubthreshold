library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

entity top is
	port(
	clk                : in  std_logic;
	nreset             : in  std_logic;
	
	sleep              : in  std_logic;
	
	--test interface
	pass        	   : out std_logic;
	fail               : out std_logic;

	--data memory interface
	data_memory_address : out std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
	data_memory_read_data : in std_logic_vector(31 downto 0);
	data_memory_be        : out std_logic_vector(1 downto 0);
	data_memory_write_data : out std_logic_vector(31 downto 0);
	data_memory_write_enable : out std_logic;  
	data_memory_read_enable : out std_logic;
	
	--instruction memory interface
	inst_memory_address : out std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	inst_memory_read_data : in std_logic_vector(31 downto 0);
	inst_memory_write_enable : out std_logic
	);
end top;


architecture behave of top is
signal stall : std_logic;
signal init_sleep : std_logic;

--Instruction fetch
signal branch_target_IF : std_logic_vector(PC_WIDTH - 1 downto 0);
signal stall_IF : std_logic;
signal instruction_IF : std_logic_vector(31 downto 0);
signal PC_incr_IF : std_logic_vector(PC_WIDTH - 1 downto 0);
signal current_PC_IF : std_logic_vector(PC_WIDTH - 1 downto 0);
signal branched_IF : std_logic;

--IFID pipline register
signal instruction_IFID : std_logic_vector(31 downto 0);
signal flush_IFID : std_logic;
signal branch_target_IFID : std_logic_vector(PC_WIDTH - 1 downto 0);
signal current_PC_IFID : std_logic_vector(PC_WIDTH - 1 downto 0);
signal PC_incr_IFID  : std_logic_vector(PC_WIDTH - 1 downto 0);
signal branched_IFID : std_logic;

--Instruction decode
signal reg1_ID : std_logic_vector(31 downto 0);
signal reg2_ID : std_logic_vector(31 downto 0);
signal imm_ID : std_logic_vector(31 downto 0);
signal is_imm_ID : std_logic;
signal rs1_ID : std_logic_vector(4 downto 0);
signal rs2_ID : std_logic_vector(4 downto 0);
signal rd_ID : std_logic_vector(4 downto 0);
signal mem_we_ID : std_logic;
signal mem_re_ID : std_logic;
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
signal mem_re_IDEX : std_logic;
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
signal branched_IDEX : std_logic;

--Execute
signal ALU_result_EX : std_logic_vector(31 downto 0);
signal mem_rs2_src_EX : std_logic; 
signal rs2_EX :  std_logic_vector(31 downto 0);

--EXMEM pipeline register 	
signal rs2_adr_EXMEM : std_logic_vector(4 downto 0);
signal rd_EXMEM : std_logic_vector(4 downto 0);
signal ALU_result_EXMEM : std_logic_vector(31 downto 0);
signal flush_EXMEM : std_logic;
signal reg2_EXMEM : std_logic_vector(31 downto 0);
signal mem_we_EXMEM : std_logic;  
signal mem_re_EXMEM : std_logic;
signal mem_be_EXMEM : std_logic_vector(1 downto 0);
signal is_branch_EXMEM : std_logic;
signal wb_we_EXMEM : std_logic;
signal wb_src_EXMEM : std_logic_vector(1 downto 0);
signal mem_load_unsigned_EXMEM : std_logic;
signal funct3_EXMEM : std_logic_vector(2 downto 0);
signal branch_target_EXMEM : std_logic_vector(PC_WIDTH - 1 downto 0);
signal is_jump_EXMEM : std_logic;
signal PC_incr_EXMEM  : std_logic_vector(PC_WIDTH - 1 downto 0);
signal branched_EXMEM : std_logic;
--Memory
signal mem_read_MEM : std_logic_vector(31 downto 0);
signal control_transfer_MEM : std_logic;
signal new_PC_MEM : std_logic_vector(PC_WIDTH - 1 downto 0);
signal branch_MEM : std_logic;
--MEMWB pipeline register
signal ALU_result_MEMWB : std_logic_vector(31 downto 0);
signal flush_MEMWB : std_logic;
signal mem_read_MEMWB : std_logic_vector(31 downto 0);
signal wb_src_MEMWB : std_logic_vector(1 downto 0);
signal wb_we_MEMWB : std_logic;
signal rd_MEMWB : std_logic_vector(4 downto 0);
signal mem_load_unsigned_MEMWB : std_logic;
signal mem_load_width_MEMWB : std_logic_vector(1 downto 0);
signal PC_incr_MEMWB  : std_logic_vector(PC_WIDTH - 1 downto 0);
--Write back
signal wb_data_WB : std_logic_vector(31 downto 0); 
signal counter_enable : std_logic; 
signal clock_count : std_logic_vector(63 downto 0);	  



--pragma synthesis_off
--performance counters
signal clocks_since_reset : integer := 0;
signal stalls : integer := 0;
signal control_transfers : integer := 0;
signal stall_and_flush : integer := 0;
--pragma synthesis_on 

begin
	
	
	
--pragma synthesis_off
performance : process(clk, nreset)
begin 
	if(clk'event and clk = '1') then
		if(stall_IF = '1') then
			stalls <= stalls + 1;
		end if;
		if(control_transfer_MEM = '1') then
			control_transfers <= control_transfers + 1;
		end if;	   
		if(stall_IF = '1' and control_transfer_MEM = '1') then
			stall_and_flush <= stall_and_flush + 1;
		end if;
		clocks_since_reset <= clocks_since_reset + 1;
	elsif(nreset = '0') then
		clocks_since_reset <= 0;
		stalls <= 0;
		control_transfers <= 0;
		stall_and_flush <= 0;
	end if;
	
end process;
--pragma synthesis_on


inst_memory_write_enable <= '0';

instruction_fetch : entity work.instruction_fetch port map(
    clk                 => clk,
    nreset              => nreset,
    control_transfer    => control_transfer_MEM,
    new_PC              => new_PC_MEM,
    branch_target_out   => branch_target_IF,
    stall               => stall_IF,
    instruction_o       => instruction_IF,
    current_PC          => current_PC_IF,
    PC_incr_out         => PC_incr_IF,
    branched            => branched_IF,
    PC_incr_MEM         => PC_incr_EXMEM,
    branch_MEM          => branch_MEM,
	is_branch_MEM       => is_branch_EXMEM,
	instruction         => inst_memory_read_data,
	imem_address        => inst_memory_address,
	init_sleep          => init_sleep,
	sleep               => sleep
	);
	
IFID_pipline_register : entity work.IFID_preg port map(
    clk                 => clk,
    flush               => flush_IFID,
    stall               => stall,
    instruction_i       => instruction_IF,
    instruction_o       => instruction_IFID,
    branch_target_in    => branch_target_IF,
    branch_target_out   => branch_target_IFID,
    current_PC_in       => current_PC_IF,
    current_PC_out      => current_PC_IFID,
    PC_incr_in          => PC_incr_IF,
    PC_incr_out         => PC_incr_IFID,
    branched_in         => branched_IF,
	branched_out        => branched_IFID
	);
	
instruction_decode : entity work.instruction_decode port map(
    clk                 => clk,
    nreset              => nreset,
    instr               => instruction_IFID,
    wb_reg              => rd_MEMWB,
    wb_data             => wb_data_WB,
    wb_write            => wb_we_MEMWB,
    reg1                => reg1_ID,
    reg2                => reg2_ID,
    imm                 => imm_ID,
    is_imm              => is_imm_ID,
    rs1                 => rs1_ID,
    rs2                 => rs2_ID,
	rd                  => rd_ID,
    mem_we              => mem_we_ID,
	mem_re              => mem_re_ID,
    mem_be              => mem_be_ID,
    wb_src              => wb_src_ID,
    wb_we               => wb_we_ID,
    ALU_operation       => ALU_operation_ID,
    is_branch           => is_branch_ID,
    mem_load_unsigned   => mem_load_unsigned_ID,
    ex_rd               => rd_IDEX,
    ex_wb_src           => wb_src_IDEX,
    stall               => stall_ID,
    reg_or_PC           => reg_or_PC_ID,
	is_jump => is_jump_ID
	);
	
IDEX_pipeline_register : entity work.IDEX_preg port map(
    clk                 => clk,
    flush               => flush_IDEX,
    ALU_operation_in    => ALU_operation_ID,
    ALU_operation_out   => ALU_operation_IDEX,
    reg1_in             => reg1_ID,
    reg2_in             => reg2_ID,
    reg2_out            => reg2_IDEX,
    reg1_out            => reg1_IDEX,
    rs1_in              => rs1_ID,
    rs2_in              => rs2_ID,
    rs1_out             => rs1_IDEX,
    rs2_out             => rs2_IDEX,
    rd_in               => rd_ID,
    rd_out              => rd_IDEX,
    imm_in              => imm_ID,
    imm_out             => imm_IDEX,
    is_imm_in           => is_imm_ID,
    is_imm_out          => is_imm_IDEX,
    mem_we_in           => mem_we_ID,
	mem_re_in           => mem_re_ID,
    mem_be_in           => mem_be_ID,
    wb_src_in           => wb_src_ID,
    wb_we_in            => wb_we_ID,
    mem_we_out          => mem_we_IDEX,
	mem_re_out          => mem_re_IDEX,
    mem_be_out          => mem_be_IDEX,
    wb_src_out          => wb_src_IDEX,
    wb_we_out           => wb_we_IDEX,
    is_branch_in        => is_branch_ID,
    is_branch_out       => is_branch_IDEX,
	mem_load_unsigned_in => mem_load_unsigned_ID,
	mem_load_unsigned_out => mem_load_unsigned_IDEX,
    branch_target_in    => branch_target_IFID,
    branch_target_out   => branch_target_IDEX,
    current_PC_in       => current_PC_IFID,
    current_PC_out      => current_PC_IDEX,
    reg_or_PC_in        => reg_or_PC_ID,
    reg_or_PC_out       => reg_or_PC_IDEX,
    is_jump_in          => is_jump_ID,
    is_jump_out         => is_jump_IDEX,
    PC_incr_in          => PC_incr_IFID,
    PC_incr_out         => PC_incr_IDEX,
    branched_in         => branched_IFID,
	branched_out        => branched_IDEX
	);

Execute : entity work.execute port map(
    ALU_operation       => ALU_operation_IDEX,
    reg1                => reg1_IDEX,
    reg2                => reg2_IDEX,
    imm                 => imm_IDEX,
    is_imm              => is_imm_IDEX,
    rs1                 => rs1_IDEX,
    rs2                 => rs2_IDEX,
    rs2_out             => rs2_EX,
	rd => rd_IDEX,
    rd_dest_mem         => rd_EXMEM,
    rd_data_mem         => ALU_result_EXMEM,
    rd_we_mem           => wb_we_EXMEM,
    rd_dest_wb          => rd_MEMWB,
    rd_data_wb          => wb_data_WB,
    rd_we_wb            => wb_we_MEMWB,
    ALU_result          => ALU_result_EX,
    current_PC          => current_PC_IDEX,
    reg_or_PC           => reg_or_PC_IDEX,
    rs2_adr_mem         => rs2_adr_EXMEM,
	mem_rs2_src         => mem_rs2_src_EX
	);

EXMEM_pipeline_register : entity work.EXMEM_preg port map(
    clk                 => clk,
    flush               => flush_EXMEM,
    ALU_result_in       => ALU_result_EX,
    ALU_result_out      => ALU_result_EXMEM,
    rs2_data_in         => rs2_EX,
    rs2_data_out        => reg2_EXMEM,
    mem_we_in           => mem_we_IDEX,
    mem_we_out          => mem_we_EXMEM,
	mem_re_in           => mem_re_IDEX,
	mem_re_out          => mem_re_EXMEM,
    mem_write_width_in  => mem_be_IDEX,
    mem_write_width_out => mem_be_EXMEM,
    is_branch_in        => is_branch_IDEX,
    is_branch_out       => is_branch_EXMEM,
    rd_in               => rd_IDEX,
    rd_out              => rd_EXMEM,
    rd_we_in            => wb_we_IDEX,
    rd_we_out           => wb_we_EXMEM,
    wb_src_in           => wb_src_IDEX,
    wb_src_out          => wb_src_EXMEM,
	mem_load_unsigned_in => mem_load_unsigned_IDEX,
	mem_load_unsigned_out => mem_load_unsigned_EXMEM,
    branch_target_in    => branch_target_IDEX,
    branch_target_out   => branch_target_EXMEM,
    is_jump_in          => is_jump_IDEX,
    is_jump_out         => is_jump_EXMEM,
    PC_incr_in          => PC_incr_IDEX,
    PC_incr_out         => PC_incr_EXMEM,
    rs2_adr_in          => rs2_IDEX,
    rs2_adr_out         => rs2_adr_EXMEM,
    branched_in         => branched_IDEX,
	branched_out        => branched_EXMEM
	);
funct3_EXMEM <= mem_load_unsigned_EXMEM & mem_be_EXMEM;	
memory : entity work.memory port map(
    clk                 => clk,
    ALU_result          => ALU_result_EXMEM,
    rs2_data_ex         => reg2_EXMEM,
    rs2_data_WB         => wb_data_WB,
    rs2_src             => mem_rs2_src_EX,
    mem_write_width     => mem_be_EXMEM,
    mem_we              => mem_we_EXMEM,
	mem_re              => mem_re_EXMEM,
    funct3              => funct3_EXMEM,
    control_transfer    => control_transfer_MEM,
    branch_target       => branch_target_EXMEM,
    new_PC              => new_PC_MEM,
    is_branch           => is_branch_EXMEM,
    is_jump             => is_jump_EXMEM,
    PC_incr             => PC_incr_EXMEM,
    branched            => branched_EXMEM,
	branch_out          => branch_MEM,
	bram_mem_be         => data_memory_be,
	bram_addr           => data_memory_address,
	bram_we             => data_memory_write_enable,
	bram_re             => data_memory_read_enable,
	bram_data_in        => data_memory_write_data
	);

MEMWB_pipeline_registers : entity work.MEMWB_preg port map(
    clk                 => clk,
    flush               => flush_MEMWB,
    mem_read_data_in    => data_memory_read_data,
    mem_read_data_out   => mem_read_MEMWB,
    ALU_data_in         => ALU_result_EXMEM,
    ALU_data_out        => ALU_result_MEMWB,
    wb_src_in           => wb_src_EXMEM,
    wb_src_out          => wb_src_MEMWB,
    wb_we_in            => wb_we_EXMEM,
    wb_we_out           => wb_we_MEMWB,
    rd_in               => rd_EXMEM,
    rd_out              => rd_MEMWB,
    mem_load_width_in   => mem_be_EXMEM,
    mem_load_width_out  => mem_load_width_MEMWB,
	mem_load_unsigned_in => mem_load_unsigned_EXMEM,
	mem_load_unsigned_out => mem_load_unsigned_MEMWB,
    PC_incr_in          => PC_incr_EXMEM,
	PC_incr_out         => PC_incr_MEMWB
	);               
	
write_back : entity work.write_back port map(
    wb_src              => wb_src_MEMWB,
    mem_data            => mem_read_MEMWB,
    ALU_data            => ALU_result_MEMWB,
    wb_data             => wb_data_WB,
    mem_load_width      => mem_load_width_MEMWB,
    mem_load_unsigned   => mem_load_unsigned_MEMWB,
	PC_incr             => PC_incr_MEMWB,
	clock_count         => clock_count
	);
	
counter : entity work.clock_counter port map(
	clk => clk,
	cnt_en => counter_enable,
	nreset => nreset,
	cnt    => clock_count
	);

activity_control : entity work.activity_control port map(
	clk => clk,	
	sleep => sleep,
	stall_ID => stall_ID,  
	nreset => nreset,
	control_transfer_MEM => control_transfer_MEM,
	init_sleep => init_sleep,
	counter_enable => counter_enable,		   
	stall_IF => stall_IF,
	stall => stall,
	flush_IFID => flush_IFID,
	flush_IDEX => flush_IDEX,
	flush_EXMEM => flush_EXMEM,
	flush_MEMWB => flush_MEMWB	
	);
	
	
test_process : process(instruction_IFID) is
begin
	pass <= '0';
	fail <= '0';
	if(instruction_IFID = x"9a559a55") then	 
		pass <= '1';
	end if;
	if(instruction_IFID = x"fa11fa11") then	 
		fail <= '1';
	end if;		
end process;
	
end behave;