#!/bin/bash

PREFIX='sugarcct'
ls $PREFIX*.png | sed s/$PREFIX[0-9]*-//g | sort -u | while read i
do
    echo $i
    IMG1=$PREFIX'15-'$i
    IMG2=$PREFIX'30-'$i
    IMG3='diff-'$i
    echo $IMG3
    convert -background white $IMG1 $IMG2 -append $IMG3
done

