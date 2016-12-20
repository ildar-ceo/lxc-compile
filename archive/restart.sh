#!/bin/bash

sleep_echo(){
	if [ -z "$1" ]; then
		return 0
	fi
	let ret=0
	TIMEOUT=$1
	echo "sleep $TIMEOUT sec"
	while [ $TIMEOUT -gt 0 ]; do
		let mod=$TIMEOUT%5
		if [ "$mod" == "0" ]; then
			echo -n $TIMEOUT
		fi
		echo -n "."
		sleep 1
		let TIMEOUT=${TIMEOUT}-1
	done
	echo "Wait done."
}

lxc stop-all
echo "System will reboot after 10 sec"
sleep_echo 10
echo "Reboot."
init 6
