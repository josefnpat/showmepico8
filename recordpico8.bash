#!/bin/bash

# The pico8 hardcoded gif name
gifoutput=PICO-8_0.gif
# The pico8 hardcoded cart path
cartpath=carts
# The temp filenamed to build the cart from body
tmpcart=showmepico8.p8
# The location of the header/footer
header=header.p8
footer=footer.p8

# http://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# parse yaml data
eval $(parse_yaml config.yml "c_")

# clean up old output
rm -f $c_record_output

mkdir -p $c_tmpdir/$cartpath

# build the cart
cat $header > $c_tmpdir/$cartpath/$tmpcart
cat $c_record_input >> $c_tmpdir/$cartpath/$tmpcart
cat $footer >> $c_tmpdir/$cartpath/$tmpcart

# backup that gif in case it exists
mv $c_pico8gifoutputdir/$gifoutput $c_pico8gifoutputdir/$gifoutput.bak 2>/dev/null

echo "Running and recording pico8"

#run and own pico8
$c_pico -gif_scale 4 -windowed 1 -run $c_tmpdir/$cartpath/$tmpcart -home $c_tmpdir &

# get the process pid
last_pid=$!
# never liked you anyway
disown

# wait for the game to load; a flag would be nice zep ... ;)
sleep 4.5
# start recording ala' p8 style (flag?)
xdotool key F8
# wait for stuff to happen
sleep 8
# stop recording ala' p8 style (flag?)
xdotool key F9
# wait for recording to save
sleep 1
# goodbye pico8, hope you did your job!
kill -KILL $last_pid

echo "Converting GIF with imagemagick"

# convert gif to twitter happy image
# thanks @gamax92 for flags
convert $c_pico8gifoutputdir/$gifoutput -background black -gravity Center -extent 560x560 -layers Optimize $c_record_output

# get rid of temp pico8 output
rm -f $c_pico8gifoutputdir/$gifoutput

echo "Done"
