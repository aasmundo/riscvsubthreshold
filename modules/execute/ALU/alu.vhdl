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
	   bpt_res  : std_logic_vector(31 downto 0);
signal add_en, sub_en, and_en, or_en, xor_en, sll_en, 
	   sra_en, srl_en, slt_en, sltu_en, bpt_en : std_logic;
begin


alu_add  : entity work.alu_adder port map(
    A => A,
    B => B,
    C => add_res,
    pwr_en => add_en
    );

alu_sub  : entity work.alu_subtractor port map(
    A => A,
    B => B,
    C => sub_res,
    pwr_en => sub_en
    );

alu_and  : entity work.alu_and port map(
    A => A,
    B => B,
    C => and_res,
    pwr_en => and_en
    );

alu_or   : entity work.alu_or port map(
    A => A,
    B => B,
    C => or_res,
    pwr_en => or_en
    );

alu_xor  : entity work.alu_xor port map(
    A => A,
    B => B,
    C => xor_res,
    pwr_en => xor_en
    );

alu_sll  : entity work.alu_sll port map(
    A => A,
    B => B(4 downto 0),
    C => sll_res,
    pwr_en => sll_en
    );

alu_sra  : entity work.alu_sra port map(
    A => A,
    B => B(4 downto 0),
    C => sra_res,
    pwr_en => sra_en
    );

alu_srl  : entity work.alu_srl port map(
    A => A,
    B => B(4 downto 0),
    C => srl_res,
    pwr_en => srl_en
    );

alu_slt  : entity work.alu_slt port map(
    A => A,
    B => B,
    C => slt_res,
    pwr_en => slt_en
    );

alu_sltu  : entity work.alu_sltu port map(
    A => A,
    B => B,
    C => sltu_res,
    pwr_en => sltu_en
    );

alu_bpt   : entity work.alu_bpt port map(
    B => B,
    C => bpt_res,
    pwr_en => bpt_en
    );


module_enable : process(operation)
begin
    
    add_en  <= '0';
    sub_en  <= '0';
    srl_en  <= '0';
    sra_en  <= '0';
    sltu_en <= '0';
    sll_en  <= '0';
    slt_en  <= '0';
    and_en  <= '0';
    or_en   <= '0';
    xor_en  <= '0';
    bpt_en  <= '0';

    case operation is
        when ALU_ADD_OPCODE     => add_en  <= '1';
        when ALU_SUB_OPCODE     => sub_en  <= '1';
        when ALU_SRL_OPCODE     => srl_en  <= '1';
        when ALU_SRA_OPCODE     => sra_en  <= '1';
        when ALU_SLTU_OPCODE    => sltu_en <= '1';
        when ALU_SLL_OPCODE     => sll_en  <= '1';
        when ALU_SLT_OPCODE     => slt_en  <= '1';
        when ALU_AND_OPCODE     => and_en  <= '1';
        when ALU_OR_OPCODE      => or_en   <= '1';
        when ALU_XOR_OPCODE     => xor_en  <= '1';
		when ALU_B_PASS_OPCODE  => bpt_en  <= '1';
        when others             => NULL;
    end case;
end process;

or_process : process(add_res, sub_res, srl_res, sra_res, sltu_res, 
    sll_res, slt_res, and_res, or_res, xor_res, bpt_res)
begin
    result <= add_res or sub_res or srl_res or sra_res or sltu_res or 
    sll_res or slt_res or and_res or or_res or xor_res or bpt_res;

end process;


end alu_arch;