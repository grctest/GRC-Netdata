#!/bin/bash
#
# Part 1: Install Gridcoin netdata stats to service
# Part 2: Install Gricoin geography gathering to service
# Part 3: Install Freegeoip as service
# Part 4: Permission to start services/freegeoip
#
# Added functions to accept inputs for starting services.
# Functions for setup

function serviceinstall {

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

        # Part 3
        #
        # Download archive and extract freegeoip (more secure)
        # Copy freegeoip service, binary and license file
        # Service not supported as doesn't run as daemon nor can be forced with systemctl
        echo Downloading freegeoip version 3.2 amd64..
        wget https://github.com/fiorix/freegeoip/releases/download/v3.2/freegeoip-3.2-linux-amd64.tar.gz
        echo Extracting freegeoip from archive..
        tar -zxf freegeoip-3.2-linux-amd64.tar.gz freegeoip-3.2-linux-amd64/freegeoip
        echo Making crontab bootup entry under user gridcoin..
        echo Warning: If you have run this install more then once then crontab -u gridcoin -e and make sure there is no duplicate entry for freegeoip
        crontab -l -u gridcoin | cat - freegeoip.crontab | crontab -u gridcoin -
        echo Copying license file..
        cp ./freegeoip.license /usr/local/bin/freegeoip.license
        echo Copying freegeoip binary..
        cp ./freegeoip-3.2-linux-amd64/freegeoip /usr/local/bin
        # make freegeoip executable
        echo Making freegeoip executable..
        chmod +x /usr/local/bin/freegeoip

        # Part 4
        #
        # Ask to start services/start freegeoip
        servicestartup
        exit 1
}

function servicestartup {

        read -p "Would you like to start these services and freegeoip at this time? (Y/N) " -n 1 choice
        echo
        case "$choice" in
                y|Y ) answer="Y";;
                n|N ) answer="N";;
        esac
        if [[ $answer ==  "Y" ]]
        then
                echo Enabling/Starting gridcoin_netdata_stats..
                systemctl enable gridcoin_netdata_stats.timer
                systemctl start gridcoin_netdata_stats.timer
                echo Enabling/Starting gridcoin_geo_scrape..
                systemctl enable gridcoin_geo_scrape.timer
                systemctl start gridcoin_geo_scrape.timer
                echo Starting freegeoip..
                # Start from sudo this time however after reboot it will load automatically as @reboot is supported by normal accounts as well.
                sudo -u gridcoin /usr/local/bin/freegeoip -http 127.0.0.1:5000 -silent &
                echo Complete.. Verify service status.
                exit 1
        elif [[ $answer == "N" ]]
        then
                echo Read readme.md file for more information about Enabling/Starting services.
                exit 1
        else
                # Bad input??? Big fingers?? Those kind of moments then loop back into servicestartup for another go.
                servicestartup
                exit 1
        fi
        exit 1
}

# Run serviceinstall function
serviceinstall
