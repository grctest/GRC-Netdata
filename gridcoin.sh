# no need for shebang - this file is loaded from charts.d.plugin

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
# GPL v3+
#

# if this chart is called X.chart.sh, then all functions and global variables
# must start with X_

# _update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
example_update_every=30

# the priority is used to sort the charts on the dashboard
# 1 = the first chart
example_priority=1

# to enable this chart, you have to set this to 12345
# (just a demonstration for something that needs to be checked)
# Enabled the chart!
example_magic_number=12345

# global variables to store our collected data
# remember: they need to start with the module name example_
connections=
powd=
posd=

example_get() {
	# do all the work to collect / calculate the values
	# for each dimensioncat getinfo.json | jq '.connections'
	#
	# Remember:
	# 1. KEEP IT SIMPLE AND SHORT
	# 2. AVOID FORKS (avoid piping commands)
	# 3. AVOID CALLING TOO MANY EXTERNAL PROGRAMS
	# 4. USE LOCAL VARIABLES (global variables may overlap with other modules)

	connections==$(cat getinfo.json | jq '.connections')
	powd==$(cat getinfo.json | jq '.difficulty' | jq '."proof-of-work"')
	posd==$(cat getinfo.json | jq '.difficulty' | jq '."proof-of-stake"')

	# this should return:
	#  - 0 to send the data to netdata
	#  - 1 to report a failure to collect the data

	return 0
}

# _check is called once, to find out if this chart should be enabled or not
example_check() {
	# this should return:
	#  - 0 to enable the chart
	#  - 1 to disable the chart

	# check something
	[ "${example_magic_number}" != "12345" ] && error "manual configuration required: you have to set example_magic_number=$example_magic_number in example.conf to start example chart." && return 1

	# check that we can collect data
	example_get || return 1

	return 0
}

# _create is called once, to create the charts
example_create() {
	# create the chart with 3 dimensions
	#
	# "random random" will likely need to be changed!
	# WIKI FOR NEXT STEP: https://github.com/firehol/netdata/wiki/External-Plugins#chart
	cat <<EOF
CHART GRC.Monitor '' "Monitoring GRC Connections and difficulties" random random stacked $((example_priority)) $example_update_every
DIMENSION Connections '' percentage-of-absolute-row 1 1
DIMENSION Proof-of-Work-Difficulty '' percentage-of-absolute-row 1 1
DIMENSION Proof-of-Stake-Difficulty '' percentage-of-absolute-row 1 1
EOF

	return 0
}

# _update is called continiously, to collect the values
example_update() {
	# the first argument to this function is the microseconds since last update
	# pass this parameter to the BEGIN statement (see bellow).

	example_get || return 1

	# write the result of the work.
	cat <<VALUESEOF
BEGIN GRC.Monitor $1
SET Connections = $connections
SET Proof-of-Work-Difficulty = $powd
SET Proof-of-Stake-Difficulty = $posd
END
VALUESEOF

	return 0
}
