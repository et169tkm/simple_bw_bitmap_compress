#!/bin/bash

# Usage: bash compress.bash <infile>
# the output is printed to stdout (user readable info is printed to stderr)

# Use 8 bit pixel numbers, the maximum number stored in 8 bit is 255.
m=255
# In the 8 bit case, 2 hex digits are required to represent a number.
printf_pattern="%02x"

# read argv[1]
input_file_name=$1

function printpixel() {
    printf "$printf_pattern" $1 | xxd -r -p
    #printf "$printf_pattern(%d)\n" $1 $1 # debug, print decimal number
}

overflow_count=0
# What the following chained command (in the "in" clause)  does:
# 1. read the image file, take only the red channel (8-bit/1byte), spit out the pixel values in binary bytes
# 2. convert it to hex
# 3. remove new line chars
# 4. convert to lines of 2 hex digits
# 5. count continous duplicate lines
# 6. print only the count
for c in `convert "$input_file_name" -depth 8 r:- | xxd -p | tr -d '\n' | fold -w 2 | uniq -c | awk '{print $1}'`; do
    while [ "$c" -gt $m ]; do
        printpixel $m
        printpixel 0
        c=$(( c-m ))
        overflow_count=$(( overflow_count+1 ))
    done
    printpixel $c
done
echo "Overflow count: $overflow_count" >&2

