#!/usr/bin/env runhaskell

# node-stats function
function initialize-haskell-script {
   ./getpeerinfo.hs
}

# Check if gridcoin is running, call node stats script
if pgrep "gridcoin" > /dev/null
then
    while true
    do
     initialize-haskell-script
     sleep 60
    done
else
   #  echo "Gridcoin is not running!"
    exit 1
fi

# Start this script with the following:
# source ./stats.sh >/dev/null 2>&1 < /dev/null &