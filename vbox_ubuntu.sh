# if (( $# > 0 )) # isn't supported by POSIX shell
vmname="Ubuntu"
if [ $# -gt 0 ]
then
    if [ "$1" == 'off' ]
    then
      VBoxManage controlvm $vmname poweroff --type headless
    elif [ "$1" == 'pause' ]
    then
      VBoxManage controlvm $vmname pause --type headless
    elif [ "$1" == 'resume' ]
    then
      VBoxManage controlvm $vmname resume --type headless
    elif [ "$1" == 'status' ]
    then
      vboxmanage showvminfo $vmname | grep State
    elif [ "$1" == 'ssh' ]
    then
      ssh -p 2222 soreatu@127.0.0.1
    elif [ "$1" == 'ip' ]
    then
      ip=`VBoxManage guestproperty get $vmname "/VirtualBox/GuestInfo/Net/0/V4/IP" | cut -d' ' -f 2`
      echo $ip
    else
      echo 'Usage: ubuntu [off/pause/resume/status/ssh/ip]'
    fi
else
  is_running=`vboxmanage showvminfo $vmname | grep -c "running (since"`
  # echo $is_running
  if [ "$is_running" == '0' ]
  then
    echo 'starting...'
    VBoxManage startvm $vmname --type headless
  else
    echo 'Ubuntu is already running...'
  fi
fi
