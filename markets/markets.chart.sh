# no need for shebang - this file is loaded from charts.d.plugin

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
# GPL v3+
#

markets_update_every=5
load_priority=3 #3rd priority -> After blockchain details & peer details

# this is an example charts.d collector
# it is disabled by default.
# there is no point to enable it, since netdata already
# collects this information using its internal plugins.
markets_enabled=1

markets_check() {
	# this should return:
	#  - 0 to enable the chart
	#  - 1 to disable the chart

	if [ ${markets_update_every} -lt 5 ]
		then
		# there is no meaning for shorter than 5 seconds
		# the kernel changes this value every 5 seconds
		markets_update_every=5
	fi

	[ ${markets_enabled} -eq 0 ] && return 1
	return 0
}

markets_create() {
        # create a chart with 3 dimensions
cat <<EOF
CHART market.rank '' "Gridcoin CMC Rank" "Rank" GRC_Rank market.rank line $((load_priority + 1)) $markets_update_every
DIMENSION rank 'Rank' absolute 100 100
CHART market.price '' "Gridcoin price" "Price" GRC_Price market.price line $((load_priority + 1)) $markets_update_every
DIMENSION usd 'USD' absolute 100 100
DIMENSION btc 'BTC' absolute 100000000 1
CHART market.capandliquidity '' "Gridcoin marketcap & liquidity" "marketcap & liquidity" MarketCap_and_Liquidity market.capandliquidity line $((load_priority + 1)) $markets_update_every
DIMENSION volume 'Volume' absolute 100 100
DIMENSION cap 'Market Cap' absolute 100 100
CHART market.percent_change '' "Gridcoin percent change" "Gridcoin percent change" GRC_Percent_Changes market.percent_change line $((load_priority + 1)) $markets_update_every
DIMENSION onehour '1Hr' absolute 100 100
DIMENSION twentyfour '24Hr' absolute 100 100
DIMENSION sevendays '7days' absolute 100 100
EOF

        return 0
}

#[
#    {
#        "id": "gridcoin",
#        "name": "GridCoin",
#        "symbol": "GRC",
#        "rank": "70",
#        "price_usd": "0.0107371",
#        "price_btc": "0.00000950",
#        "24h_volume_usd": "23910.3",
#        "market_cap_usd": "4173278.0",
#        "available_supply": "388678321.0",
#        "total_supply": "388678321.0",
#        "percent_change_1h": "0.9",
#        "percent_change_24h": "1.84",
#        "percent_change_7d": "9.52",
#        "last_updated": "1491333858"
#    }
#]

markets_update() {
        rankVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].rank')
        usdVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].price_usd')
        btcVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].price_btc')
        volumeVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[]."24h_volume_usd"')
        capVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].market_cap_usd')
        onehourVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].percent_change_1h')
        twentyfourVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].percent_change_24h')
        sevendaysVal=$(cat /home/gridcoin/.GridcoinResearch/gridcoin_cmc.json | jq '.[].percent_change_7d')

        cat <<VALUESEOF
BEGIN market.rank
SET rank = $rankVal
END
BEGIN market.price
SET usd = $usdVal
SET btc = $btcVal
END
BEGIN market.capandliquidity
SET volume = $volumeVal
SET cap = $capVal
END
BEGIN market.percent_change
SET onehour = $onehourVal
SET twentyfour = $twentyfourVal
SET sevendays = $sevendaysVal
END
VALUESEOF

        return 0
}
