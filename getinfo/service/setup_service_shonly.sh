#!/bin/bash
#
# Part 1: Install Gridcoin netdata stats to service
# Part 2: Install Gricoin geography gathering to service
# Part 3: Install Freegeoip as service
#
# This version for those who don't use most common 'bash'
#
# Part 1
#
# Copy netdata service, chart and script.
echo Copying gridcoin stats and chart files..
cp ./gridcoin_netdata_stats.service /etc/systemd/system
cp ./gridcoin_netdata_stats.timer /etc/systemd/system
cp ./gridcoin_netdata_stats.sh /usr/local/bin
cp ./../gridcoin.chart.sh /usr/libexec/netdata/charts.d
# Make chart and script executable
echo Making .sh files executable..
chmod +x /usr/local/bin/gridcoin_netdata_stats.sh
chmod +x /usr/libexec/netdata/charts.d/gridcoin.chart.sh
#
# Part 2
#
# Copy geo scrape service, geo.json list, and script.
echo Copying gridcoin geography scrape files..
cp ./gridcoin_geo_scrape.service /etc/systemd/system
cp ./gridcoin_geo_scrape.timer /etc/systemd/system
cp ./gridcoin_geo_scrape.sh /usr/local/bin
cp ./geo.json /usr/local/bin/geo.json
# Make script executable
echo Making .sh file executable..
chmod +x /usr/local/bin/gridcoin_geo_scrape.sh
#
# Part 3
#
# Download archive and extract freegeoip (more secure)
# Copy freegeoip service, binary and license file
echo Downloading freegeoip version 3.2 amd64..
wget https://github.com/fiorix/freegeoip/releases/download/v3.2/freegeoip-3.2-linux-amd64.tar.gz
echo Extracting freegeoip from archive..
tar -zxf freegeoip-3.2-linux-amd64.tar.gz freegeoip-3.2-linux-amd64/freegeoip
echo Copying service file..
cp ./gridcoin_freegeoip_service.service /etc/systemd/system
echo Copying license file..
cp ./freegeoip.license /usr/local/bin/freegeoip.license
echo Copying freegeoip binary..
cp ./freegeoip-3.2-linux-amd64/freegeoip /usr/local/bin
# make freegeoip executable
echo Making freegeoip executable..
chmod +x /usr/local/bin/freegeoip
#
echo Read readme.md for enable/starting instructions
