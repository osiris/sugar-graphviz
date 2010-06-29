#!/bin/bash

files="copyright README INSTALL LEEME INSTALAR"
for f in $files
do
    echo $f
    rst2pdf $f -o ./doc/$f.pdf
done

