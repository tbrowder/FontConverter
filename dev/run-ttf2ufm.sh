#!/bin/bash

#FFILE=fonts/DejaVuSerif.ttf
FFILE=N.ttf
PROG=ttf2ufm

if [[ -z "$1" ]]; then
    echo "Usage: $0 "
    echo
    echo "Runs '$PROG' ops on ttf file '$FFILE'"
    exit
fi

# options:
# --pfb  # produce a .pfb file
#   -G 
#      u # don't produce the .ufm file (saves 45Mb)
#      f # don't produce the .t1a file (saves 171Kb)
$PROG --pfb -G u $FFILE
$PROG       -G u $FFILE


