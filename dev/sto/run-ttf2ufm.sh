#!/bin/bash

FFILE=DejaVuSerif.ttf
PROG=ttf2ufm

if [[ -z "$1" ]]; then
    echo "Usage: $0 "
    echo
    echo "Runs '$PROG' ops on ttf file '$FFILE'"
    exit
fi

# options:
# --pfb  # produce a .pfb file instead of a t1a
#       
#   -G 
#      u # don't produce the .ufm file (saves 45Mb)
#      f # don't produce the .t1a file (saves 171Kb)
$PROG --pfb -G u $FFILE
$PROG       -G u $FFILE


