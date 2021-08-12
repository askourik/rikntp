logger "ntp.sh start"
params=$(tr ' ' ' |' < /etc/rikntp/rikntp.conf) 
arrold=(${params// / })
modeold=${arrold[0]}
ntpserverold=${arrold[1]}
if [ $ntpserverold == 'Firsttime' ]; then
  logger "ntp.sh starting firsttime"  
  busctl set-property xyz.openbmc_project.Settings /xyz/openbmc_project/time/sync_method xyz.openbmc_project.Time.Synchronization TimeSyncMethod s "xyz.openbmc_project.Time.Synchronization.Method.Manual"
  logger "ntp.sh busctl set-property Manual"  
fi
method=$(busctl get-property xyz.openbmc_project.Settings /xyz/openbmc_project/time/sync_method xyz.openbmc_project.Time.Synchronization TimeSyncMethod)
logger "ntp.sh method=$method"
arr1=(${method// / })
mode1=${arr1[1]}
mode2=$(echo $mode1 | tr -d \") 
arr2=(${mode2//./ })
mode=${arr2[5]}
logger "ntp.sh mode=$mode"

logger "ntp.sh modeold=$modeold ntpserverold=$ntpserverold"

if [ $mode == 'Manual' ]; then
  if [ $mode != $modeold ]; then
    logger "ntp.sh systemctl enable pch-time-sync.service"
    systemctl enable pch-time-sync.service
    sleep 10
    logger "ntp.sh systemctl start pch-time-sync.service"
    systemctl start pch-time-sync.service
    sleep 5
  fi
  logger "ntp.sh modenew=$mode ntpservernew=Manual"
  #sleep 5
  #newdate=$(nc time.nist.gov 13 | grep -o '[0-9]\{2\}\-[0-9]\{2\}\-[0-9]\{2\} [0-9]\{2\}\:[0-9]\{2\}\:[0-9]\{2\}' | sed -e 's/^/20/')
  #date -s "$newdate"
  #logger "ntp.sh set Manual = $newdate"
  logger "ntp.sh firsttine write $mode to rikntp.conf"
  echo $mode Manual > /etc/rikntp/rikntp.conf
  sleep 1
elif [ $mode == 'NTP' ]; then
 if [ $mode != $modeold ]; then
   logger "ntp.sh   systemctl stop pch-time-sync.service"
   systemctl stop pch-time-sync.service
   sleep 5
   logger "ntp.sh   systemctl disable pch-time-sync.service"
   systemctl disable pch-time-sync.service
   sleep 10
 fi
 servers=$(busctl get-property xyz.openbmc_project.Network /xyz/openbmc_project/network/eth0 xyz.openbmc_project.Network.EthernetInterface NTPServers)
 if [ -z "$servers" ]; then
   numserv=0
 else
   arr3=(${servers// / })
   numserv=${arr3[1]}
 fi
 logger "ntp.sh numserv=$numserv"
 #if [ $numserv -eq 0 ]; then
 #  mode='Manual'
 #fi

 for i in "${!arr3[@]}"; do 
  sleep 1
  if [ $i -gt 1 ];  then
    ntpserver=$(echo ${arr3[$i]} | tr -d \") 
    ntpdate -u $ntpserver
    if [ $? -eq 0 ]; 
    then
      sleep 5
      logger "ntp.sh modenew=$mode ntpservernew=$ntpserver"
      newdate=$(date) 
      logger "ntp.sh set NTP from $ntpserver = $newdate"
      logger "ntp.sh NTP write $mode $ntpserver to rikntp.conf"
      echo $mode $ntpserver > /etc/rikntp/rikntp.conf
      sleep 1
      break
    fi
    logger "ntp.sh set NTP from $ntpserver failed, trying next"
    sleep 5
  fi
 done

fi

logger "ntp.sh complete"
