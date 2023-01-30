#!/bin/bash

OUTPUT="/home/aurelien/Documents/Audrey/git_book/index.html"

# Generate menu
rm -f ./index_builder/site-index.html
/home/aurelien/Documents/Audrey/git_book/index_builder/make_tree.sh

# Generate index
cat ./index_builder/index_top.html > $OUTPUT
sed -i -e '$a\' $OUTPUT
cat ./index_builder/site-index.html >> $OUTPUT
sed -i -e '$a\' $OUTPUT
cat ./index_builder/index_bottom.html >> $OUTPUT
