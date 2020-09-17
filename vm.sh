#!/bin/zsh

# vmware fusion on mac
# for headless vms start, stop, ssh and so on.

VMRUN="/Applications/VMware Fusion.app/Contents/Public/vmrun"
VMDIR="$HOME/Virtual Machines.localized"

ACTION=$1
shift 1
VMNAME="$@"

#echo $ACTION
#echo $VMNAME

function vmrun_start
{
	VM="$@"
	if [[ "$(vmrun_find_running $VM)" != 0 ]]; then
		echo 'VM already running'
		exit
	fi
	echo "Starting $VMNAME..."
	"$VMRUN" -T ws start "$VM" nogui
}

function vmrun_ip
{
	VM="$@"
	"$VMRUN" -T fusion getGuestIPAddress "$VM" -wait
}

function vmrun_ssh
{
	VM="$@"
	echo -n "ip: "
	vmrun_ip $VM
	ssh root@$("$VMRUN" -T fusion getGuestIPAddress "$VM" -wait)
}

function vmrun_suspend
{
	VM="$@"
	if [[ "$(vmrun_find_running $VM)" == 0 ]]; then
		echo 'VM not running'
		exit
	fi
	echo "Suspening $VMNAME..."
	"$VMRUN" suspend "$VM"
}

function vmrun_list
{
	LIST=$("$VMRUN" list)
	ESCAPED_DIR=$(echo "$VMDIR" | sed 's/\//\\\//g' | sed 's/\./\\\./g')
	echo "$LIST" | sed -n "s/$ESCAPED_DIR\/\(.*\)\.vmwarevm\/\(.*\)\.vmx/\2/p"
	echo "$LIST" | head -n 1
}

function list_names
{
	ls $VMDIR | cut -d'.' -f 1
}

function vmrun_find_running
{
	VM="$@"
	echo $("$VMRUN" list | grep "$VM" | wc -l);
}

function vmrun_help
{
	echo "usage:"
	echo "- start a headless vm:"
	echo "$ $0 start vmname"
	echo
	echo "- suspend a headless vm:"
	echo "$ $0 stop vmname"
	echo
	echo "- suspect ip address of a vm:"
	echo "$ $0 ip vmname"
	echo
	echo "- ssh into a vm:"
	echo "$ $0 ssh vmname"
	echo
	echo "- list running vms"
	echo "$ $0 list"
	echo
	echo "- list all available vms"
	echo "$ $0 name"
}

# 1 args
if [ -s $ACTION ]; then
	vmrun_help
	exit
fi

# 2 args
if [[ $ACTION == 'help' ]]; then
	vmrun_help
	exit
fi

if [[ $ACTION == 'list' ]]; then
	vmrun_list
	exit
fi

if [[ $ACTION == 'name' ]]; then
	list_names
	exit
fi

# 3 args
if [ -s $VMNAME ]; then
	echo 'specify a vm name'
	exit
fi

if [ ! -d "$VMDIR/$VMNAME.vmwarevm" ]; then
	echo 'vm not found'
	exit
fi

VMX="$VMDIR/$VMNAME.vmwarevm/$VMNAME.vmx"

if [ ! -f "$VMX" ]; then
	echo 'vmx not found'
	exit
fi

case $ACTION in
	start)
		vmrun_start $VMX
		;;
	stop)
		vmrun_suspend $VMX
		;;
	suspend)
		vmrun_suspend $VMX
		;;
	ip)
		vmrun_ip $VMX
		;;
	ssh)
		vmrun_ssh $VMX
		;;
	*)
		vmrun_help
		;;
esac

