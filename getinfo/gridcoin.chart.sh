# no need for shebang - this file is loaded from charts.d.plugin

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
# GPL v3+
#

gridcoin_update_every=5
load_priority=1

# this is an example charts.d collector
# it is disabled by default.
# there is no point to enable it, since netdata already
# collects this information using its internal plugins.
gridcoin_enabled=1

gridcoin_check() {
	# this should return:
	#  - 0 to enable the chart
	#  - 1 to disable the chart

	if [ ${gridcoin_update_every} -lt 5 ]
		then
		# there is no meaning for shorter than 5 seconds
		# the kernel changes this value every 5 seconds
		gridcoin_update_every=5
	fi

	[ ${gridcoin_enabled} -eq 0 ] && return 1
	return 0
}

gridcoin_create() {
        # create a chart with 3 dimensions
cat <<EOF
CHART Gridcoin.connections '' "Gridcoin client connections" "# of connections" Connections gridcoin.connections line $((load_priority + 1)) $gridcoin_update_every
DIMENSION connections 'Connected' absolute 1 1
CHART Gridcoin.blocks '' "Gridcoin blocks" "# of blocks" Blocks gridcoin.blocks line $((load_priority + 1)) $gridcoin_update_every
DIMENSION blocks 'Blocks' absolute 1 1
CHART Gridcoin.money '' "Gridcoin coin supply" "Total coin supply" Coin_Supply gridcoin.money line $((load_priority + 1)) $gridcoin_update_every
DIMENSION moneysupply 'Coins' absolute 1 1
CHART Gridcoin.difficulty '' "Gridcoin difficulties" "Difficulty" Difficulties gridcoin.difficulty line $((load_priority + 1)) $gridcoin_update_every
DIMENSION difficultypos 'PoS' absolute 1 1
DIMENSION difficultypow 'PoW' absolute 1 1
CHART Gridcoin.stake_weight '' "Gridcoin network weight" "# of coins staking" Network_Weight gridcoin.stake_weight line $((load_priority + 1)) $gridcoin_update_every
DIMENSION stakeweight 'Weight' absolute 1 1
CHART Gridcoin.continent '' "Gridcoin client locations" "# of connections from" Locations gridcoin.continent stacked $((load_priority + 1)) $gridcoin_update_every
DIMENSION northamerica 'N. America' absolute 1 1
DIMENSION southamerica 'S. America' absolute 1 1
DIMENSION europe 'Europe' absolute 1 1
DIMENSION africa 'Africa' absolute 1 1
DIMENSION asia 'Asia' absolute 1 1
DIMENSION oceania 'Oceania' absolute 1 1
DIMENSION other 'Other' absolute 1 1
EOF

        return 0
}

gridcoin_update() {
        GRCINFO='/home/gridcoin/.GridcoinResearch/getinfo.json'
        GRCSTAKING='/home/gridcoin/.GridcoinResearch/getstakinginfo.json'
        GRCGEO='/home/gridcoin/.GridcoinResearch/geooutput.json'
	connections=$(jq '.connections' $GRCINFO)
        blocks=$(jq '.blocks' $GRCINFO)
        moneysupply=$(jq '.moneysupply' $GRCINFO)
        difficulty_pow=$(jq '.difficulty["proof-of-work"]' $GRCINFO)
        difficulty_pos=$(jq '.difficulty["proof-of-stake"]' $GRCINFO)
        staking_weight=$(jq '.netstakeweight' $GRCSTAKING)
        geoNA=$(jq -r '.[].contNA' $GRCGEO)
        geoSA=$(jq -r '.[].contSA' $GRCGEO)
        geoEU=$(jq -r '.[].contEU' $GRCGEO)
        geoAF=$(jq -r '.[].contAF' $GRCGEO)
        geoAS=$(jq -r '.[].contAS' $GRCGEO)
        geoOC=$(jq -r '.[].contOC' $GRCGEO)
        geoOT=$(jq -r '.[].contOT' $GRCGEO)
	# write the result of the work.
        cat <<VALUESEOF
BEGIN Gridcoin.connection
SET connection = $connections
END
BEGIN Gridcoin.blocks
SET blocks = $blocks
END
BEGIN Gridcoin.money
SET moneysupply = $moneysupply
END
BEGIN Gridcoin.difficulty
SET difficultypos = $difficulty_pos
SET difficultypow = $difficulty_pow
END
BEGIN Gridcoin.stake_weight
SET stakeweight = $staking_weight
END
BEGIN Gridcoin.continent
SET northamerica = $geoNA
SET southamerica = $geoSA
SET europe = $geoEU
SET africa = $geoAF
SET asia = $geoAS
SET oceania = $geoOC
SET other = $geoOT
END
VALUESEOF

        return 0
}
