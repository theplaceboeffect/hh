#!/bin/bash
### Requires pyharmony from http://github.com/petele/pyharmony

HH_CACHE=~/.hh.cache.json
HH_CONFIG=~/.harmonyhub.config
PYHARMONY_LIB=~/.lib/pyharmony

PYHARMONY_GIT_URL=https://github.com/theplaceboeffect/pyharmony.git

########################################
## Get the pyharmony library from petele
function get_pyharmony {
	if [ ! -d $PYHARMONY_LIB ]; then
		echo "pyharmony library not found in $PYHARMONY_LIB. Cloning from $PYHARMONY_GIT_URL"
		LIB=$(dirname $PYHARMONY_LIB)
		if [ ! -d $LIB ]; then mkdir -p $LIB; fi
		pushd $LIB > /dev/null
		git clone $PYHARMONY_GIT_URL
		popd > /dev/null
	fi
}

#################################################
## Define function to send command to harmony hub
function send_command {
	PYTHONPATH=$PYHARMONY_LIB python $PYHARMONY_LIB/harmony --loglevel CRITICAL\
									 --email $HARMONY_EMAIL --password $HARMONY_PASSWORD\
									 --harmony_ip  $HARMONY_IP --harmony_port 5222 $* ##2> /dev/null
}

#################################################
## Cache functions
function refresh_cache {
	send_command show_config > $HH_CACHE
}

function update_cache {
	## Update cache if older than 7 days.
	REFRESH_AFTER_EVERY_N_SECONDS=$(expr 60 \* 60 \* 24 \* 7)

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
		echo Refreshing cache 
		refresh_cache
	fi
}

#################################################
function read_config {
	if [ ! -f $HH_CONFIG ]; then
		echo Configuration file "$HH_CONFIG" not found. Created an empty one.
cat << EOF > $HH_CONFIG
HARMONY_EMAIL=enter your harmony email here
HARMONY_PASSWORD=enter the password
HARMONY_IP=xxx.xxx.xxx.xxx
HARMONY_PORT=5222
EOF

	else
		source $HH_CONFIG
	fi;

}

#################################################
## Read configuration
read_config
get_pyharmony
update_cache

## Run command
case $1 in
"help" | "h" | "")		### HELP
		grep '^".*)' $0
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
"off" )				### Turn off TV
		send_command start_activity -1
		;;
"on" )				### Turn on TV
		send_command --device_id 13304282 --command PowerOn
		;;
"py")				### Run generic pyharmony command
		shift
		if [ "$#" -eq 0 ]; then
			send_command -h
		else
			send_command $*
		fi
		;;
"info")		### Show available activities, devices and commands
		echo "---- Activities ---"
		jq -c '.activity[] | { "id":.id, "label":.label}' $HH_CACHE
		echo "---- Devices ---"
		jq -c '.device[] | { "id":.id, "label":.label}' $HH_CACHE
		;;
"install" )			### Remove libraries and cache
		ln -s $PWD/hh.sh ~/bin/hh
		;;
"uninstall" )			### Remove libraries and cache
		rm -frv $PYHARMONY_LIB ~/.hh.cache
		rm -f ~/bin/hh
		;;
$*)	## Pass command to harmony
		send_command $*
esac
