library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity activity_control is
	port(	
	clk                    : in  std_logic;
	
	sleep,
	stall_ID,  
	nreset,
	control_transfer_MEM   : in  std_logic;
	
	init_sleep,
	counter_enable,		   
	stall_IF,
	stall,
	flush_IFID,
	flush_IDEX,
	flush_EXMEM,
	flush_MEMWB		   : out std_logic
	
	);
end activity_control;


architecture behave of activity_control is
signal stall_i : std_logic;
signal sleeping	: std_logic;
begin
	counter_enable <= not sleep;	
	stall_i <= (sleeping or stall_ID) and nreset;
	stall_IF <= stall_i and not control_transfer_MEM;
	flush_IFID <= control_transfer_MEM or sleep or not nreset;
	flush_IDEX <= control_transfer_MEM or sleep or stall_i or not nreset;
	flush_EXMEM <= control_transfer_MEM or sleep or not nreset;
	flush_MEMWB <= not nreset;	  
	stall <= stall_i;
	
	seq : process(clk) is
	begin
		if(clk'event and clk = '1') then
			if(nreset = '0') then
				sleeping <= '0';
			else
				sleeping <= sleep;
			end if;
			
		end if;
		
	end process;
end behave;