#!/bin/bash

if pgrep "gridcoin" > /dev/null
then
    GRCAPP="$(which gridcoinresearchd)"
    GRCPATH="$(getent passwd gridcoin | cut -d: -f6)/.GridcoinResearch"
    "$GRCAPP" getinfo > "$GRCPATH"/getinfo.tmp && mv -f "$GRCPATH"/getinfo.tmp "$GRCPATH"/getinfo.json
    "$GRCAPP" getstakinginfo > "$GRCPATH"/getstakinginfo.tmp && mv -f "$GRCPATH"/getstakinginfo.tmp "$GRCPATH"/getstakinginfo.json
    "$GRCAPP" getmininginfo > "$GRCPATH"/getmininginfo.tmp && mv -f "$GRCPATH"/getmininginfo.tmp "$GRCPATH"/getmininginfo.json
    "$GRCAPP" list mymagnitude > "$GRCPATH"/listmymagnitude.tmp && mv -f "$GRCPATH"/listmymagnitude.tmp "$GRCPATH"/listmymagnitude.json
    "$GRCAPP" execute superblockage > "$GRCPATH"/executesuperblockage.tmp && mv -f "$GRCPATH"/executesuperblockage.tmp "$GRCPATH"/executesuperblockage.json
    else
    exit 1
fi
