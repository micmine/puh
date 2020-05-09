#!/bin/bash

scriptname="${0%.*}"
scriptname="${scriptname##*/}"
pitlocation="/tmp/.$scriptname-"

plantumllocation="$HOME/tools/plantuml/plantuml.jar"
if [ -n "$PLANTUML_HOME" ];then
	plantumllocation="$PLANTUML_HOME/plantuml.jar"
fi
script=$0 #$(dirname "$0")/$(basename "$0")

render () {
	java -jar "$plantumllocation" "$1" &
}

startLive () {
	name="${1%.*}"
	name="${name##*/}"
	image="${1%.*}.png"
	find "$1" | entr -r "$script" -r "$1" &
	echo -n "$! " >> "$pitlocation$name"
	feh -Z -R 1 "$image" &
	echo -n "$! " >> "$pitlocation$name"
}

stopLive () {
	name="${1%.*}"
	name="${name##*/}"

	if [ -f "$pitlocation$name" ]; then
		kill $(cat "$pitlocation$name")
		rm "$pitlocation$name"
	else
		echo "This live preview not running"
	fi
}

helpinfo () {
	echo "plantuml helper"
	echo "usage: "
	echo "-r | render image"
	echo "-l | start live preview"
	echo "-s | stop live preview"
	echo "As a second padrameter use a plantuml file"
	echo "example:"
	echo "./puh.sh -l class.plantuml"
	echo "./puh.sh -s class.plantuml"
	echo "exit code:"
	echo "1 => plantuml not found"
	echo "2 => file not found"
}

if [ ! -f "$plantumllocation" ]; then
	echo "Could not found $plantumllocation!"
	exit 1
fi
if [ ! -z "$1" ] && [ ! -z "$2" ]; then
	if [ ! -f "$2" ]; then
		echo "File does not exist: $2"
		exit 2
	fi
	if [ "$1" == "-r" ]; then
		render "$2"
	elif [ "$1" == "-l" ]; then
		render "$2"
		startLive "$2"
	elif [ "$1" == "-s" ]; then
		stopLive "$2"
	else
		helpinfo
	fi
else
	helpinfo
fi
