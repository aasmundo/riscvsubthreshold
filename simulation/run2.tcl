database -open -shm -into ncsim.shm waves -default
probe -create -shm :clk :nreset :sclk :mosi :miso :pass :fail :cs1 :cs2 :cs3 :cs3 :cs4  -waveform
run 
