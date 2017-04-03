# getpeerinfo chart

## Dependencies

sudo apt-get install haskell-platform

sudo apt-get install jq

cabal update

cabal install turtle

cabal install aeson

You also need to install netdata!

## How to install chart

Place the 'getpeerinfo.chart.sh' script into the "/usr/libexec/netdata/charts.d/" folder, and provide it full executable permissions "chmod +x getpeerinfo.chart.sh"

Edit the file "/etc/netdata/charts.d.conf" and set 'enable_all_charts="yes"'

Execute "killall netdata" then "netdata"

Navigate to IP:19999 and the new charts should be showing! If not, check the last few steps.

## How to begin gathering the peer info data

source ./initGPI-Hask.sh >/dev/null 2>&1 < /dev/null &

## <=1GB RAM? Setup a swap!

dd if=/dev/zero of=/tmp/swap bs=1M count=1024

mkswap /tmp/swap

swapon /tmp/swap