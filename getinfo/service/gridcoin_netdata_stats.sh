#!/bin/sh

if pgrep "gridcoin" > /dev/null
then
	grc getinfo > /home/gridcoin/.GridcoinResearch/getinfo.json
	grc getstakinginfo > /home/gridcoin/.GridcoinResearch/getstakinginfo.json
	grc getdifficulty > /home/gridcoin/.GridcoinResearch/difficulty.json
	else
   #  echo "Gridcoin is not running!"
    exit 1
fi