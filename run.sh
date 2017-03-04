#!/bin/sh
pico=/root/pico-8/pico8
cartpath=carts
workingdir=/root/.lexaloffle/pico-8
code=pico8code.p8
templateheader=header.p8
templatefooter=footer.p8
output=showmepico8.p8
gifoutputdir=/root/Desktop/
gifoutput=$gifoutputdir/PICO-8_0.gif
gifoutputim=$gifoutputdir/PICO-8_0_pad.gif
tmpcsv=/tmp/tweetcsv
tmpcsvparent=/tmp/tweetcsvparent
lasttweetidf=/root/.lasttweetid
lasttweetid=`cat $lasttweetidf`

t mentions -n 1 --csv | head -n2 > $tmpcsv

tweetid=`cut -d , -f 1 $tmpcsv | tail -1`
tweetuser=`cut -d , -f 3 $tmpcsv | tail -1`

if [ "$lasttweetid" = "$tweetid" ]
then
  #echo "Been there, done that. bailing out."
  exit
else
  echo "Oh my, this is new!"
fi

echo $tweetid > $lasttweetidf

`ruby lemtzas.rb $tweetid > $tmpcsvparent`

parenttweetid=`cat $tmpcsvparent | head -n1`
parenttweettext=`cat $tmpcsvparent | tail -n +2`

rm $gifoutputdir/*.gif
mkdir -p $workingdir/$cartpath
echo "$parenttweettext" > $workingdir/$cartpath/$code
cat $templateheader > $workingdir/$cartpath/$output
cat $workingdir/$cartpath/$code >> $workingdir/$cartpath/$output
cat $templatefooter >> $workingdir/$cartpath/$output

echo "Running and recording pico8"

$pico -gif_scale 4 -windowed 1 -run $workingdir/$cartpath/$output &
sleep 5.5
xdotool key F8
sleep 6
xdotool key F9
sleep 1
pkill -9 pico8

echo "Converting GIF with imagemagick"

convert $gifoutput -background black -gravity Center -extent 560x560 -layers Optimize $gifoutputim

echo "Responding to tweet"

t reply -a $tweetid -f "$gifoutputim" "pico8 🤘"

