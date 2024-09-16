#!/bin/bash

#====================== GET OPTIONS
# Goal: replicate the directory tree containing only html files

#-------- Get option
# INPUT:  input directory (full path)
# OUTPUT: output directory (full path)
# WITH: folder in the input directory to include in the output directory (relative path)

while getopts i:o:w: flag
do
    case "${flag}" in
        i) INPUT=${OPTARG};;
        o) OUTPUT=${OPTARG};;
        w) WITH=${OPTARG};;
    esac
done

#====================== BUILD INDEX PAGE

mkdir -p $OUTPUT

for full_name in $(find $INPUT -name "*html" -type f)
do
    # INPUT: /useless/interest

    # Get input directory simple name
    simple_input=$(basename $INPUT)      # interest


    # Split full name /useless/interest/A/B/C/toto.html
    dir_name=$(dirname ${full_name})     # /useless/interest/A/B/C/

    # Remove eventual . if the dir_name is ./toto/tata
    dir_name="${dir_name//.\///}"        # /toto/tata

    # Remove everything before simple_input
    dir_name=$(echo "${dir_name#*$simple_input}")   # /A/B/C/

    # Create directory
    mkdir -p $OUTPUT/$dir_name/

    # Copy file
    cp $full_name $OUTPUT/$dir_name/
done

# Copy the wanted folder
if [ -n "$WITH" ]
then
    echo "$INPUT/$WITH"
    echo "$OUTPUT/$WITH"
    mkdir -p $OUTPUT/$WITH
    cp -r $INPUT/$WITH/* $OUTPUT/$WITH
fi