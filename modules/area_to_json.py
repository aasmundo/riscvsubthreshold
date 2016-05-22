
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


html = ["""<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.0.0-beta1/jquery.js"></script>
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/heatmap.js"></script>
<script src="https://code.highcharts.com/modules/treemap.js"></script>
<div id="container"></div>

<script>
$(function() {
  var data = """, """,
    points = [],
    regionP,
    regionVal,
    regionI = 0,
    countryP,
    countryI,
    causeP,
    causeI,
    region,
    country,
    cause,
    causeName = {
      'LVT_invx2_PB4_AFBB': 'inverter2x',
      'LVT_invx1_PB4_AFBB': 'inverter1x',
      'LVT_NADN2x1_PB4_AFBB': 'nand',
      'LVT_NOR2x1_PB4_AFBB': 'nor',
      'LVT_FAx1_PB4_AFBB': 'full adder',
      'LVT_RFDFFx1_PB4_AFBB': 'flip flop',
      'LVT_BUFx1_PB4_AFBB': 'buffer',
      'LVT_NADN2x1_PB4_AFBB': 'nand',
      'LVT_RFDFFSx1_PB4_AFBB': 'flip flop w. reset'
    };
  // This function handles arrays and objects
  function getRandomColor() {
    var letters = '0123456789ABCDEF'.split('');
    var color = '#';
    for (var i = 0; i < 6; i++) {
      color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
  }

  function color_change(color) {
    var letters = '0123456789ABCDEF'.split('');
    var new_color = "#";
    var old_letter = 0;
    for (var i = 1; i < 7; i++) {
      for (var j = 0; j < letters.length; j++) {
        if (color[i] == letters[j]) {
          old_letter = j;
        }
      }
      old_letter = old_letter + Math.floor((Math.random() * 5) - 2.5)
      if (old_letter > (letters.length - 1)) {
        old_letter = letters.length - 1;
      } else if (old_letter < 0) {
        old_letter = 0;
      }
      new_color += letters[old_letter];
    }
    return new_color;
  }

  function eachRecursive(obj, parent, name, color) {
    if (color == "nocolor" || parent == "none_top") {
      color = getRandomColor()
    }

    var subcktP = {
      id: parent + "_" + name,
      name: name,
      value: 0,
      color: color_change(color)
    };
    if (parent != "none") {
      subcktP.parent = parent;
    }
    for (var k in obj) {
      if (typeof obj[k] == "object" && obj[k] !== null && String(k) != "this") {
        //console.log(k, parent + "_" + k)
        subcktP.value += eachRecursive(obj[k], subcktP.id, k, color);
      } else {
        if (String(k) == "this") {
          var this_greie = {
            parent: subcktP.id,
            id: subcktP.id + "_" + k,
            value: 0,
            name: "this",
            color: color_change(color)
          }
          var cellP = {}
          for (var i in obj[k]) {
            cellP = {
              id: subcktP.id + "_" + k + "_" + i,
              name: causeName[i],
              parent: subcktP.id + "_" + k,
              value: obj[k][i],
              color: color_change(color)
            };
            subcktP.value += obj[k][i];
            this_greie.value += obj[k][i];
            points.push(cellP);
          }
          points.push(this_greie);
        }
      }
    }
    //console.log(subcktP)
    points.push(subcktP);
    return subcktP.value
  }
  eachRecursive(data, "none", "top", getRandomColor())
  $('#container').highcharts({
    series: [{
      type: 'treemap',
      layoutAlgorithm: 'squarified',
      allowDrillToNode: true,
      dataLabels: {
        enabled: false
      },
      levelIsConstant: false,
      levels: [{
        level: 1,
        dataLabels: {
          enabled: true
        },
        borderWidth: 3
      }],
      data: points
    }],
    subtitle: {
      text: 'Click points to drill down.'
    },
    title: {
      text: 'Area in um^2'
    }
  });
});

 </script>

<style>#container {
  min-width: 100%;
  max-width: 900px;
  min-height: 800px;
  margin: 0 auto;
}
 </style>"""]



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
area_dict = {subckt_list[-1] : area_dict[subckt_list[-1]]}
number_dict = {subckt_list[-1] : number_dict[subckt_list[-1]]}
with open('area.html', 'w') as fp:
  fp.write(html[0])
  json.dump(area_dict, fp)
  fp.write(html[1])
with open('cell_count.html', 'w') as fp:
  fp.write(html[0])
  json.dump(number_dict, fp)
  fp.write(html[1])

print "json dumped"

if(current_subckt != ""):
  sys.exit("Last subckt not ended: " + current_subckt)


