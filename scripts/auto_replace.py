import re
import os
from os.path import join, getsize

replace_map = {}
input_file = open("variables.txt", "r")

for line in input_file:
	if(re.match("\s*(\S+),\s*(\S+)\s*", line)):
		match = re.match("\s*(\S+),\s*(\S+)\s*", line)
		replace_map[match.group(1)] = match.group(2)


for root, dirs, files in os.walk("../modules"):
	print root, dirs, files