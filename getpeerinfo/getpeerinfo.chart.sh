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

	#if [ ${getpeerinfo_update_every} -lt 10 ]
	#	then
		# there is no meaning for shorter than 5 seconds
		# the kernel changes this value every 5 seconds
	#	getpeerinfo_update_every=10
	#fi

	#[ ${getpeerinfo_enabled} -eq 0 ] && return 1
	return 0
}

getpeerinfo_create() {
#
echo "CHART GRC.PeerVersions '' 'Gridcoin peer versions' 'client version' Versions GRC.PeerVersions line $((load_priority + 1)) $getpeerinfo_update_every"
# cat "/root/GRC-Netdata/getpeerinfo/peerinfo_versions.txt"|while read line; do
#  currentLine="$line"
#  stringarray=($currentLine)
#  echo "DIMENSION ${stringarray[0]} '${stringarray[1]}' absolute 1 1"
# done
cat "/root/GRC-Netdata/getpeerinfo/dimensions_peerinfo_versions.txt"
 return 0
}

getpeerinfo_update() {
# write the result of the work.

cat "/root/GRC-Netdata/getpeerinfo/set_peerinfo_versions"

#echo "BEGIN GRC.PeerVersions"
# cat "/root/GRC-Netdata/getpeerinfo/peerinfo_versions.txt"|while read line; do
#  currentLine="$line"
#  stringarray=($currentLine)
#  echo "SET ${stringarray[0]} '${stringarray[2]}'"
# done
#echo "END"
 return 0
}
