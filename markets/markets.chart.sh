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
# cat <<EOF
# CHART gridcoin.connection '' "Gridcoin client connections" "connections" connection gridcoin.connection line $((load_priority + 1)) $markets_update_every
# DIMENSION connection 'connections' absolute 1 1
# CHART gridcoin.blocks '' "Gridcoin blocks" "blocks" Blocks gridcoin.block line $((load_priority + 1)) $markets_update_every
# DIMENSION blocks 'blocks' absolute 1 1
# EOF

        return 0
}

markets_update() {
        #connections=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.connections')
        #blocks=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.blocks')
        #moneysupply=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.moneysupply')
        #difficulty_pow=$(cat /home/gridcoin/.GridcoinResearch/difficulty.json | jq .\"proof-of-work\")
        #difficulty_pos=$(cat /home/gridcoin/.GridcoinResearch/difficulty.json | jq .\"proof-of-stake\")
        #staking_weight=$(cat /home/gridcoin/.GridcoinResearch/getstakinginfo.json | jq '.netstakeweight')
        # grc=$(sudo -u gridcoin gridcoinresearchd -datadir=/home/gridcoin/.GridcoinResearch getinfo | jq '.connections')
        #load1=$(grc getinfo | jq '.connections')
        # write the result of the work.
        #cat <<VALUESEOF
#BEGIN gridcoin.connection
#SET connection = $connections
#END
#BEGIN gridcoin.blocks
#SET blocks = $blocks
#END
#VALUESEOF

        return 0
}
