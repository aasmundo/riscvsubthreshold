rm -r INCA_libs/
irun -clean -compile -mess /eda/tools/cadence/incisive.15.10.008/tools.lnx86/affirma_ams/etc/vhdlams_connectlib_samples/*.vhms
irun -ultrasim_args +mt=12 -amsfastspice -access +r -v93 -top soc_top_tb_no_startup -mess MODULES_FOLDERconstants.vhdl MODULES_FOLDERinstr_mem_sram_model.vhd MODULES_FOLDERdata_mem_sram_model.vhd soc_top_tb_no_startup.vhd /eda/tools/cadence/incisive.15.10.008/tools.lnx86/affirma_ams/etc/vhdlams_connectlib_samples/*.vhms amsd.scs -input run2.tcl -run | tee deleteme.tmp
