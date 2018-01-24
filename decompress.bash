#!/bin/bash

# Usage: bash decompress.bash <infile> <width> <height> <outfile>

# assuming 8-bit numbers, 2 hex digits = one number
hex_digit_per_pixel=2

input_file_name=$1
width=$2
height=$3
output_file_name=$4

image_r8_hex='' # buffer to store rgba data of the image in hex format
color1='FF'
color2='00'
next_pixel=$color1
# What the following command chain does:
# 1. print the input file as hex
# 2. format it as one pixel per line (e.g. 8bit image = 2 hex digits)
# 3. convert it to upper case (so bc can read it)
for hex_val in `xxd -p "$input_file_name" | fold -w "$hex_digit_per_pixel" | tr '[:lower:]' '[:upper:]'`; do
    # convert the hex_val to number using bc
    c=`echo "ibase=16; $hex_val" | bc`
    if [ $c -ge 1 ]; then
        # print the rgb value a pixel in hex format
        buf=`printf '%'"$c"'s' | sed "s/ /$next_pixel$next_pixel$next_pixel/g"`
        # append to current image buffer
        image_r8_hex=$image_r8_hex$buf
    fi
    # switch to another colour
    if [ "$next_pixel" = "$color1" ]; then
        next_pixel="$color2"
    else
        next_pixel="$color1"
    fi
done
echo -n "$image_r8_hex" | xxd -p -r | convert -size "$width"x"$height" -depth 8 rgb:- "$output_file_name"

