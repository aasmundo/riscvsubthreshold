database -open -shm -into ncsim.shm waves -default
probe -create -shm :A :B :operation -waveform
run 
