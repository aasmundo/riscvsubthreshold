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
signal add_res, add_res_iso, sub_res, sub_res_iso, and_res, and_res_iso, or_res, or_res_iso, xor_res, xor_res_iso,  
	   sll_res, sll_res_iso, sra_res, sra_res_iso, srl_res, srl_res_iso, slt_res, slt_res_iso, sltu_res, sltu_res_iso,
	   bpt_res, bpt_res_iso  : std_logic_vector(31 downto 0);
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

add_res_iso <= add_res and (add_res'range => add_en);
sub_res_iso <= sub_res and (sub_res'range => sub_en);
srl_res_iso <= srl_res and (srl_res'range => srl_en);
sra_res_iso <= sra_res and (sra_res'range => sra_en);
sltu_res_iso <= sltu_res and (sltu_res'range => sltu_en);
sll_res_iso <= sll_res and (sll_res'range => sll_en);
slt_res_iso <= slt_res and (slt_res'range => slt_en);
and_res_iso <= and_res and (and_res'range => and_en);
or_res_iso <= or_res and (or_res'range => or_en);
xor_res_iso <= xor_res and (xor_res'range => xor_en);
bpt_res_iso <= bpt_res and (bpt_res'range => bpt_en);



result <= add_res_iso or sub_res_iso or srl_res_iso or sra_res_iso or sltu_res_iso or 
    sll_res_iso or slt_res_iso or and_res_iso or or_res_iso or xor_res_iso or bpt_res_iso;



end alu_arch;