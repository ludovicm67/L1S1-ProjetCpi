#!/bin/bash

# we need a file with raw data to graph
if [ "$#" -ne "1" ]
then
    echo "Usage: ./$0 raw-data-file" 1>&2
    exit 1
fi

# the first arg is the filename
f=$1

# the image will be named like the raw data filename with ".png" to the end
img=$1.png

gnuplot << EOF
set grid
set xlabel "Taille du fichier (o)"
set ylabel "Vitesse de calcul (secondes)"
set title "Recherche de lignes identiques dans deux fichiers"

plot \
    "${f}" using 1:2 with linespoints lt 1 title "Solution simple",\
    "${f}" using 1:3 with linespoints lt 2 title "Solution optimisée"
set terminal png
set output "${img}"
replot
EOF
