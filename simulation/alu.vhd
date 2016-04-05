library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity alu is
port (
    A      : in std_logic_vector(31 downto 0); 
    B      : in std_logic_vector(31 downto 0);
    operation : in std_logic_vector(3 downto 0);
    result    : out std_logic_vector(31 downto 0)
    );
end entity alu;

