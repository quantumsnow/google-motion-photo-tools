#!/bin/bash

function merge() {
	# check if file is a live photo
	imageid=$(exiftool -s -s -s -m -MediaGroupUUID "$1")
	if [[ "$imageid" == "" ]]
	then
		return
	fi
	
	# try to find matching video file
	for ext in 'mp4' 'MP4' 'mov' 'MOV'
	do
		vid=$(echo $1 | sed -r "s/\.[^\.]+$/.$ext/")
		if [[ -f "$vid" ]] && [[ $(exiftool -s -s -s -m -ContentIdentifier "$vid") == "$imageid" ]]
		then
			foundvid=1
			break
		fi
	done
	
	if [[ $foundvid != 1 ]]
	then
		return
	fi
	
	mime_type=$(file --mime-type -b "$1")
	filename=$(basename "$1")
	filedir=$(echo "$1" | sed -r 's/\/[^\/]+$//' | sed 's/^\.?\///') # extract path from file pointer and remove leading './' or '/'
	destdir="$2/$filedir"
	mkdir -p "$destdir"
	
	# if input file is already a jpeg we just need to copy it, otherwise we need to convert it
	if [[ "$mime_type" == "image/jpeg" ]]
	then
		destfile="$destdir/$filename"
		cat "$1" > "$destfile"
	else
		destfile="$destdir/$(echo $filename | sed -r 's/\.[^\.]+$/.jpg/')"
		convert "$1" "$destfile"
	fi
	
	# append video
	cat "$vid" >> "$destfile"

	# write motion metadata
	exiv2 -m exiv2-mopho-xmp.txt "$destfile"
}

# if input is a single file merge it, otherwise find all find all files contained in input and merge all of them
if [[ -f "$1" ]]
then
	merge "$1" "$2"
else
	export -f merge
	
	find "$1" -type f -exec bash -c 'echo "$0"; merge "$0" "$1"' '{}' "$2" \;
fi

