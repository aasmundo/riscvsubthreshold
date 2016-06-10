library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

library work;
use work.constants.all;


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
		instr_mem_Address  : out std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
		instr_mem_write_data_input : out std_logic_vector(31 downto 0);
		instr_mem_read_data	: in std_logic_vector(31 downto 0);
		instr_mem_reset_pulse_generator : out std_logic;
		instr_mem_idle : in std_logic;
		--instr-mem-reroute--
		data_mem_write_en : out std_logic;
		data_mem_Address  : out std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
		data_mem_write_data_input : out std_logic_vector(31 downto 0);
		data_mem_read_data	: in std_logic_vector(31 downto 0);
		data_mem_be : out std_logic_vector(1 downto 0);
		data_mem_reset_pulse_generator : out std_logic;
		data_mem_idle : in std_logic
		);
end entity;





architecture behave of soc_top is	
	--test interface
	signal pass_i, pass_i_reg : std_logic;
	signal fail_i, fail_i_reg : std_logic;
	
	
	--SPI and startup
	signal spi_settings     :  std_logic;
	signal spi_data_in      :  std_logic_vector(31 downto 0);
	signal spi_data_out     :  std_logic_vector(31 downto 0);
	
	signal spi_busy         :  std_logic;
	signal spi_finished     :  std_logic;
	signal spi_clear        :  std_logic;
	signal spi_start        :  std_logic;
	
	signal startup_data_mem : std_logic_vector(31 downto 0);	
	signal startup_address  : std_logic_vector(DATA_MEM_WIDTH - 3 downto 0);
	signal startup_we		: std_logic;
	signal startup_done		: std_logic;
	
	signal clk_reset, 
	reset_last   : std_logic;
	signal sync_reset : std_logic;
	--memory
	signal instr_we         : std_logic;
	signal instr_data_w		: std_logic_vector(31 downto 0);
	signal instr_data_r	: std_logic_vector(31 downto 0);
	signal instr_addr		: std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	signal instr_re         : std_logic;
	signal instr_idle       : std_logic;

	
	signal data_we          : std_logic; 
	signal data_mem_we      : std_logic;
	signal data_data_w		: std_logic_vector(31 downto 0);
	signal data_data_r		: std_logic_vector(31 downto 0);
	signal data_addr        : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
	signal data_be          : std_logic_vector(1 downto 0);
	signal data_re          : std_logic; 
	
	signal data_mem_data_r  : std_logic_vector(31 downto 0); 
	signal data_mem_re      : std_logic;
	signal data_busy        : std_logic;
	signal data_idle        : std_logic;
	
	signal startup_instr_addr : std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	signal startup_data_addr  : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
	signal startup_instr_we   : std_logic;
	signal startup_data_we    : std_logic;
	
	signal startup_spi_data_in  : std_logic_vector(31 downto 0);
	signal startup_spi_data_out : std_logic_vector(31 downto 0);
	signal startup_spi_finished : std_logic;
	signal startup_spi_start    : std_logic;
	signal startup_spi_clear    : std_logic;
	signal startup_spi_settings : std_logic;
	
	signal cpu_instr_we         : std_logic;
	signal cpu_instr_data_w		: std_logic_vector(31 downto 0);
	signal cpu_instr_data_r		: std_logic_vector(31 downto 0);
	signal cpu_instr_addr		: std_logic_vector(INSTRUCTION_MEM_WIDTH - 1 downto 0);
	signal cpu_instr_re         : std_logic;
	
	signal cpu_data_we          : std_logic;
	signal cpu_data_data_w		: std_logic_vector(31 downto 0);
	signal cpu_data_addr        : std_logic_vector(SPI_AND_DATA_MEM_WIDTH - 1 downto 0);
	signal cpu_data_be          : std_logic_vector(1 downto 0);
	signal cpu_data_re          : std_logic;
	
	signal cpu_spi_data_in  : std_logic_vector(31 downto 0);
	signal cpu_spi_data_out : std_logic_vector(31 downto 0);
	signal cpu_spi_finished : std_logic;
	signal cpu_spi_start    : std_logic;
	signal cpu_spi_clear    : std_logic;
	signal cpu_spi_settings : std_logic;
	
	signal data_to_spi : std_logic_vector(31 downto 0);
	
	signal mem_data_n, mem_data_seq : std_logic_vector(31 downto 0);
	
	
	signal mem_data_src, mem_data_src_n : std_logic;
	
	signal sleep_we, sleep_type, sleep_ctl : std_logic;
	
	signal timer : std_logic_vector(63 downto 0);
	
	--CPU
	signal cpu_sleep : std_logic;
	--testsignal
	signal mem_re_last : std_logic;
	
	--pragma synthesis_off
	signal sleep_cnt      : integer := 0;
	signal awake_cnt      : integer := 0;
	signal dmem_read_cnt  : integer := 0;
	signal dmem_write_cnt : integer := 0;
	signal dmem_idle_cnt  : integer := 0;
	--pragma synthesis_on
begin
	pass <= pass_i_reg;
	fail <= fail_i_reg;
	d_clk_out <= d_clk;
	
	cpu_sleep <= (not startup_done) or (pass_i_reg or fail_i_reg) or sleep_ctl;
	
	
	
	
	sync_reset_process : process(d_clk)
	begin
		if(d_clk'event and d_clk = '1') then
			sync_reset <= nreset;	
		end if;
	end process; 
	
	test_process : process(d_clk)
	begin
		if(d_clk'event and d_clk = '1') then
			if(nreset = '0') then
				pass_i_reg <= '0';
				fail_i_reg <= '0';
			else
				pass_i_reg <= pass_i;
				fail_i_reg <= fail_i;
			end if;
		end if;	
	end process;
	
	startup_instr_addr <= startup_address(DATA_MEM_WIDTH - 3 downto 0) & "00";
	startup_data_addr  <= '0' & startup_address(DATA_MEM_WIDTH - 3 downto 0) & "00";
	
	cpu_spi_data_in <= cpu_data_data_w;
	startup_spi_finished <= spi_finished;
	startup_spi_data_out <= spi_data_out;
	cpu_spi_data_out <= spi_data_out;
	
	memory_control_selector : process(startup_done, startup_instr_addr, 
		startup_data_addr, startup_instr_we, startup_data_we, startup_data_mem, 
		startup_data_mem, cpu_instr_addr, cpu_data_addr, cpu_instr_we,
		cpu_data_we, cpu_data_be, cpu_instr_data_w, cpu_data_re, cpu_instr_re, 
		cpu_data_data_w, startup_spi_data_in, startup_spi_start, startup_spi_clear, 
		startup_spi_settings, cpu_spi_data_in , cpu_spi_start, cpu_spi_clear, cpu_spi_settings)
	begin
		case (startup_done) is
			when '0' =>
				instr_addr    <= startup_instr_addr;
				data_addr     <= startup_data_addr;
				instr_we      <= startup_instr_we;
				data_we       <= startup_data_we;
				data_be       <= "10";
				instr_data_w  <= startup_data_mem;
				data_data_w   <= startup_data_mem;
				data_re       <= '0';
				instr_re      <= '0';
				data_to_spi   <= startup_spi_data_in;
				spi_start     <= startup_spi_start;
				spi_clear     <= startup_spi_clear;
			spi_settings  <= startup_spi_settings;
			when '1' =>
				instr_addr    <= cpu_instr_addr;
				data_addr     <= cpu_data_addr;
				instr_we      <= cpu_instr_we;
				data_we       <= cpu_data_we;
				data_be       <= cpu_data_be;
				instr_data_w  <= cpu_instr_data_w;
				data_data_w   <= cpu_data_data_w;
				data_re       <= cpu_data_re;
				instr_re      <= cpu_instr_re;
				data_to_spi   <= cpu_spi_data_in;
				spi_start     <= cpu_spi_start;
				spi_clear     <= cpu_spi_clear;
			spi_settings  <= cpu_spi_settings;
			when others =>
			NULL;
		end case;
	end process;
	
	memory_map : process(mem_data_src, mem_data_seq, data_mem_data_r)
	begin
		case (mem_data_src) is
			when '1'   =>
			data_data_r	<= mem_data_seq;
			when '0'  =>
			data_data_r <= data_mem_data_r;
			when others =>
				null;
		end case;	
	end process;
	
	
	
	
	
	spi_status_regs : process(d_clk)
	begin
	if(d_clk'event and d_clk = '1') then
	mem_data_seq <= mem_data_n;
	mem_data_src <= mem_data_src_n;
	mem_re_last <= data_mem_re;
	end if;
	
	end process;
	
	
	mem_map_decode : process( data_addr, data_re, data_we, spi_data_out, data_mem_data_r, spi_busy, mem_data_src)
		
	begin
		data_mem_we <= data_we;
		data_mem_re <= data_re;	 
		data_busy   <= '0';
		mem_data_src_n <= '0';
		
		cpu_spi_settings <= '0';
		cpu_spi_start    <= '0';
		cpu_spi_clear    <= '0';
		mem_data_n <= spi_data_out;
		
		sleep_we <= '0';
		sleep_type <= data_addr(0);
		
		
		case (data_addr(SPI_AND_DATA_MEM_WIDTH - 1 downto 4)) is
			when RESERVED_ADDR_SPACE =>
				data_mem_we     <= '0';
				data_mem_re     <= '0';
				mem_data_src_n    <= '1';
				case (data_addr(2)) is
					when '1'   =>  --SPI address space
						data_busy <= spi_busy;
						case (data_addr(1 downto 0)) is
							when "00" =>
								mem_data_n <= x"0000000" & "00" &  spi_finished & spi_busy; 	--address: FFC
							when SPI_settings_OP =>
								cpu_spi_settings  <= data_we;              --address: FFD
							when SPI_START_OP    =>
								cpu_spi_start     <= data_we;              --address: FFE
							when SPI_clear_OP    =>
								cpu_spi_clear     <= data_we;              --address: FFF
							when others => NULL;
						end case;
					when '0' =>
						case(data_addr(1)) is
							when '0' => --sleep control address space
								sleep_we <= data_we;
							
							when '1' => --timer address space
								case (data_addr(0)) is
									when '0' =>
										mem_data_n <= timer(31 downto 0);
									when '1' =>
										mem_data_n <= timer(63 downto 32);
									when others =>
										null;
								end case;
							when others =>
								null;
						end case;
					when others =>
						null;
					end case;
			when others =>
				null;
		end case;
	end process;   
	
	sleep_controller : entity work.sleep_controller port map(
		clk          => d_clk,
		nreset       => sync_reset,
		data         => cpu_data_data_w, 
		we           => sleep_we,
		spi_finished => spi_finished,
		spi_busy     => spi_busy,
		sleep_type   => sleep_type,
		sleep        => sleep_ctl
		);
	time_module : entity work.timer port map(
		clk => d_clk,
		timer => timer,
		nreset => sync_reset
		);
	
	
	
	spi_controller : entity work.SPI_controller port map(
		clk        => d_clk,
		nreset     => sync_reset,
		request    => spi_settings,
		data_in    => data_to_spi,
		data_out   => spi_data_out,
		
		busy       => spi_busy,
		finished   => spi_finished,
		clear      => spi_clear,
		start      => spi_start,
		
		--SPI interface
		miso       => miso,
		mosi       => mosi,
		sclk       => sclk,
		cs1        => cs1,
		cs2        => cs2,
		cs3        => cs3,
		cs4        => cs4
		);
	
	startup_controller : entity work.spi_startup port map(
		clk        => d_clk,
		nreset     => sync_reset, 
		skip_startup => skip_startup,

		--SPI controller interface--
		data_to_spi => startup_spi_data_in,
		data_from_spi => startup_spi_data_out,
		spi_finished => startup_spi_finished,
		spi_start => startup_spi_start,
		spi_clear => startup_spi_clear,
		spi_settings => startup_spi_settings,
		
		
		--Memory interface--
		data_mem => startup_data_mem,
		address  => startup_address,
		instr_we => startup_instr_we,	
		data_we  => startup_data_we,
		
		done     => startup_done
		
		);
	
	
	--sleep_controller : entity work.sleep_controller port map(
	--clk => d_clk,
	
	--);
	
		
	instruction_memory : entity work.instr_mem_wrap generic map(
		address_width => INSTRUCTION_MEM_WIDTH)
	port map(
		d_clk => d_clk,
		clk   => clk,
		reset_pulse_generator => sync_reset,
		write_en  => instr_we,
		Address   =>  instr_addr,
		write_data_input  => instr_data_w,
		read_data => instr_data_r,
		idle => instr_idle,
		--rerouting for no startup--
		reroute_write_en => instr_mem_write_en,
		reroute_Address  => instr_mem_Address,
		reroute_write_data_input => instr_mem_write_data_input,
		reroute_read_data => instr_mem_read_data,
		reroute_reset_pulse_generator => instr_mem_reset_pulse_generator,
		reroute_idle => instr_mem_idle
		);	
	
	data_memory : entity work.data_mem_wrap generic map(
		address_width => INSTRUCTION_MEM_WIDTH)
	port map(
		d_clk => d_clk,
		clk   => clk,
		be    => data_be,
		reset_pulse_generator => sync_reset,
		write_en  => data_mem_we,
		Address   =>  data_addr(DATA_MEM_WIDTH - 1 downto 0),
		write_data_input  => data_data_w,
		read_data => data_mem_data_r,
		idle => data_idle,
		--rerouting for no startup--
		reroute_write_en => data_mem_write_en,
		reroute_Address  => data_mem_Address,
		reroute_write_data_input => data_mem_write_data_input,
		reroute_read_data => data_mem_read_data,
		reroute_reset_pulse_generator => data_mem_reset_pulse_generator,
		reroute_idle => data_mem_idle
		);
	
	
	AAsmund_RISC : entity work.top_pg_wrap	port map
		(
		clk => d_clk,
		nreset => sync_reset,
		
		sleep => cpu_sleep,
		
		--test interface
		pass  => pass_i,
		fail  => fail_i,
		
		--data memory interface
		data_memory_address      => cpu_data_addr,
		data_memory_read_data    =>	data_data_r, 
		data_memory_be           =>	cpu_data_be,
		data_memory_write_data   => cpu_data_data_w,
		data_memory_write_enable => cpu_data_we,
		data_memory_read_enable => cpu_data_re,
		
		--instruction memory interface
		inst_memory_address => cpu_instr_addr,
		inst_memory_read_data => instr_data_r,
		inst_memory_write_enable => cpu_instr_we
		);
	
	cpu_instr_data_w <= x"00000000";
	
	cpu_instr_re <= '1'; --TODO: Implement read enable signal	 
	
	--pragma synthesis_off
	process(d_clk)
	begin
		if(d_clk = '1' and d_clk'event) then
			if(sync_reset = '0') then
				sleep_cnt <= 0;
				awake_cnt <= 0;
				dmem_read_cnt <= 0;
				dmem_write_cnt <= 0;
				dmem_idle_cnt <= 0;
			else
				if(cpu_data_re = '1') then
					dmem_read_cnt <= dmem_read_cnt + 1;
				elsif(cpu_data_we = '1') then
					dmem_write_cnt <= dmem_write_cnt + 1;
				else
					dmem_idle_cnt <= dmem_idle_cnt + 1;
				end if;
				if(cpu_sleep = '1') then
					sleep_cnt <= sleep_cnt + 1;
				else
					awake_cnt <= awake_cnt + 1;	
				end if;
			end if;
		end if;
			
	end process;
	
	--pragma synthesis_on
end behave;
