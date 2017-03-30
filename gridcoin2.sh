# no need for shebang - this file is loaded from charts.d.plugin

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
# GPL v3+
#

gridcoin_update_every=5
load_priority=100

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
CHART gridcoin.load '' "System Load Average" "load" load system.load line $((load_priority + 1)) $gridcoin_update_every
DIMENSION connection 'connections' absolute 1 1
EOF

        return 0
}

gridcoin_update() {
        grc=$(cat /home/gridcoin/.GridcoinResearch/getinfo.json | jq '.connections')
        # grc=$(sudo -u gridcoin gridcoinresearchd -datadir=/home/gridcoin/.GridcoinResearch getinfo | jq '.connections')
        #load1=$(grc getinfo | jq '.connections')
        # write the result of the work.
        cat <<VALUESEOF
BEGIN gridcoin.load
SET connection = $grc
END
VALUESEOF

        return 0
}

