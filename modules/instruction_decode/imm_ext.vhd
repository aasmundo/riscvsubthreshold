library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all; 

library work;
use work.constants.all;

entity imm_ext is
	port(
	instr : in std_logic_vector(31 downto 0);
	imm : out std_logic_vector(31 downto 0);
	is_imm : out std_logic
	);
end imm_ext;

architecture behave of imm_ext is
signal i_type, s_type, sb_type, u_type, ub_type, shamt_type, i_and_shamt_type : std_logic_vector(31 downto 0);
signal opcode : std_logic_vector(6 downto 0);
signal i_or_shamt : std_logic;
signal funct3 : std_logic_vector(2 downto 0);
begin
	
opcode <= instr(6 downto 0);
funct3 <= instr(14 downto 12);
	
i_type  <= std_logic_vector(resize(signed(instr(31 downto 20)), imm'length));
s_type  <= std_logic_vector(resize(signed(instr(31 downto 25) & instr(11 downto 7)), imm'length));
sb_type <= std_logic_vector(resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), imm'length));
u_type  <= instr(31 downto 12) & x"000";
ub_type <= std_logic_vector(resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21)), imm'length));
shamt_type <= x"000000" & "000" & instr(24 downto 20);



process(opcode, i_type, s_type, sb_type, u_type, ub_type, funct3, i_or_shamt, i_and_shamt_type)
begin
	is_imm <= '1';
	case(opcode) is
		when OPCODE_S_TYPE                       => imm <= s_type;
		when OPCODE_SB_TYPE                      => imm <= sb_type;
		when OPCODE_U_TYPE_1 | OPCODE_U_TYPE_2   => imm <= u_type;
		when OPCODE_UB_TYPE                      => imm <= ub_type;	
		when OPCODE_I_TYPE_A_2                   => imm <= i_and_shamt_type;
		when OPCODE_I_TYPE_A_1 | OPCODE_I_TYPE_B => imm <= i_type;
		when others                              => 
			imm <= i_type;
			is_imm <= '0';
	end case;
	
	case(funct3) is
		when "001" => i_or_shamt <= '0';
		when "101" => i_or_shamt <= '0';
		when others => i_or_shamt <= '1';
	end case;
	
	if (i_or_shamt = '1') then 	i_and_shamt_type <= i_type;
	else 						i_and_shamt_type <= shamt_type;
	end if;
	
	
		
end process;
end behave;