library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;


entity alu is
port (
    A, B      : in std_logic_vector(31 downto 0);
    operation : in std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0);
    
    result    : out std_logic_vector(31 downto 0)
);
end alu;

architecture alu_arch of alu is
signal add_res, sub_res, and_res, or_res, xor_res,  
	   sll_res, sra_res, srl_res, slt_res, sltu_res,
	   b_pass_through_res : signed(31 downto 0);
begin


combi: process(A, B)
begin    
    add_res <= signed(A) + signed(B);
    sub_res <= signed(A) - signed(B);
    if(signed(A) < signed(B))     then  slt_res <= x"00000001";    
    else                                slt_res <= x"00000000";    
    end if;
    if(unsigned(A) < unsigned(B)) then sltu_res <= x"00000001";    
    else                               sltu_res <= x"00000000";            
    end if;
    
    and_res <= signed(A and B);
    or_res  <= signed(A or  B);
    xor_res <= signed(A xor B);
    
    
    sll_res <= signed(std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0))))));
    srl_res <= signed(std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0))))));
    sra_res <= shift_right(signed(A), to_integer(unsigned(B(4 downto 0))));
    
	b_pass_through_res <= signed(B);
end process;

mux: process(add_res, sub_res, srl_res, sra_res, sltu_res, sll_res, slt_res, and_res, or_res, xor_res, operation, b_pass_through_res)
begin

    case operation is
        when ALU_ADD_OPCODE     => result <= std_logic_vector(add_res);
        when ALU_SUB_OPCODE     => result <= std_logic_vector(sub_res);
        when ALU_SRL_OPCODE     => result <= std_logic_vector(srl_res);
        when ALU_SRA_OPCODE     => result <= std_logic_vector(sra_res);
        when ALU_SLTU_OPCODE    => result <= std_logic_vector(sltu_res);
        when ALU_SLL_OPCODE     => result <= std_logic_vector(sll_res);
        when ALU_SLT_OPCODE     => result <= std_logic_vector(slt_res);
        when ALU_AND_OPCODE     => result <= std_logic_vector(and_res);
        when ALU_OR_OPCODE      => result <= std_logic_vector(or_res);
        when ALU_XOR_OPCODE     => result <= std_logic_vector(xor_res);
		when ALU_B_PASS_OPCODE  => result <= std_logic_vector(b_pass_through_res);
        when others             => result <= x"00000000";
    end case;
end process;


end ALU_arch;