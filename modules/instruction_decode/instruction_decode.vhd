library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;


entity instruction_decode is
	port(
	clk : in std_logic;
	nreset : in std_logic;
	instr : in std_logic_vector(31 downto 0);
	
	wb_reg : in std_logic_vector(4 downto 0);
	wb_data : in std_logic_vector(31 downto 0);
	wb_write : in std_logic;
	
	
	reg1 : out std_logic_vector(31 downto 0);
	reg2 : out std_logic_vector(31 downto 0);
	imm  : out std_logic_vector(31 downto 0);
	is_imm : out std_logic;
	rs1 : out std_logic_vector(4 downto 0);
	rs2 : out std_logic_vector(4 downto 0);
	rd : out std_logic_vector(4 downto 0); 
	
	--hazard
	ex_rd : in std_logic_vector(4 downto 0);
	ex_wb_src : in std_logic_vector(1 downto 0);
	stall : out std_logic;
	
	--control
	mem_we : out std_logic;
	mem_be : out std_logic_vector(1 downto 0);
	wb_src : out std_logic_vector(1 downto 0);
	wb_we  : out std_logic;
	ALU_operation : out std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
	is_branch : out std_logic;
	mem_load_unsigned : out std_logic;
	reg_or_PC : out std_logic;
	is_jump : out std_logic
	
	);
end instruction_decode;


architecture behave of instruction_decode is
signal opcode   : std_logic_vector(6 downto 0);
signal alu_decode_helper : std_logic_vector(10 downto 0);
signal is_immediate : std_logic;
begin

opcode <= instr(6 downto 0);

rd <= instr(11 downto 7); 
rs1 <= instr(19 downto 15);
rs2 <= instr(24 downto 20);
is_imm <= is_immediate;

immediate_extender : entity work.imm_ext port map
	(
		instr  => instr,
		imm    => imm,
		is_imm => is_immediate	
	);
	
register_file : entity work.register_file port map
	(
		clk => clk,
		read_register_1 => instr(19 downto 15),
		read_register_2 => instr(24 downto 20),
		write_register  => wb_reg,
		reg_write       => wb_write,
		write_data      => wb_data,
		read_data_1     => reg1,
		read_data_2     => reg2,
		nreset          => nreset
	);

	
control : entity work.control port map
	(
		opcode => opcode,
		funct3 => instr(14 downto 12),
		wb_we => wb_we,	
		wb_src => wb_src,
		mem_we => mem_we,
		mem_write_width => mem_be,
		is_branch => is_branch,
		is_jump => is_jump,
		mem_load_unsigned => mem_load_unsigned,
		reg_or_PC => reg_or_PC
	);
	
hazard_detector : entity work.hazard_detector port map
	(
		is_imm => is_immediate,
		rs1 => instr(19 downto 15),
		rs2 => instr(24 downto 20),
		ex_rd => ex_rd,
		ex_wb_src => ex_wb_src,
		stall => stall
		
	);
	
alu_decode_helper <= instr(30) & instr(14 downto 12) & instr(6 downto 0);	
decode : process(alu_decode_helper)
begin
	alu_opcode_decode : case(alu_decode_helper) is
		when "00000110011" =>  --ADD
			ALU_operation <= ALU_ADD_OPCODE;
		when "00000010011" | "10000010011"  =>  --ADDI
			ALU_operation <= ALU_ADD_OPCODE;
		when "10000110011" =>  --SUB
			ALU_operation <= ALU_SUB_OPCODE;
		when "00010010011" | "00010110011" | "10010010011" | "10010110011" =>  --SLL & SLLI
			ALU_operation <= ALU_SLL_OPCODE;
		when "00100010011" | "00100110011" | "10100010011" | "10100110011" =>  --SLT & SLTI
			ALU_operation <= ALU_SLT_OPCODE;
		when "00110010011" | "00110110011" | "10110010011" | "10110110011" =>  --SLTU & SLTIU
			ALU_operation <= ALU_SLTU_OPCODE;
		when "01000010011" | "01000110011" | "11000010011" | "11000110011" =>  --XOR & XORI
			ALU_operation <= ALU_XOR_OPCODE;
		when "01010010011" | "01010110011" =>  --SRL & SRLI
			ALU_operation <= ALU_SRL_OPCODE;
		when "11010010011" | "11010110011" =>  --SRA & SRAI
			ALU_operation <= ALU_SRA_OPCODE;
		when "01100010011" | "01100110011" | "11100010011" | "11100110011" =>  --OR & ORI
			ALU_operation <= ALU_OR_OPCODE;
		when "01110010011" | "01110110011" | "11110010011" | "11110110011" => --AND & ANDI
			ALU_operation <= ALU_AND_OPCODE;
		when "00001100011" | "10001100011" => --BEQ
			ALU_operation <= ALU_SUB_OPCODE;
		when "00011100011" | "10011100011" => --BNE
			ALU_operation <= ALU_SUB_OPCODE;
		when "01001100011" | "11001100011" => --BLT
			ALU_operation <= ALU_SLT_OPCODE;
		when "01011100011" | "11011100011" => --BGE
			ALU_operation <= ALU_SLT_OPCODE;
		when "01101100011" | "11101100011" => --BLTU
			ALU_operation <= ALU_SLTU_OPCODE;
		when "01111100011" | "11111100011" => --BGEU
			ALU_operation <= ALU_SLTU_OPCODE;
		when "00000110111" | "00010110111" | "00100110111" | "00110110111" |
			 "01000110111" | "01010110111" | "01100110111" | "01110110111" |
			 "10000110111" | "10010110111" | "10100110111" | "10110110111" |
			 "11000110111" | "11010110111" | "11100110111" | "11110110111" => --LUI
			ALU_operation <= ALU_B_PASS_OPCODE;
		when "00001101111" | "00011101111" | "00101101111" | "00111101111" |
			 "01001101111" | "01011101111" | "01101101111" | "01111101111" |
			 "10001101111" | "10011101111" | "10101101111" | "10111101111" |
			 "11001101111" | "11011101111" | "11101101111" | "11111101111" => --JAL
			ALU_operation <= ALU_B_PASS_OPCODE; 
		when "00000010111" | "00010010111" | "00100010111" | "00110010111" |
			 "01000010111" | "01010010111" | "01100010111" | "01110010111" |
			 "10000010111" | "10010010111" | "10100010111" | "10110010111" |
			 "11000010111" | "11010010111" | "11100010111" | "11110010111" => --AUIPC
			ALU_operation <= ALU_ADD_OPCODE;
		when others => 
			ALU_operation <= ALU_ADD_OPCODE;
	end case;
end process;


	
end behave;
