#!/bin/bash

OUTPUT="/home/aurelien/Documents/Audrey/git_book/index.html"

# Generate menu
menu_file="/home/aurelien/Documents/Audrey/git_book/index_builder/site-index.html"

rm -f $menu_file

/home/aurelien/Documents/Audrey/git_book/index_builder/make_tree.sh \
-r /home/aurelien/Documents/Audrey/git_analysis \
-o $menu_file \
-i "/libs/|/pipeline_info/|/SCENIC/"

# Generate index
cat ./index_builder/index_top.html > $OUTPUT
sed -i -e '$a\' $OUTPUT
cat $menu_file >> $OUTPUT
sed -i -e '$a\' $OUTPUT
cat ./index_builder/index_bottom.html >> $OUTPUT
