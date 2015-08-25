library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ALU is
port {
	A, B in std_logic_vector(31 downto 0);
	operation in std_logic_vector($alu_opcode downto 0);
	result out std_logic_vector(31 downto 0)
};
end ALU;

architecture ALU_arch of ALU is
signal add_res, sub_res, slt_res, and_res, or_res, xor_res std_logic_vector(31 downto 0);
begin


combi: process(A, B, operation)
begin
	add_res <= A + B;
	sub_res <= A - B;
	if(A < B) then
		slt_res <= 0x00000001;
	else 
		slt_res <= 0x00000000;
	end if;
	and_res <= A and B;
	or_res <= A or B;
	xor_res <= A xor B;
end process;


end ALU_arch;