library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity IDEX_preg is
	port(
		clk : in std_logic;
		flush : in std_logic;

		opcode_5_out : out std_logic;
		funct7_5_out : out std_logic;
		funct3_out : out std_logic_vector(FUNCT3_WIDTH - 1 downto 0);
		
		ALU_b_src_out : out std_logic;
		reg1_out : out std_logic_vector(31 downto 0);
		reg2_out : out std_logic_vector(31 downto 0);
		imm_out : out std_logic_vector(31 downto 0);
		is_imm_out : out std_logic;
		rs1_out : out std_logic_vector(4 downto 0);
		rs2_out : out std_logic_vector(4 downto 0);
		rd_out : out std_logic_vector(4 downto 0);

		opcode_5_in : in std_logic;
		funct7_5_in : in std_logic;
		funct3_in : in std_logic_vector(FUNCT3_WIDTH - 1 downto 0);
		
		ALU_b_src_in : in std_logic;
		reg1_in : in std_logic_vector(31 downto 0);
		reg2_in : in std_logic_vector(31 downto 0);
		imm_in : in std_logic_vector(31 downto 0);
		is_imm_in : in std_logic;
		rs1_in : in std_logic_vector(4 downto 0);
		rs2_in : in std_logic_vector(4 downto 0);
		rd_in : in std_logic_vector(4 downto 0)

	);
end IDEX_preg;

architecture behave of IDEX_preg is

begin
	
seq : process(clk, opcode_5_in, funct7_5_in, ALU_b_src_in, reg1_in, reg2_in, imm_in, is_imm_in, rs1_in, rs2_in, rd_in)
begin
	if(clk'event and clk = '1') then
		if(flush = '1') then
		    opcode_5_out <= '0';
			funct7_5_out <= '0';
			funct3_out <= "000";
			rd_out <= "00000";
		else
			opcode_5_out <= opcode_5_in;
			funct7_5_out <= funct7_5_in;
			funct3_out <= funct3_in;
			rd_out <= rd_in;
		end if;
		ALU_b_src_out <= ALU_b_src_in;
		reg1_out <= reg1_in;
		reg2_out <= reg2_in;
		imm_out <= imm_in;
		is_imm_out <= is_imm_in;
		rs1_out <= rs1_in;
		rs2_out <= rs2_in;
	end if;
	
	
end process;
	
end behave;