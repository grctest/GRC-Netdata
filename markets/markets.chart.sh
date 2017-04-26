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
DIMENSION rank 'Rank' absolute 1 1
CHART market.usdprice '' "Gridcoin price" "Price" GRC_to_USD_Price market.usdprice line $((load_priority + 1)) $markets_update_every
DIMENSION usd 'USD' absolute 1 10000
CHART market.btcprice '' "Gridcoin price" "Price (Satoshi)" GRC_to_BTC_Price market.btcprice line $((load_priority + 1)) $markets_update_every
DIMENSION btc 'BTC' absolute 1 1
CHART market.mcap '' "Gridcoin marketcap" "Market cap" Market_Cap market.mcap line $((load_priority + 1)) $markets_update_every
DIMENSION cap 'Cap' absolute 1 1
CHART market.mliquidity '' "Gridcoin Liquidity" "Market liquidity" Market_Liquiduity market.mliquidity line $((load_priority + 1)) $markets_update_every
DIMENSION volume 'Volume' absolute 1 1
CHART market.percent_change '' "Gridcoin percent change" "Gridcoin percent change" GRC_Percent_Changes market.percent_change line $((load_priority + 1)) $markets_update_every
DIMENSION onehour '1Hr' absolute 100 1
DIMENSION twentyfour '24Hr' absolute 100 1
DIMENSION sevendays '7Days' absolute 100 1
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
        GRCCMC='/home/gridcoin/.GridcoinResearch/gridcoin_cmc.json'
	# jq -r raw output saves stirpping of "'s
	# tr -d '\n' removes end of line so we can do math
	# piping to bc is used for calculations as shell can't do floating point operations
        rankVal=$(jq -r '.[].rank' $GRCCMC | tr -d '\n')
        usdVal0=$(jq -r '.[].price_usd' $GRCCMC | tr -d '\n')
        usdVal=$(echo $usdVal0 \* 10000 | bc | tr -d '\n')
        btcVal0=$(jq -r '.[].price_btc' $GRCCMC | tr -d '\n')
 	btcVal=$(echo $btcVal0 \* 100000000 | bc | tr -d '\n')
        volumeVal=$(jq '.[]."24h_volume_usd"' $GRCCMC)
        capVal=$(jq '.[].market_cap_usd' $GRCCMC)
        onehourVal0=$(jq -r '.[].percent_change_1h' $GRCCMC | tr -d '\n')
	onehourVal=$(echo $onehourVal0 \* 100 | bc | tr -d '\n')
        twentyfourVal0=$(jq -r '.[].percent_change_24h' $GRCCMC | tr -d '\n')
	twentyfourVal=$(echo $twentyfourVal0 \* 100 | bc | tr -d '\n')
        sevendaysVal0=$(jq -r '.[].percent_change_7d' $GRCCMC | tr -d '\n')
	sevendaysVal=$(echo $sevendaysVal0 \* 100 | bc | tr -d '\n')
	
        cat <<VALUESEOF
BEGIN market.rank
SET rank = $rankVal
END
BEGIN market.usdprice
SET usd = $usdVal
END
BEGIN market.btcprice
SET btc = $btcVal
END
BEGIN market.mcap
SET cap = $capVal
END
BEGIN market.mliquidity
SET volume = $volumeVal
END
BEGIN market.percent_change
SET onehour = $onehourVal
SET twentyfour = $twentyfourVal
SET sevendays = $sevendaysVal
END
VALUESEOF

        return 0
}
