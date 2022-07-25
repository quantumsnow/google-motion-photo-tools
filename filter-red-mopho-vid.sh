#!/bin/bash

filter_file() {
	# check if file is motion photo
	ismopho=$(exiftool -s -s -s -m -MicroVideo -MotionPhoto "$1")
	
	if [[ $ismopho != 1 ]]
	then
		echo "not mopho"
		return
	fi

	# try to find matching video file
	for ext in '.mp4' '.MP4' ''
	do
		vid=$(echo $1 | sed -r "s/\.[^\.]+$/$ext/")
		if [[ -f "$vid" ]] && [[ "$(file --mime-type -b "$vid")" == "video/mp4" ]]
		then
			foundvid=1
			break
		fi
	done
	
	if [[ $foundvid != 1 ]]
	then
		echo "found no vid"
		return
	fi
	
	filedir=$(echo "$1" | sed -r 's/\/[^\/]+$//' | sed 's/^\.?\///') # extract path from file pointer and remove leading './' or '/'
	destdir="$2/$filedir"
	mkdir -p "$destdir"
	mv "$vid" "$destdir/"
}

export -f filter_file

find "$1" -type f -exec bash -c 'echo "$0"; filter_file "$0" "$1"' '{}' "$2" \;

