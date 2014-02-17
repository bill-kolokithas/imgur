#!/bin/bash

function uploadImage {
	curl -s -F "image=@$1" -H 'Authorization: Client-ID c3d5102cafbba4c' https://api.imgur.com/3/upload.xml | grep -E -o "<link>(.)*</link>" | grep -E -o "http://i.imgur.com/[^<]*"
}

if [ "$#" -ne 1 ]; then
	notify-send "Upload error"
else
	uploadImage $1 | xclip -selection c
	notify-send "Upload complete"
fi
