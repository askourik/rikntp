address=$(cat < /etc/rikntp/rikntp.conf) 
oncal="*:0/5"

echo "[Unit]" > /etc/rikntp/rikntp.timer
echo "Description=Logs some system statistics to the systemd journal" >> /etc/rikntp/rikntp.timer
echo "Requires=rikntp.service" >> /etc/rikntp/rikntp.timer
echo >> /etc/rikntp/rikntp.timer
echo "[Timer]" >> /etc/rikntp/rikntp.timer
echo "Unit=rikntp.service" >> /etc/rikntp/rikntp.timer
echo "OnCalendar=$oncal" >> /etc/rikntp/rikntp.timer
echo >> /etc/rikntp/rikntp.timer
echo "[Install]" >> /etc/rikntp/rikntp.timer
echo "WantedBy=timers.target" >> /etc/rikntp/rikntp.timer

sleep 3

cp /etc/rikntp/rikntp.timer /etc/systemd/system/rikntp.timer

sleep 3

systemctl daemon-reload
systemctl restart rikntp.timer

logger "uptimer.sh complete"
