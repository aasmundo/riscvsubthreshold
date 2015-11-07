library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity IDEX_preg is
	port(
		clk : in std_logic;
		flush : in std_logic;

		
		ALU_operation_in : in std_logic_Vector(ALU_OPCODE_WIDTH - 1 downto 0);	  
		ALU_operation_out : out std_logic_Vector(ALU_OPCODE_WIDTH - 1 downto 0);
		reg1_out : out std_logic_vector(31 downto 0);
		reg2_out : out std_logic_vector(31 downto 0);
		imm_out : out std_logic_vector(31 downto 0);
		is_imm_out : out std_logic;
		rs1_out : out std_logic_vector(4 downto 0);
		rs2_out : out std_logic_vector(4 downto 0);
		rd_out : out std_logic_vector(4 downto 0);
		
		reg1_in : in std_logic_vector(31 downto 0);
		reg2_in : in std_logic_vector(31 downto 0);
		imm_in : in std_logic_vector(31 downto 0);
		is_imm_in : in std_logic;
		rs1_in : in std_logic_vector(4 downto 0);
		rs2_in : in std_logic_vector(4 downto 0);
		rd_in : in std_logic_vector(4 downto 0);
		
		mem_we_in : in std_logic;
		mem_be_in : in std_logic_vector(1 downto 0); 
		mem_load_unsigned_in : in std_logic;  
		mem_load_unsigned_out : out std_logic;
		wb_src_in : in std_logic_vector(1 downto 0);
		wb_we_in  : in std_logic;
		mem_we_out : out std_logic;
		mem_be_out : out std_logic_vector(1 downto 0);
		wb_src_out : out std_logic_vector(1 downto 0);
		wb_we_out  : out std_logic;
		is_branch_in : in std_logic;
		is_branch_out : out std_logic;
		branch_target_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
		branch_target_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
		current_PC_in : in std_logic_vector(PC_WIDTH - 1 downto 0);
		current_PC_out : out std_logic_vector(PC_WIDTH - 1 downto 0);
		reg_or_PC_in : in std_logic;
		reg_or_PC_out : out std_logic;
		is_jump_in : in std_logic;
		is_jump_out : out std_logic;
		PC_incr_in :  in std_logic_vector(PC_WIDTH - 1 downto 0);
		PC_incr_out :  out std_logic_vector(PC_WIDTH - 1 downto 0);
		branched_in : in std_logic;
		branched_out : out std_logic
	);
end IDEX_preg;

architecture behave of IDEX_preg is

begin
	
seq : process(clk, flush)
begin
	if(clk'event and clk = '1') then
		if(flush = '1') then
			rd_out     <= "00000";
			mem_we_out <= '0';
			wb_we_out  <= '0';
			is_branch_out  <= '0';
			is_jump_out <= '0';
			branched_out <= '0';
		else
			branched_out <= branched_in;
			rd_out <= rd_in;
			mem_we_out <= mem_we_in;
			wb_we_out  <= wb_we_in;
			is_branch_out <= is_branch_in;
			is_jump_out <= is_jump_in;
		end if;
		ALU_operation_out <= ALU_operation_in;
		mem_be_out <= mem_be_in;
		reg1_out <= reg1_in;
		reg2_out <= reg2_in;
		imm_out <= imm_in;
		is_imm_out <= is_imm_in;
		rs1_out <= rs1_in;
		rs2_out <= rs2_in;
		ALU_operation_out <= ALU_operation_in;
		wb_src_out <= wb_src_in;
		mem_load_unsigned_out <= mem_load_unsigned_in;
		branch_target_out <= branch_target_in;
		current_PC_out <= current_PC_in;
		reg_or_PC_out <= reg_or_PC_in;
		PC_incr_out <= PC_incr_in;
	end if;
	
	
end process;
	
end behave;