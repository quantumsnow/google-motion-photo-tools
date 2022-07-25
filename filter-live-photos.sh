#!/bin/bash

filter_file() {
	# check if file is live photo
	fileid=$(exiftool -s -s -s -m -MediaGroupUUID -ContentIdentifier "$1")
	
	if [[ "$fileid" != "" ]]
	then
		filedir=$(echo "$1" | sed -r 's/\/[^\/]+$//' | sed 's/^\.?\///') # extract path from file pointer and remove leading './' or '/'
		destdir="$2/$filedir"
		mkdir -p "$destdir"
		mv "$1" "$destdir/"
	fi
}

export -f filter_file

find "$1" -type f -exec bash -c 'echo "$0"; filter_file "$0" "$1"' '{}' "$2" \;

