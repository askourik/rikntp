params=$(tr '_' ';|' < /etc/rikntp/rikntp.conf) 
arr=(${params//;/ })
mode=${arr[0]}
address=${arr[1]}

if [ $mode -eq 0 ]; then
newdate=$(nc time.nist.gov 13 | grep -o '[0-9]\{2\}\-[0-9]\{2\}\-[0-9]\{2\} [0-9]\{2\}\:[0-9]\{2\}\:[0-9]\{2\}' | sed -e 's/^/20/')
date -s "$newdate"
sleep 10
elif [ $mode -eq 1 ]; then
ntpdate -u $address
sleep 10
fi

