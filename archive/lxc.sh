#!/bin/bash

DIR_BIN=/usr/bin

#export LD_LIBRARY_PATH="/usr/lib"

case "$1" in

attach)
	shift
	${DIR_BIN}/lxc-attach $@
	;;
	
autostart)
	shift
	${DIR_BIN}/lxc-autostart $@
	;;
	
cgroup)
	shift
	${DIR_BIN}/lxc-cgroup $@
	;;
	
checkconfig)
	shift
	${DIR_BIN}/lxc-checkconfig $@
	;;
	
checkpoint)
	shift
	${DIR_BIN}/lxc-checkpoint $@
	;;
	
clone)
	shift
	${DIR_BIN}/lxc-clone $@
	;;
	
config)
	shift
	${DIR_BIN}/lxc-config $@
	;;
	
console)
	shift
	${DIR_BIN}/lxc-console $@
	;;
	
create)
	shift
	${DIR_BIN}/lxc-create $@
	;;
	
destroy)
	shift
	${DIR_BIN}/lxc-destroy $@
	;;
	
device)
	shift
	${DIR_BIN}/lxc-device $@
	;;
	
execute)
	shift
	${DIR_BIN}/lxc-execute $@
	;;
	
freeze)
	shift
	${DIR_BIN}/lxc-freeze $@
	;;
	
info)
	shift
	${DIR_BIN}/lxc-info $@
	;;
	
ls)
	shift
	${DIR_BIN}/lxc-ls $@
	;;
	
monitor)
	shift
	${DIR_BIN}/lxc-monitor $@
	;;
	
snapshot)
	shift
	${DIR_BIN}/lxc-snapshot $@
	;;
	
start)
	shift
	${DIR_BIN}/lxc-start $@
	;;
	
stop)
	shift
	${DIR_BIN}/lxc-stop $@
	;;

stop-all)
	for name in `${DIR_BIN}/lxc-ls`
	do
		echo "Stop lxc $name"
		${DIR_BIN}/lxc-stop --name $name
		#echo $name
	done
	
	#shift
	#${DIR_BIN}/lxc-stop $@
	;;
	
top)
	shift
	${DIR_BIN}/lxc-top $@
	;;
	
unfreeze)
	shift
	${DIR_BIN}/lxc-unfreeze $@
	;;
	
unshare)
	shift
	${DIR_BIN}/lxc-unshare $@
	;;
	
usernsexec)
	shift
	${DIR_BIN}/lxc-usernsexec $@
	;;
	
wait)
	shift
	${DIR_BIN}/lxc-wait $@
	;;
	
*)
	echo "Usage: $0 "
	echo "      attach"
	echo "      autostart"
	echo "      cgroup"
	echo "      checkconfig"
	echo "      checkpoint"
	echo "      clone"
	echo "      config"
	echo "      console"
	echo "      create"
	echo "      destroy"
	echo "      execute"
	echo "      freeze"
	echo "      ls"
	echo "      snapshot"
	echo "      start"
	echo "      stop"
	echo "      stop-all"
	echo "      top"
	echo "      unfreeze"
	echo "      unshare"
	echo "      usernsexec"
	echo "      wait"
	;;
esac