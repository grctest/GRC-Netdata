#!/bin/sh

if pgrep "gridcoin" > /dev/null
then
    GRCAPP='/usr/bin/gridcoinresearchd'
    GRCPATH='/home/gridcoin/.GridcoinResearch'
    "$GRCAPP" getinfo > "$GRCPATH"/getinfo.tmp && mv -f "$GRCPATH"/getinfo.tmp "$GRCPATH"/getinfo.json
    "$GRCAPP" getstakinginfo > "$GRCPATH"/getstakinginfo.tmp && mv -f "$GRCPATH"/getstakinginfo.tmp "$GRCPATH"/getstakinginfo.json
    "$GRCAPP" getdifficulty > "$GRCPATH"/difficulty.tmp && mv -f "$GRCPATH"/difficulty.tmp "$GRCPATH"/difficulty.json
    else
    exit 1
fi
