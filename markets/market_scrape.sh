# Scraping the market stats for Gridcoin
function grc-value {
    GRCPATH='/home/gridcoin/.GridcoinResearch'
    curl -s "https://api.coinmarketcap.com/v1/ticker/gridcoin/" > $GRCPATH/gridcoin_cmc.tmp && mv -f $GRCPATH/gridcoin_cmc.tmp $GRCPATH/gridcoin_cmc.json
}

# Continuously running the script every x seconds
while true
do
 grc-value
 sleep 15
done

# Start this script with the following:
# source ./market_scrape.sh >/dev/null 2>&1 < /dev/null &
