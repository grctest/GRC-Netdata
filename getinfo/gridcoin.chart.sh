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
cat <<EOF
CHART Gridcoin.connections '' "Gridcoin client connections" "# of connections" Connections gridcoin.connections line $((load_priority + 1)) $gridcoin_update_every
DIMENSION connections 'Connected' absolute 1 1
CHART Gridcoin.blocks '' "Gridcoin blocks" "# of blocks" Blocks gridcoin.blocks line $((load_priority + 1)) $gridcoin_update_every
DIMENSION blocks 'Blocks' absolute 1 1
CHART Gridcoin.superblock_age '' "Gridcoin superblock age" "hours" Superblock_Age gridcoin.superblock_age line $((load_priority + 1)) $gridcoin_update_every
DIMENSION superblock_age 'Hours' absolute 1 3600
CHART Gridcoin.money '' "Gridcoin coin supply" "Total coin supply" Coin_Supply gridcoin.money line $((load_priority + 1)) $gridcoin_update_every
DIMENSION moneysupply 'Coins' absolute 1 1
CHART Gridcoin.difficulty '' "Gridcoin difficulties" "Difficulty" Difficulties gridcoin.difficulty line $((load_priority + 1)) $gridcoin_update_every
DIMENSION difficultypos 'PoS' absolute 1 1
DIMENSION difficultypow 'PoW' absolute 1 1
DIMENSION difficultypor 'PoR' absolute 1 1
CHART Gridcoin.stake_weight '' "Gridcoin stake weight" "# of coins staking" Network_Weight gridcoin.stake_weight line $((load_priority + 1)) $gridcoin_update_every
DIMENSION net_weight 'Net Weight' absolute 1 1
CHART Gridcoin.continent '' "Gridcoin client locations" "# of connections from" Locations gridcoin.continent stacked $((load_priority + 1)) $gridcoin_update_every
DIMENSION northamerica 'N. America' absolute 1 1
DIMENSION southamerica 'S. America' absolute 1 1
DIMENSION europe 'Europe' absolute 1 1
DIMENSION africa 'Africa' absolute 1 1
DIMENSION asia 'Asia' absolute 1 1
DIMENSION oceania 'Oceania' absolute 1 1
DIMENSION other 'Other' absolute 1 1
CHART Gridcoin.timeoffset '' "Gridcoin node time offset" "minutes" Time_Offset gridcoin.timeoffset line $((load_priority + 1)) $gridcoin_update_every
DIMENSION timeoffset 'Delta' absolute 1 1
CHART Gridcoin.transactions '' "Gridcoin transactions" "# of transactions" Transactions gridcoin.transactions line $((load_priority + 1)) $gridcoin_update_every
DIMENSION currentblocktx 'TX current block' absolute 1 1
DIMENSION pooledtx 'TX pooled' absolute 1 1
CHART Gridcoin.rsa '' "Gridcoin research savings account" "GRC" RSA gridcoin.rsa line $((load_priority + 1)) $gridcoin_update_every
DIMENSION paid_daily 'Paid daily' absolute 1 1
DIMENSION paid_14days 'Paid 14 days' absolute 1 1
DIMENSION exp_daily 'Expected daily' absolute 1 1
DIMENSION exp_14days 'Expected 14 days' absolute 1 1
DIMENSION rsa_owed 'RSA Owed' absolute 1 1
CHART Gridcoin.fulfillment '' "Gridcoin fulfillment" "percent" Fulfillment gridcoin.fulfillment line $((load_priority + 1)) $gridcoin_update_every
DIMENSION fulfillment '% Fulfilled' absolute 1 1
CHART Gridcoin.magnitude '' "Gridcoin magnitude" "mag" Magnitude gridcoin.magnitude stacked $((load_priority + 1)) $gridcoin_update_every
DIMENSION magnitude 'Magnitude' absolute 1 1
DIMENSION dpor_weight 'DPoR Weight' absolute 1 100000000
CHART Gridcoin.magnitude_unit '' "Gridcoin magnitude unit" "coins per unit mag" Magnitude_Unit gridcoin.magnitude_unit line $((load_priority + 1)) $gridcoin_update_every
DIMENSION magnitude_unit 'Mag Unit' absolute 1 1000
CHART Gridcoin.lifetime '' "Gridcoin lifetime performance" "GRC" Lifetime gridcoin.lifetime stacked $((load_priority + 1)) $gridcoin_update_every
DIMENSION lifetime_interest 'Interest' absolute 1 1
DIMENSION lifetime_research 'Research' absolute 1 1
CHART Gridcoin.lifetime_ppd '' "Gridcoin lifetime payments per day" "GRC" Lifetime_Average gridcoin.lifetime_ppd line $((load_priority + 1)) $gridcoin_update_every
DIMENSION lifetime_ppd 'PPD' absolute 1 1
EOF

        return 0
}

gridcoin_update() {
        GRCPATH="$(getent passwd gridcoin | cut -d: -f6)/.GridcoinResearch"
        GRCINFO="${GRCPATH}/getinfo.json"
        GRCSTAKING="${GRCPATH}/getstakinginfo.json"
        GRCMINING="${GRCPATH}/getmininginfo.json"
        GRCMAGNITUDE="${GRCPATH}/listmymagnitude.json"
        GRCRSA="$GRCPATH/listrsaweight.json"
        GRCSB="${GRCPATH}/executesuperblockage.json"
        GRCGEO="${GRCPATH}/geooutput.json"
        connections=$(jq '.connections' $GRCINFO)
        blocks=$(jq '.blocks' $GRCINFO)
        superblock_age=$(jq -r '.[1]."Superblock Age"' $GRCSB)
        moneysupply=$(jq '.moneysupply' $GRCINFO)
        difficulty_pow=$(jq '.difficulty["proof-of-work"]' $GRCMINING)
        difficulty_pos=$(jq '.difficulty["proof-of-stake"]' $GRCMINING)
        difficulty_por=$(jq '.difficulty["proof-of-research"]' $GRCMINING)
        staking_weight=$(jq '.netstakeweight' $GRCSTAKING)
        dpor_weight=$(jq '.weight' $GRCSTAKING)
        geoNA=$(jq -r '.[].contNA' $GRCGEO)
        geoSA=$(jq -r '.[].contSA' $GRCGEO)
        geoEU=$(jq -r '.[].contEU' $GRCGEO)
        geoAF=$(jq -r '.[].contAF' $GRCGEO)
        geoAS=$(jq -r '.[].contAS' $GRCGEO)
        geoOC=$(jq -r '.[].contOC' $GRCGEO)
        geoOT=$(jq -r '.[].contOT' $GRCGEO)
        timeoffset=$(jq -r '.timeoffset' $GRCINFO)
        currentblocktx=$(jq -r '.currentblocktx' $GRCSTAKING)
        pooledtx=$(jq -r '.pooledtx' $GRCSTAKING)
        paid_daily=$(jq -r '.[1]."Daily Paid"' $GRCMAGNITUDE)
        paid_fortnightly=$(jq -r '.[1]."Research Payments (14 days)"' $GRCMAGNITUDE)
        exp_daily=$(jq -r '.[1]."Expected Earnings (Daily)"' $GRCMAGNITUDE)
        exp_fortnightly=$(jq -r '.[1]."Expected Earnings (14 days)"' $GRCMAGNITUDE)
        rsa_owed=$(jq -r '.[1]."RSA Owed"' $GRCRSA)
        fulfillment=$(jq -r '.[1]."Fulfillment %"' $GRCMAGNITUDE)
        magnitude=$(jq -r '.[1]."Magnitude (Last Superblock)"' $GRCMAGNITUDE)
        magnitude_unit=$(jq -r '."Magnitude Unit"' $GRCMINING | sed -r "s/0?\.//")
        lifetime_interest=$(jq -r '.[1]."CPID Lifetime Interest Paid"' $GRCMAGNITUDE)
        lifetime_research=$(jq -r '.[1]."CPID Lifetime Research Paid"' $GRCMAGNITUDE)
        lifetime_avg_mag=$(jq -r '.[1]."CPID Lifetime Avg Magnitude"' $GRCMAGNITUDE)
        lifetime_ppd=$(jq -r '.[1]."CPID Lifetime Payments Per Day"' $GRCMAGNITUDE)
        # write the result of the work.
        cat <<VALUESEOF
BEGIN Gridcoin.connections
SET connections = $connections
END
BEGIN Gridcoin.blocks
SET blocks = $blocks
END
BEGIN Gridcoin.superblock_age
SET superblock_age = $superblock_age
END
BEGIN Gridcoin.money
SET moneysupply = $moneysupply
END
BEGIN Gridcoin.difficulty
SET difficultypos = $difficulty_pos
SET difficultypow = $difficulty_pow
SET difficultypor = $difficulty_por
END
BEGIN Gridcoin.stake_weight
SET net_weight = $staking_weight
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
BEGIN Gridcoin.timeoffset
SET timeoffset = $timeoffset
END
BEGIN Gridcoin.transactions
SET currentblocktx = $currentblocktx
SET pooledtx = $pooledtx
END
BEGIN Gridcoin.rsa
SET paid_daily = $paid_daily
SET paid_14days = $paid_fortnightly
SET exp_daily = $exp_daily
SET exp_14days = $exp_fortnightly
SET rsa_owed = $rsa_owed
END
BEGIN Gridcoin.fulfillment
SET fulfillment = $fulfillment
END
BEGIN Gridcoin.magnitude
SET magnitude = $magnitude
SET dpor_weight = $dpor_weight
END
BEGIN Gridcoin.magnitude_unit
SET magnitude_unit = $magnitude_unit
END
BEGIN Gridcoin.lifetime
SET lifetime_interest = $lifetime_interest
SET lifetime_research = $lifetime_research
END
BEGIN Gridcoin.lifetime_ppd
SET lifetime_ppd = $lifetime_ppd
END
VALUESEOF

        return 0
}
