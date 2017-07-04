#!/bin/bash

if pgrep "gridcoin" > /dev/null
then
    GRCAPP="$(which gridcoind)"
    GRCPATH="$(getent passwd gridcoin | cut -d: -f6)/.GridcoinResearch"
    "$GRCAPP" getinfo > "$GRCPATH"/getinfo.tmp && mv -f "$GRCPATH"/getinfo.tmp "$GRCPATH"/getinfo.json
    "$GRCAPP" getstakinginfo > "$GRCPATH"/getstakinginfo.tmp && mv -f "$GRCPATH"/getstakinginfo.tmp "$GRCPATH"/getstakinginfo.json
    else
    exit 1
fi
