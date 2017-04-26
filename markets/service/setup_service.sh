#!/bin/sh
# Added -f to cp incase there is an updated setup_service.sh in future. Will make it easier to update the files without user having to do anything.

cp ./gridcoin_market_scrape.service /etc/systemd/system
cp ./gridcoin_market_scrape.timer /etc/systemd/system
cp ./gridcoin_market_scrape.sh /usr/local/bin
