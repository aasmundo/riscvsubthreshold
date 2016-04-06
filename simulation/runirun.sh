rm -r INCA_libs/
irun -clean -compile -mess /eda/tools/cadence/incisive.15.10.008/tools.lnx86/affirma_ams/etc/vhdlams_connectlib_samples/*.vhms
irun -ultrasim_args +mt=12 -amsfastspice -access +r -v93 -gui -top alu_testbench -mess ../modules/constants.vhdl alu_testbench.vhd /eda/tools/cadence/incisive.15.10.008/tools.lnx86/affirma_ams/etc/vhdlams_connectlib_samples/*.vhms amsd.scs -input run2.tcl -run | tee deleteme.tmp
