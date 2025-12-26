#!/bin/bash
# Usage: compile.sh <exercise.s> <output> [gcc|c_file.c]
set -e
E="$1" O="$2" M="$3"
if [ -z "$M" ]; then as --64 -o "$O.o" "$E" && ld -o "$O" "$O.o" && rm -f "$O.o"
elif [ "$M" = "gcc" ]; then gcc -o "$O" "$E"
else gcc -o "$O" "$M" "$E"; fi
