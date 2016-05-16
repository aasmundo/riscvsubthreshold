import os
import math
from subprocess import call

print "How many tests?"
tests = int(raw_input())
print "How many concurrent simulations?"
concurrent = int(raw_input())

tests_per_sim = int(round(float(tests) / concurrent))
simulations = []
testnum = 0
for i in range(0,concurrent):
    tests_per_sim = int(round(float(tests - testnum) / (concurrent - i)))
    simulations.append([testnum, testnum + tests_per_sim - 1])
    testnum += tests_per_sim
simulations[-1][1] = tests - 1

current_dir = os.getcwd()
hex_tests_path = current_dir + "/newTests/"
hex_tests_path = "\\\"" + hex_tests_path.replace("/", "\/") + "\\\""
modules_folder = current_dir + "/modules/"
modules_folder = modules_folder.replace("/", "\/")

if(os.path.isdir("concurrent_sim")):
    call(["rm", "-r", "concurrent_sim"])
call(["mkdir", "concurrent_sim"])
f = open("runall", "w")
for i in range(0, concurrent):
    begin_test = str(simulations[i][0])
    last_test  = str(simulations[i][1])
    os.makedirs("concurrent_sim/" + str(i) + "/")
    call(["cp", "-Lr", "simulation/", "concurrent_sim/" + str(i) + "/"])
    os.chdir("concurrent_sim/" + str(i) + "/")
    call(["find ./ -type f -exec sed -i -e 's/TEST_FOLDER/" + str(hex_tests_path) + "/g' {} \;"], shell=True)
    call(["find ./ -type f -exec sed -i -e 's/MODULES_FOLDER/" + str(modules_folder) + "/g' {} \;"], shell=True)
    call(["find ./ -type f -exec sed -i -e 's/BEGIN_TEST/" + str(begin_test) + "/g' {} \;"], shell=True)
    call(["find ./ -type f -exec sed -i -e 's/LAST_TEST/" + str(last_test) + "/g' {} \;"], shell=True)
    call(["find ./ -type f -exec sed -i -e 's/NUM_OF_TESTS/" + str(int(math.ceil(float(tests + 1) / concurrent))) + "/g' {} \;"], shell=True)
    os.chdir("../..") 
    f.write("cd concurrent_sim/" + str(i) + "/simulation/ \n")
    f.write("./runirun.sh -parameters &  \n")
    f.write("cd ../../.. \n")
f.close()
call(["chmod +x runall"],  shell=True)
call(["./runall"], shell=True)



