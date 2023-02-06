#!/bin/bash

#====================== GET OPTIONS

#-------- Error if not 3 options
if [ $# -ne 6 ]; then
    echo "Please specify 3 command line arguments :"
    echo "-r is the root directory to make tree on"
    echo "-o is the output file names, with full path"
    echo "-i is a regular expression with pattern to ignore in the tree"
		exit 1
fi

#-------- Get option
#ROOT="/home/aurelien/Documents/Audrey/git_analysis"
#OUTPUT="/home/aurelien/Documents/Audrey/git_book/index_builder/site-index.html"
#IGNORE="/libs/|/pipeline_info/|/SCENIC/"

while getopts r:o:i: flag
do
    case "${flag}" in
        r) ROOT=${OPTARG};;
        o) OUTPUT=${OPTARG};;
        i) IGNORE=${OPTARG};;
    esac
done

#====================== BUILD TREE

# Also a nice option :
#tree -f | grep '\.html$' | grep -v $IGNORE


echo "<ul>" > $OUTPUT

first_dir=""
nested_parent=""
nested_level=0

for one_file in `find $ROOT -iname "*html" -type f | grep -Ev $IGNORE | sort`; do
  # Remove $ROOT in full path
  one_file=${one_file#"$ROOT/"}

  # Get first directory
  #next_dir=`echo $one_file | cut -d '/' -f 1`
  next_dir=`echo ${one_file%/*}`

  if [[ $next_dir != $first_dir && $next_dir != $one_file ]]; then
    # New directory
    if [[ $first_dir != "" ]]; then
      # Previous is not the root
      if [[ $next_dir == "$first_dir/"* ]]; then
        # nextdir/ = /firstdir/.../
        # New nested directory (new dir contains first dir) 
        nested_level=$(($nested_level + 1))
      else
        # Fully new directory
        # Close nested lists
        while [ $nested_level -gt 0 ]; do
          echo "</ul>" >> $OUTPUT
          nested_level=$(($nested_level - 1))
        done
        # Close list and open new
        echo "</ul>" >> $OUTPUT
      fi
    fi

    # Add new directory
    echo "<li>$next_dir</li>" >> $OUTPUT
    echo "<ul>" >> $OUTPUT

    first_dir=$next_dir
  fi

  # Print file
  only_file=${one_file##*/}
  only_file=${only_file%.*}
  echo "<li><button id='$ROOT/$one_file' class='ulli_button' onClick=\"changeIframe('$ROOT/$one_file')\">$only_file</button></li>" >> $OUTPUT

done

# Close nested lists
while [ $nested_level -gt 0 ]; do
  echo "</ul>" >> $OUTPUT
  nested_level=$(($nested_level - 1))
done

echo "</ul>" >> $OUTPUT
echo "</ul>" >> $OUTPUT

#cat $OUTPUT