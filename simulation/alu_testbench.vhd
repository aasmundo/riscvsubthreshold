library IEEE;
use ieee.math_real.all;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants.all;

LIBRARY worklib;

entity alu_testbench is
port(not_connected : out std_logic
);
end alu_testbench;



architecture alu_tb of alu_testbench is
signal A, B, result, result_a : std_logic_vector(31 downto 0);
signal operation : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
begin

ALUinstance : entity worklib.alu port map (
A => A,
B => B,
operation => operation,
result => result_a
);
result <= result_a;
stim: process
variable seed1, seed2: positive;
variable rand: real;
variable A_val, B_val, opcode_val : integer;
begin
	
	for i in 0 to 1000 loop
		UNIFORM(seed1, seed2, rand);
		A_val := integer(trunc(rand*2147483648.0));

		UNIFORM(seed1, seed2, rand);
		B_val := integer(trunc(rand*2147483648.0));

		UNIFORM(seed1, seed2, rand);
		opcode_val := integer(trunc(rand*12.0));
		operation <= std_logic_vector(to_signed(opcode_val, ALU_OPCODE_WIDTH));
		if(operation = ALU_SLTU_opcode) then 
			A <= std_logic_vector(to_unsigned(A_val, 32));
			B <= std_logic_vector(to_unsigned(B_val, 32));
		else
			A_val := A_val - 1073741823; 
			B_val := B_val - 1073741823;
			A <= std_logic_vector(to_signed(A_val, 32)); 
			B <= std_logic_vector(to_signed(B_val, 32));
		end if;
		wait for 1 us;
		case operation is
			when ALU_ADD_OPCODE =>
				assert (to_integer(signed(result)) = A_val + B_val) report "ALU add error: "&integer'IMAGE(to_integer(signed(result)))&" should be: "&integer'IMAGE(A_val + B_val) severity error;
			when ALU_SUB_OPCODE =>
				assert (to_integer(signed(result)) = A_val - B_val) report "ALU sub error: "&integer'IMAGE(to_integer(signed(result)))&" should be: "&integer'IMAGE(A_val + B_val) severity error;
			when ALU_SLL_OPCODE =>
				assert (to_integer(signed(result)) = to_integer(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))))) report "ALU sll error: "&integer'IMAGE(to_integer(signed(result)))&" should be: "&integer'IMAGE(to_integer(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))))) severity error;
			when ALU_SLT_OPCODE =>
				if((A_val < B_val and result(0) = '0') or (not(A_val < B_val) and result(0) = '1')) then
					assert (false) report "ALU slt error" severity error;
				end if;
			when ALU_AND_OPCODE =>
				assert (result = (A and B)) report "ALU and error" severity error;
			when ALU_OR_OPCODE =>
				assert (result = (A or B)) report "ALU or error" severity error; 
			when ALU_XOR_OPCODE =>
				assert (result = (A xor B)) report "ALU xor error" severity error;
			when ALU_SRA_OPCODE =>
				assert (to_integer(signed(result)) = to_integer(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))))) report "ALU sra error: "&integer'IMAGE(to_integer(signed(result)))&" should be: "&integer'IMAGE(to_integer(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))))) severity error;
			when ALU_SLTU_opcode =>
				if((unsigned(A) < unsigned(B) and result(0) = '0') or (not(unsigned(A) < unsigned(B)) and result(0) = '1')) then
					assert (false) report "ALU sltu error" severity error;
				end if;
			when ALU_SRL_OPCODE =>
				assert (to_integer(signed(result)) = to_integer(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))))) report "ALU srl error: "&integer'IMAGE(to_integer(signed(result)))&" should be: "&integer'IMAGE(to_integer(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))))) severity error;
			when others => null;
		end case;	
	end loop;
	
	
end process;

	
end alu_tb;
