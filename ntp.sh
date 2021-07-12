method=$(busctl get-property xyz.openbmc_project.Settings /xyz/openbmc_project/time/sync_method xyz.openbmc_project.Time.Synchronization TimeSyncMethod)
arr1=(${method// / })
mode1=${arr1[1]}
mode2=$(echo $mode1 | tr -d \") 
arr2=(${mode2//./ })
mode=${arr2[5]}
servers=$(busctl get-property xyz.openbmc_project.Network /xyz/openbmc_project/network/eth0 xyz.openbmc_project.Network.EthernetInterface NTPServers)
arr3=(${servers// / })
numserv=${arr3[1]}

if [ $mode == 'Manual' ] || [ $numserv -eq 0 ]; then
  sleep 5
  newdate=$(nc time.nist.gov 13 | grep -o '[0-9]\{2\}\-[0-9]\{2\}\-[0-9]\{2\} [0-9]\{2\}\:[0-9]\{2\}\:[0-9]\{2\}' | sed -e 's/^/20/')
  date -s "$newdate"  >> /etc/rikntp/rikntp.conf
  sleep 5
elif [ $mode == 'NTP' ]; then
for i in "${!arr3[@]}"; do 
  sleep 5
  if [ $i -gt 1 ];  then
    ntpserver=$(echo ${arr3[$i]} | tr -d \") 
    ntpdate -u $ntpserver >> /etc/rikntp/rikntp.conf
    if [ $? -eq 0 ]; 
    then 
      sleep 5
      break
    fi
    sleep 5
  fi
done

fi

