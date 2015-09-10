library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity ALU is
port (
	A, B      : in std_logic_vector(31 downto 0);
	opcode_5  : in std_logic;
	funct7_5  : in std_logic;				  
	funct3    : in std_logic_vector(FUNCT3_WIDTH - 1 downto 0);
	
	result    : out std_logic_vector(31 downto 0)
);
end ALU;

architecture ALU_arch of ALU is
signal add_res, sub_res, and_res, or_res, xor_res, add_sub_res, 
	   sll_res, sra_res, srl_res, srl_sra_res : signed(31 downto 0);
signal slt_res, sltu_res : std_logic;
signal add_or_sub, srl_or_sra : std_logic; 
begin


combi: process(A, B, funct3, funct7_5, opcode_5)
begin	
	add_res <= signed(A) + signed(B);
	sub_res <= signed(A) - signed(B);
	if(signed(A) < signed(B)) then
		slt_res <= '1';
	else
		slt_res <= '0';
	end if;
	if(unsigned(A) < unsigned(B)) then
		sltu_res <= '1';
	else
		sltu_res <= '0';
	end if;
	
	and_res <= signed(A and B);
	or_res  <= signed(A or  B);
	xor_res <= signed(A xor B);
	
	
	sll_res <= signed(std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0))))));
	srl_res <= signed(std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0))))));
	sra_res <= shift_right(signed(A), to_integer(unsigned(B(4 downto 0))));
	
	add_or_sub <= not (funct7_5 and opcode_5);
	srl_or_sra <= not funct7_5;
end process;

mux: process(add_sub_res, srl_sra_res, sltu_res, sll_res, slt_res, and_res, or_res, xor_res, add_or_sub, srl_or_sra, funct3)
begin
	case add_or_sub is
		when '0' => add_sub_res <= sub_res;
		when '1' => add_sub_res <= add_res;
		when others => add_sub_res <= add_res;
	end case;
			
	case srl_or_sra is
		when '0' => srl_sra_res <= sra_res;
		when '1' => srl_sra_res <= srl_res;
		when others => srl_sra_res <= srl_res;
	end case;
	
	case funct3 is
		when ALU_ADD_SUB_OPCODE => result <= std_logic_vector(add_sub_res);
		when ALU_SRL_SRA_OPCODE => result <= std_logic_vector(srl_sra_res);
		when ALU_SLTU_OPCODE    => result <= std_logic_vector(x"0000000" & "000" & sltu_res);
		when ALU_SLL_OPCODE     => result <= std_logic_vector(sll_res);
		when ALU_SLT_OPCODE     => result <= std_logic_vector(x"0000000" & "000" & slt_res);
		when ALU_AND_OPCODE     => result <= std_logic_vector(and_res);
		when ALU_OR_OPCODE      => result <= std_logic_vector(or_res);
		when ALU_XOR_OPCODE     => result <= std_logic_vector(xor_res);
		when others 		    => result <= x"00000000";
	end case;
end process;


end ALU_arch;