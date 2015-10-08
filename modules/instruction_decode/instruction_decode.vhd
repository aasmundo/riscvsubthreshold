library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;


entity instruction_decode is
	port(
	clk : in std_logic;
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
	
	--control
	mem_we : std_logic;
	mem_be : std_logic_vector(1 downto 0);
	wb_src : std_logic;
	wb_we  : std_logic;
	ALU_operation : out std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
	is_branch : std_logic
	
	);
end instruction_decode;


architecture behave of instruction_decode is
signal opcode   : std_logic_vector(6 downto 0);
signal funct7   : std_logic_vector(6 downto 0);
signal alu_decode_helper : std_logic_vector(10 downto 0);
begin

opcode <= instr(6 downto 0);
funct7 <= instr(31 downto 25);

rd <= instr(11 downto 7); 
rs1 <= instr(19 downto 15);
rs2 <= instr(24 downto 20);

immediate_extender : entity work.imm_ext port map
	(
		instr  => instr,
		imm    => imm,
		is_imm => is_imm	
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
		read_data_2     => reg2		
	);

alu_decode_helper <= instr(30) & instr(14 downto 12) & instr(6 downto 0);	
decode : process(instr)
begin
	alu_opcode_decode : case(alu_decode_helper) is
		when "00000110011" =>  --ADD
			ALU_operation <= ALU_ADD_OPCODE;
		when "-0000010011" =>  --ADDI
			ALU_operation <= ALU_ADD_OPCODE;
		when "10000110011" =>  --SUB
			ALU_operation <= ALU_SUB_OPCODE;
		when "-0010-10011" =>  --SLL & SLLI
			ALU_operation <= ALU_SLL_OPCODE;
		when "-0100-10011" =>  --SLT & SLTI
			ALU_operation <= ALU_SLT_OPCODE;
		when "-0110-10011" =>  --SLTU & SLTIU
			ALU_operation <= ALU_SLTU_OPCODE;
		when "-1000-10011" =>  --XOR & XORI
			ALU_operation <= ALU_XOR_OPCODE;
		when "01010-10011" =>  --SRL & SRLI
			ALU_operation <= ALU_SRL_OPCODE;
		when "11010-10011" =>  --SRA & SRAI
			ALU_operation <= ALU_SRA_OPCODE;
		when "-1100-10011" =>  --OR & ORI
			ALU_operation <= ALU_OR_OPCODE;
		when "-1110-10011" => --AND & ANDI
			ALU_operation <= ALU_AND_OPCODE;
		when others => 
			ALU_operation <= ALU_ADD_OPCODE;
	end case;
end process;


	
end behave;
