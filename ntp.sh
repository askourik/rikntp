method=$(busctl get-property xyz.openbmc_project.Settings /xyz/openbmc_project/time/sync_method xyz.openbmc_project.Time.Synchronization TimeSyncMethod)
arr1=(${method// / })
mode1=${arr1[1]}
mode2=$(echo $mode1 | tr -d \") 
arr2=(${mode2//./ })
mode=${arr2[5]}
servers=$(busctl get-property xyz.openbmc_project.Network /xyz/openbmc_project/network/eth0 xyz.openbmc_project.Network.EthernetInterface NTPServers)
if [ -z "$servers" ]; then
  numserv=0
else
  arr3=(${servers// / })
  numserv=${arr3[1]}
fi

logger "ntp.sh start"
params=$(tr ' ' ' |' < /etc/rikntp/rikntp.conf) 
arrold=(${params// / })
modeold=${arrold[0]}
ntpserverold=${arrold[1]}
logger "ntp.sh modeold=$modeold ntpserverold=$ntpserverold"

if [ $numserv -eq 0 ]; then
  mode='Manual'
fi

if [ $mode == 'Manual' ] && [ $ntpserverold == 'Firsttime' ]; then
  logger "ntp.sh modenew=$mode ntpservernew=Manual"
  sleep 5
  newdate=$(nc time.nist.gov 13 | grep -o '[0-9]\{2\}\-[0-9]\{2\}\-[0-9]\{2\} [0-9]\{2\}\:[0-9]\{2\}\:[0-9]\{2\}' | sed -e 's/^/20/')
  logger "ntp.sh   systemctl enable pch-time-sync.service"
  systemctl enable pch-time-sync.service
  sleep 5
  systemctl start pch-time-sync.service
  sleep 5
  #date -s "$newdate"
  logger "ntp.sh set Manual = $newdate"
  echo $mode Manual > /etc/rikntp/rikntp.conf
  sleep 5
elif [ $mode == 'NTP' ]; then
 for i in "${!arr3[@]}"; do 
  sleep 5
  if [ $i -gt 1 ];  then
    ntpserver=$(echo ${arr3[$i]} | tr -d \") 
    ntpdate -u $ntpserver
    if [ $? -eq 0 ]; 
    then
      logger "ntp.sh   systemctl disable pch-time-sync.service"
      systemctl stop pch-time-sync.service
      sleep 5
      systemctl disable pch-time-sync.service
      sleep 5
      logger "ntp.sh modenew=$mode ntpservernew=$ntpserver"
      newdate=$(date) 
      logger "ntp.sh set NTP from $ntpserver = $newdate"
      echo $mode $ntpserver > /etc/rikntp/rikntp.conf
      sleep 5
      break
    fi
    logger "ntp.sh set NTP from $ntpserver failed, trying next"
    sleep 5
  fi
 done

fi

logger "ntp.sh complete"
