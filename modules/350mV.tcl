# Set parameter units
#set_units -time ns
#set_operating_conditions worst
#
set TOPLEVEL  "soc_top"
set link_library  "~/S28_coreLVTPB4_AFBB_ecsm_350mV.db"
set search_path ~/
set target_library "~/S28_coreLVTPB4_AFBB_ecsm_350mV.db"
set fileFormat vhdl

set_host_options -max_cores 12
supress_message "UCN-1"
supress_message "ELAB-311"
supress_message "VHD-4"
supress_message "ELAB-943"

read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_decode/register_file.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_fetch/branch_predictor.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_decode/control.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/constants.vhdl"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/memory/bram.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/memory/SP_32bit.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/sleep_controller.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/timer.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/clock_divider.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/write_back/clock_counter.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/spi_startup.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/SPI_top3.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/SPI_controller.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/activity_control.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/execute/ALU/alu.vhdl"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/execute/forwarder.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/execute/execute.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_decode/hazard_detector.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_decode/imm_ext.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_fetch/branch_target_adder.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_fetch/PC/PC_increment.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_fetch/PC/PC.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/memory/branch_control.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/pipeline_registers/EXMEM_preg.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/pipeline_registers/IFID_preg.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/write_back/write_back.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/pipeline_registers/MEMWB_preg.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/pipeline_registers/IDEX_preg.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/memory/memory.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_decode/instruction_decode.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_fetch/instruction_fetch.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/instruction_fetch/two_level_bp.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/top.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/clock_divider_cnt.vhd"
read_vhdl "~/newWorkdir/riscvsubthreshold/modules/soc_top.vhd"
read_sdc "~/riscvsubthreshold/constraints.sdc"

current_design soc_top

#create_clock -name $CLK -period 1000.0 -waveform {0 500} [get_ports clk]
set high_fanout_net_threshold 10000
uniquify
change_names -rules verilog -hierarchy

compile

check_design

all_high_fanout -nets
write -f verilog -o soc_top_old_2.v -hierarchy 


