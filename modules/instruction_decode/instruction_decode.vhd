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
	rd : out std_logic_vector(4 downto 0)
	);
end instruction_decode;


architecture behave of instruction_decode is
signal opcode   : std_logic_vector(6 downto 0);
signal funct7   : std_logic_vector(6 downto 0);
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


	
end behave;
