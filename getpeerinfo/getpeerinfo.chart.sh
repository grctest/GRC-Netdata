# no need for shebang - this file is loaded from charts.d.plugin

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
# GPL v3+
#

getpeerinfo_update_every=10
load_priority=2

# this is an example charts.d collector
# it is disabled by default.
# there is no point to enable it, since netdata already
# collects this information using its internal plugins.
getpeerinfo_enabled=1

getpeerinfo_check() {
	# this should return:
	#  - 0 to enable the chart
	#  - 1 to disable the chart

	if [ ${getpeerinfo_update_every} -lt 10 ]
		then
		# there is no meaning for shorter than 5 seconds
		# the kernel changes this value every 5 seconds
		getpeerinfo_update_every=10
	fi

	[ ${getpeerinfo_enabled} -eq 0 ] && return 1
	return 0
}

getpeerinfo_create() {
# create a chart with 3 dimensions
        
DATA="$(< ~/GRC-Netdata/getpeerinfo/peerinfo_versions.txt)" #names from names$

echo "CHART GRC.PeerVersions '' 'Gridcoin peer versions' 'client version' Versions GRC.PeerVersions line $((load_priority + 1)) $getpeerinfo_update_every"
 for Line in $DATA; do
  currentLine="$Line"
  stringarray=($currentLine)
  echo "DIMENSION ${stringarray[0]} '${stringarray[1]}' absolute 1 1"
 done
 return 0
}



getpeerinfo_update() {
# write the result of the work.
DATA="$(< ~/GRC-Netdata/getpeerinfo/peerinfo_versions.txt)" #names from names$

BEGIN GRC.PeerVersions
 for Line in $DATA; do
  currentLine="$Line"
  stringarray=($currentLine)
  echo "SET ${stringarray[0]} '${stringarray[2]}' absolute 1 1
 done
END
 return 0
}
