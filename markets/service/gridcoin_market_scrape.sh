#!/bin/bash
# Scraping the market stats for Gridcoin
# For service use only

if pgrep "gridcoin" > /dev/null
then
	GRCPATH='/home/gridcoin/.GridcoinResearch'
	curl "https://api.coinmarketcap.com/v1/ticker/gridcoin/" > $GRCPATH/gridcoin_cmc.tmp && mv -f $GRCPATH/gridcoin_cmc.tmp $GRCPATH/gridcoin_cmc.json
	else
	exit 1
fi


