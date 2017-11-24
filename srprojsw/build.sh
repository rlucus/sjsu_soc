#!/bin/bash
if [ ! "$OUTDIR" ]; then
	OUTDIR="/Users/kmwetles/vm_shared"
fi

if ! which mars > /dev/null; then
	echo "MARS runtime not set up"
	exit 1
fi

if [[ ! "$1" ]]; then
	echo "Usage: $0 [source]"
	exit 2
fi

HexText="$OUTDIR/`basename $1 | sed 's/asm$/mem/'`"
mars nc np mc CompactTextAtZero a dump '.text' HexText $HexText $1
echo "Build finished, stored to: $HexText"
