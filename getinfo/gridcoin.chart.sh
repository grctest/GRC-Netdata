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
CHART gridcoin.connection '' "Gridcoin client connections" "connections" Connections gridcoin.connection line $((load_priority + 1)) $gridcoin_update_every
DIMENSION connection 'connections' absolute 1 1
CHART gridcoin.blocks '' "Gridcoin blocks" "blocks" Blocks gridcoin.block line $((load_priority + 1)) $gridcoin_update_every
DIMENSION blocks 'blocks' absolute 1 1
CHART gridcoin.money '' "Gridcoin coinsupply" "coins" Coinsupply gridcoin.money line $((load_priority + 1)) $gridcoin_update_every
DIMENSION moneysupply 'coins' absolute 1 1
CHART gridcoin.difficulty '' "Gridcoin difficulties" "difficulty" Difficulties gridcoin.difficulty line $((load_priority + 1)) $gridcoin_update_every
DIMENSION difficultypos 'pos' absolute 1 1
DIMENSION difficultypow 'pow' absolute 1 1
CHART gridcoin.stake_weight '' "Gridcoin stake weight" "stake weight" Stake_Weight gridcoin.stake_weight line $((load_priority + 1)) $gridcoin_update_every
DIMENSION stakeweight 'stake_weight' absolute 1 1
EOF

        return 0
}

gridcoin_update() {
        GRCINFO='/home/gridcoin/.GridcoinResearch/getinfo.json'
        GRCSTAKING='/home/gridcoin/.GridcoinResearch/getstakinginfo.json'
        connections=$(jq '.connections' $GRCINFO)
        blocks=$(jq '.blocks' $GRCINFO)
        moneysupply=$(jq '.moneysupply' $GRCINFO)
        difficulty_pow=$(jq '.difficulty["proof-of-work"]' $GRCINFO)
        difficulty_pos=$(jq '.difficulty["proof-of-stake"]' $GRCINFO)
        staking_weight=$(jq '.netstakeweight' $GRCSTAKING)
        # write the result of the work.
        cat <<VALUESEOF
BEGIN gridcoin.connection
SET connection = $connections
END
BEGIN gridcoin.blocks
SET blocks = $blocks
END
BEGIN gridcoin.money
SET moneysupply = $moneysupply
END
BEGIN gridcoin.difficulty
SET difficultypos = $difficulty_pos
SET difficultypow = $difficulty_pow
END
BEGIN gridcoin.stake_weight
SET stakeweight = $staking_weight
END
VALUESEOF

        return 0
}
