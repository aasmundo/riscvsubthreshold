library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity clock_gate is
port(
        clk       : in  std_logic;
        en        : in  std_logic;
        gated_clk : out std_logic
);
end clock_gate;

architecture behave of clock_gate is
signal not_en, not_clk, n1, n2, n3, n4, n5, n6 : std_logic;
begin
        gated_clk <= clk and n5;
        not_en <= not en;
        not_clk <= not clk;
        n1 <= not_en nand not_clk;
        n2 <= not_clk nand en;
        n3 <= not n1;
        n4 <= not n2;
        n5 <= n3 nor n6;
        n6 <= n5 nor n4;
end behave;