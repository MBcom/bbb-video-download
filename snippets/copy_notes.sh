#!/bin/bash

# Call with <meeting id> and run with BBB user

if [ -f /var/bigbluebutton/recording/raw/$1/notes/notes.pdf ]; then
	if [ -d /var/bigbluebutton/published/presentation/$1 ]; then
		cp /var/bigbluebutton/recording/raw/$1/notes/notes.pdf /var/bigbluebutton/published/presentation/$1/
	fi
fi
