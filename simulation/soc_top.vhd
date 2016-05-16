library IEEE;
use IEEE.std_logic_1164.all;

entity soc_top is
	port(
		clk          : in std_logic;
		d_clk        : in std_logic;
		nreset       : in std_logic;
	    
		--testbench
		pass         : out std_logic;
		fail         : out std_logic;
		--spi--
		sclk         : out std_logic;
		miso         : in  std_logic;
		mosi         : out std_logic;
		cs1          : out std_logic;
		cs2          : out std_logic;
		cs3         : out std_logic;
		cs4         : out std_logic;
		
		--reroute for fast sim--
		skip_startup : in std_logic;
		d_clk_out    : out std_logic;
		--instr-mem-reroute--
		instr_mem_write_en : out std_logic;
		instr_mem_Address  : out std_logic_vector(10 downto 0);
		instr_mem_write_data_input : out std_logic_vector(31 downto 0);
		instr_mem_read_data	: in std_logic_vector(31 downto 0);
		instr_mem_reset_pulse_generator : out std_logic;
		instr_mem_idle : in std_logic;
		--instr-mem-reroute--
		data_mem_write_en : out std_logic;
		data_mem_Address  : out std_logic_vector(10 downto 0);
		data_mem_write_data_input : out std_logic_vector(31 downto 0);
		data_mem_read_data	: in std_logic_vector(31 downto 0);
		data_mem_be : out std_logic_vector(1 downto 0);
		data_mem_reset_pulse_generator : out std_logic;
		data_mem_idle : in std_logic
		);
end entity;
