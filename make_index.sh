#!/bin/bash

#====================== GET OPTIONS

#-------- Get option
MAKER="."                                     # index maker directory
ROOT="./"                                     # directory to make the index.html for
MENU="./site-index.html"                      # intermediate html file containing the menu (generated with make_tree.sh)
IGNORE="/libs/|/index_layout/|index.html"     # elements to ignore while making the menu
OUTPUT="./index.html"                         # output (index.html by default)

while getopts b:r:m:i:o: flag
do
    case "${flag}" in
        b) MAKER=${OPTARG};;
        r) ROOT=${OPTARG};;
        m) MENU=${OPTARG};;
        i) IGNORE=${OPTARG};;
        o) OUTPUT=${OPTARG};;
    esac
done

#====================== BUILD INDEX PAGE

# Remove trailing slash in root
ROOT=${ROOT%/}

# Make menu
$MAKER/index_builder/make_tree.sh \
-r $ROOT \
-o $MENU \
-i $IGNORE

# Generate index
cat $MAKER/index_builder/index_top.html > $OUTPUT
sed -i -e '$a\' $OUTPUT
cat $MENU >> $OUTPUT
sed -i -e '$a\' $OUTPUT
cat $MAKER/index_builder/index_bottom.html >> $OUTPUT

# Delete menu
rm -f $MENU

# Add index_layout folder in output directory
cp -r $MAKER/index_layout $ROOT/