
#https://jsfiddle.net/2tbnpqLj/
import re
import sys
import json
filnavn = sys.argv
print filnavn
if(isinstance(filnavn, list)):
    if len(filnavn) != 2:
        sys.exit("check your arguments")
    filnavn = filnavn[1]
filnavn = str(filnavn)


with open("cellinfo.json", 'r') as f:
  cellinfo = json.load(f)


cell_regex = []
for celltype in cellinfo:
  cell_regex.append({"name" : celltype, "regex" : re.compile(".*" + celltype + ".*")})
new_subckt = re.compile("^subckt\s+(\S+)\s+.*$")
end_subckt = re.compile("^ends\s(\S+)\s*$")


#cell = re.compile(".*(LVT_[a-zA-Z0-9_]+).*")
comment = re.compile("^\s*//.*")
not_newline = re.compile("^(.*)\\\s*$")
subckts = {}
current_subckt = ""
subckt_list = []
multiline = ""
this_line = ""
with open(filnavn, 'r') as f:
   for line in f:
      this_line = line
      line = multiline + line
      if(comment.match(this_line)):
        multiline = ""
        continue
      elif(not_newline.match(this_line)):
        multiline = multiline + not_newline.match(this_line).group(1)
        continue
      elif(new_subckt.match(line)):
        if(current_subckt != ""):
          sys.exit("Subckt in another subckt: " + line)
        current_subckt = new_subckt.match(line).group(1)
        subckt_list.append(current_subckt)
        subckts[current_subckt] = {"regex" : re.compile(".*\)\s+" + current_subckt + "\s*$"), "name" : current_subckt, "cells" : [], "subckts" : []}
      elif(end_subckt.match(line)):
        if(current_subckt != end_subckt.match(line).group(1)):
          sys.exit("Exit subckt not matching current subckt")
        for celltype in cellinfo:
          if(celltype == current_subckt):
            del subckts[current_subckt]
            subckt_list.pop()
        current_subckt = ""
      else:
        for cell in cell_regex:
          if(cell["regex"].match(line)):
            subckts[current_subckt]["cells"].append({"name" : cell["name"], "info" : cellinfo[cell["name"]]})
            continue
        for subckt in subckts:
          if(subckts[subckt]["regex"].match(line)):
            subckts[current_subckt]["subckts"].append(subckt)
      multiline = ""
      #print line + "lineend"

print "parsing complete"

area_dict = {}
number_dict = {}
for subckt in subckts:
  area_dict[subckt] = {"this" : {}}
  number_dict[subckt] = {"this" : {}}
  for cell in subckts[subckt]["cells"]:
    if(cell["name"] in area_dict[subckt]["this"]):
      area_dict[subckt]["this"][cell["name"]] += cell["info"]["area"]
      number_dict[subckt]["this"][cell["name"]] += 1
    else:
      area_dict[subckt]["this"][cell["name"]] = cell["info"]["area"]
      number_dict[subckt]["this"][cell["name"]] = 1

print "area and count of cells complete"

for subckt in subckt_list:
  print subckt
  for i in subckts[subckt]["subckts"]:
    print "   " + i
    area_dict[subckt][i] = area_dict[i]
    number_dict[subckt][i] = number_dict[i]
print number_dict["instruction_fetch"]
area_dict = {subckt_list[-1] : area_dict[subckt_list[-1]]}
number_dict = {subckt_list[-1] : number_dict[subckt_list[-1]]}
with open('area.json', 'w') as fp:
    json.dump(area_dict, fp)
with open('cell_count.json', 'w') as fp:
  json.dump(number_dict, fp)

print "json dumped"

if(current_subckt != ""):
  sys.exit("Last subckt not ended: " + current_subckt)


