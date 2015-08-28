library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity ALU is
port (
	A, B      : in std_logic_vector(31 downto 0);
	operation : in std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
	result    : out std_logic_vector(31 downto 0)
);
end ALU;

architecture ALU_arch of ALU is
signal A_ext_MSB, B_ext_MSB : std_logic; 
signal A_ext, B_ext : std_logic_vector(32 downto 0);
signal add_res, sub_res, and_res, or_res, xor_res : signed(32 downto 0);
signal slt_res : std_logic;
begin


combi: process(A, B, operation, A_ext_MSB, B_ext_MSB, A_ext, B_ext)
begin
	A_ext_MSB <= (not operation(ALU_UNSIGNED_POS)) and A(31);
	B_ext_MSB <= (not operation(ALU_UNSIGNED_POS)) and B(31);
	A_ext <= A_ext_MSB & A;
	B_ext <= B_ext_MSB & B;
	
	add_res <= signed(A_ext) + signed(B_ext);
	sub_res <= signed(A_ext) - signed(B_ext);
	if(signed(A_ext) < signed(B_ext)) then
		slt_res <= '1';
	else
		slt_res <= '0';
	end if;
	
	and_res <= signed(A_ext and B_ext);
	or_res  <= signed(A_ext or  B_ext);
	xor_res <= signed(A_ext xor B_ext);

end process;

mux: process(add_res, sub_res, slt_res, and_res, or_res, xor_res)
begin
	case operation(ALU_UNSIGNED_POS - 1 downto 0) is
		when ALU_ADD_OPCODE => result <= std_logic_vector(add_res(31 downto 0));
		when ALU_SUB_OPCODE => result <= std_logic_vector(sub_res(31 downto 0));
		when ALU_SLT_OPCODE => result <= std_logic_vector(x"0000000" & "000" & slt_res);
		when ALU_AND_OPCODE => result <= std_logic_vector(and_res(31 downto 0));
		when ALU_OR_OPCODE  => result <= std_logic_vector(or_res(31 downto 0));
		when ALU_XOR_OPCODE => result <= std_logic_vector(xor_res(31 downto 0));
		when others 		=> result <= x"00000000";
	end case;
end process;


end ALU_arch;