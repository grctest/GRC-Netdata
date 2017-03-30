# GRC-Netdata
Netdata charts for Gridcoin

# Installation guide

* This has only been tested on Ubuntu
* This script assumes you've setup your fullnode using [the autonode script](https://github.com/gridcoin-community/Autonode/blob/master/GridcoinAutoNode.sh), and have created the 'grc' alias for running the Gridcoin client under the 'gridcoin' user.
* You need to install [Netdata](https://github.com/firehol/netdata/wiki/Installation) (remember the pre-req section too).
* Once netdata has been installed, place the stats.sh script somewhere memorable and run it using the command "source ./stats.sh >/dev/null 2>&1 < /dev/null &"
* Place the 'gridcoin.chart.sh' script into the "/usr/libexec/netdata/charts.d/" folder, and provide it full executable permissions "chmod +x gridcoin.chart.sh"
* Edit the file "/etc/netdata/charts.d.conf" and set both 'enable_all_charts="yes"' and 'gridcoin="yes"'
* Execute "killall netdata" then "netdata"
* Navigate to IP:19999 and your Gridcoin charts should be shown!