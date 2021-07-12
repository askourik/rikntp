sleep 5
newdate=$(nc time.nist.gov 13 | grep -o '[0-9]\{2\}\-[0-9]\{2\}\-[0-9]\{2\} [0-9]\{2\}\:[0-9]\{2\}\:[0-9]\{2\}' | sed -e 's/^/20/')
date -s "$newdate"  >> /etc/rikntp/rikntp.conf
sleep 5

logger "ntptimer.sh complete"
