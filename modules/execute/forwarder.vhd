library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.constants.all;

entity forwarder is
	port(
	rs1_ex, rs2_ex, rs2_mem : in std_logic_vector(4 downto 0);
	rd_mem, rd_wb           : in std_logic_vector(4 downto 0);
	rd_mem_we, rd_wb_we     : in std_logic;
	
	mem_rs2_src             : out std_logic;
	rs1_src, rs2_src        : out std_logic_vector(1 downto 0)
	
	);
end forwarder;

architecture behave of forwarder is
signal rs1_exmem_conflict, rs1_exwb_conflict : std_logic;
signal rs2_exmem_conflict, rs2_exwb_conflict : std_logic;
signal rs2_memwb_conflict : std_logic;
begin
	
combi : process(rs1_ex, rs2_ex, rd_mem, rd_wb, rd_mem_we, rd_wb_we, rs1_exmem_conflict, rs1_exwb_conflict, rs2_exmem_conflict, rs2_exwb_conflict, rs2_memwb_conflict, rs2_mem)

begin
	rs1_exmem_conflict <= '0';
	rs1_exwb_conflict  <= '0';
	rs2_exmem_conflict <= '0';
	rs2_exwb_conflict  <= '0';
	rs2_memwb_conflict <= '0';
	if(rs1_ex = rd_mem and rd_mem /= "00000") then
		rs1_exmem_conflict <= rd_mem_we;
	end if;
	if(rs1_ex = rd_wb and rd_wb /= "00000") then
		rs1_exwb_conflict  <= rd_wb_we;
	end if;
	if(rs2_ex = rd_mem and rd_mem /= "00000") then
		rs2_exmem_conflict <= rd_mem_we;
	end if;
	if(rs2_ex = rd_wb and rd_wb /= "00000") then
		rs2_exwb_conflict  <= rd_wb_we;
	end if;
	if(rs2_mem = rd_wb and rd_wb /= "00000") then
		rs2_memwb_conflict <= rd_wb_we;
	end if;
	
	rs1_src <= rs1_exmem_conflict & rs1_exwb_conflict;
	rs2_src <= rs2_exmem_conflict & rs2_exwb_conflict;
	mem_rs2_src <= rs2_memwb_conflict;
	
end process;
	
	
end behave;