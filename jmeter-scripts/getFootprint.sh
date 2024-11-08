IP=${1}

PID=$(ssh ${IP} ps -ef | grep java | grep -v grep | awk '{print $2}' | tail -1)
FP=$(ssh ${IP} cat /proc/${PID}/smaps | grep 'Rss' | awk '{total+=$2;} END{print total;}' | numfmt --from-unit=1024 --to=iec | awk '{gsub("M"," "); print $1}')
echo
echo "Footprint: $FP"
echo
