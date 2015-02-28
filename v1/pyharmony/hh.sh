#!/bin/bash

### Requires pyharmony from http://github.com/jterrace/pyharmony

HH_CACHE=~/.hh.cache

############################################

## Read configuration
source ~/.harmonyhub.config

## Define function to send command to harmony hub
function send_command {
	PYTHONPATH=. python harmony --loglevel ERROR --email $HARMONY_EMAIL --password $HARMONY_PASSWORD --harmony_ip  $HARMONY_IP --harmony_port 5222 $* 2> /dev/null
}

function refresh_cache {
	send_command show_config > $HH_CACHE
}


## Update cache if older than a day.
REFRESH_AFTER_EVERY_N_SECONDS=$(expr 60 \* 60 \* 24)

if [ ! -f $HH_CACHE ]; then
	DIFF=$REFRESH_AFTER_EVERY_N_SECONDS 
else
	#LINUX: HH_CACHE_LAST_MODIFIED=$(stat --format="%Y" $HH_CACHE)
	#MAC:
	HH_CACHE_LAST_MODIFIED=$(stat -f"%m" $HH_CACHE)
	NOW=$(date +%s)
	DIFF=$(expr $NOW - $HH_CACHE_LAST_MODIFIED)

fi

if [ $DIFF -ge $REFRESH_AFTER_EVERY_N_SECONDS -o ! -s $HH_CACHE  ]; then
	echo Refreshing cache after $REFRESH_AFTER_EVERY_N_SECONDS
	refresh_cache
fi

## Run command

case $1 in
"help" | "h" | "")		### HELP
		grep '^".*)' $0

		echo Available Activities
		jq -c '.activity[] | { "id":.id, "label":.label}' $HH_CACHE
		;;
"current" | "c" )		### Show current activity
		send_command show_current_activity | jq .label
		;;
"refresh_cache" | "rc" )	### Refresh command cache
		echo Refreshing cache
		refresh_cache
		;;
"atv" )				### Apple TV
		send_command start_activity 13198070
		;;
"mac" )				### macmini
		send_command start_activity 13198039
		;;
"ps4" )				### PS4
		send_command start_activity 13198079
		;;
"wiiu" )			### Wii U
		send_command start_activity 
		;;
"tv" | "xb1" )			### GAME - switch to XBox One & TV
		send_command start_activity 13197995
		;;
"off" )			### Turn off TV
		send_command start_activity -1
		;;
esac
