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

HexText="`basename $1 | sed 's/asm$/mem/'`"
# Remove np to allow pseudoinstructions
mars nc mc CompactTextAtZero a dump '.text' HexText $HexText $1
if [ -d $OUTDIR ]; then
	cp $HexText $OUTDIR
fi
echo "Build finished, stored to: $HexText"
