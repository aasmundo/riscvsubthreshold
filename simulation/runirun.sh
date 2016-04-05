rm -r INCA_libs/
irun -clean -compile -mess /eda/tools/cadence/incisive.15.10.008/tools.lnx86/affirma_ams/etc/vhdlams_connectlib_samples/*.vhms
irun -ultrasim_args +mt=12 -amsfastspice -access +r -v93 -top alu_testbench -gui -mess ../modules/constants.vhdl  amsd.scs alu_testbench.vhd -input run2.tcl -run | tee deleteme.tmp
