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
CHART gridcoin.connection '' "Gridcoin client connections" "connections" connection gridcoin.connection line $((load_priority + 1)) $gridcoin_update_every
DIMENSION connection 'connections' absolute 1 1
CHART gridcoin.blocks '' "Gridcoin blocks" "blocks" block gridcoin.block line $((load_priority + 1)) $gridcoin_update_every
DIMENSION blocks 'blocks' absolute 1 1
DIMENSION moneysupply 'connections' absolute 1 1
CHART gridcoin.money '' "Gridcoin moneysupply" "coins" block gridcoin.money line $((load_priority + 1)) $gridcoin_update_every
DIMENSION moneysupply 'coins' absolute 1 1
CHART gridcoin.difficulty '' "Gridcoin difficulties" "difficulty" block gridcoin.difficulty line $((load_priority + 1)) $gridcoin_update_every
DIMENSION difficultypos 'pos' absolute 1 1
DIMENSION difficultypow 'pow' absolute 1 1
EOF

        return 0
}

gridcoin_update() {
        connections=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.connections')
        blocks=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.blocks')
        moneysupply=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.moneysupply')
        difficulty_pow=$(cat /home/gridcoin/.GridcoinResearch/difficulty.json | jq .\"proof-of-work\")
        difficulty_pos=$(cat /home/gridcoin/.GridcoinResearch/difficulty.json | jq .\"proof-of-stake\")
        # grc=$(sudo -u gridcoin gridcoinresearchd -datadir=/home/gridcoin/.GridcoinResearch getinfo | jq '.connections')
        #load1=$(grc getinfo | jq '.connections')
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
VALUESEOF

        return 0
}