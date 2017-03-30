# node-stats function
function node-stats {
   #echo "Gridcoin client running. Creating files!"

    grc getinfo > /usr/share/netdata/web/getinfo.json

    #echo "Moving files"
    # \cp getinfo.json /usr/share/netdata/web/

    #echo "Changing file ownership"
    sudo chown netdata:netdata /usr/share/netdata/web/getinfo.json

    #echo "Deleting files"
    rm -rf getinfo.json
}

# Check if gridcoin is running, call node stats script
if pgrep "gridcoin" > /dev/null
then
    while true
    do
     node-stats
     sleep 5
    done
else
   #  echo "Gridcoin is not running!"
    exit 1
fi

# Start this script with the following:
# nohup bash stats.sh &

# crontab -e
# @reboot source ./stats.sh >/dev/null 2>&1 < /dev/null &
