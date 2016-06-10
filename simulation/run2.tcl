database -open -shm -into ncsim.shm waves -default
probe -create -shm :pass :fail :clk :d_clk_out -waveform
run 
