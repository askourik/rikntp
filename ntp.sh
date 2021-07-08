#!/bin/bash

#--------------------------main-------------------

address=$(cat < /etc/rikntp/rikntp.conf) 
oncal="*:0/5"
dateparam=$(date)

modemes="!"
if [ "$mode" -eq 1 ]; then
modemes="errors"
elif [ "$mode" -eq 2 ]; then
modemes="warnings"
else
modemes="values"
fi

from="From: \"Rikor-Scalable EATX Board\" <Rikor-Scalable@rikor.com>"
to="To: \"Administrator\" <$recipient>"
echo $from  > /etc/rikmail/header.txt
echo $to  >> /etc/rikmail/header.txt

oncal="daily"
period1="daily"
mode1="all"

if [ $period -eq 1 ]; then
oncal="*:0/5"
period1="every 5 minutes"
elif [ $period -eq 2 ]; then
oncal="daily"
period1="daily"
else
oncal="daily"
period1="daily"
fi

res2=0
echo "Hi $recipient," > /etc/rikmail/body.txt
echo "Send Mode: $modemes. Period: $period1" >> /etc/rikmail/body.txt

WriteBody $mode
res2=$?
if [ "$res2" -gt 0 ]; then
echo "Bye" >> /etc/rikmail/body.txt
else
echo "All is OK. Bye" >> /etc/rikmail/body.txt
fi
subj="Subject: EATX Board Parameters at $dateparam: $res2 $modemes"
echo $subj  >> /etc/rikmail/header.txt
echo >> /etc/rikmail/header.txt

cat /etc/rikmail/header.txt /etc/rikmail/body.txt > /etc/rikmail/mail.txt

if [ $recipient != "info@example.com" ] && [ $recipient != "" ]; then
/usr/sbin/sendmail -t < /etc/rikmail/mail.txt
sleep 10
fi

