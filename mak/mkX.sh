#!/bin/bash

if [ "$hpldir" == "" ]; then export hpldir=..; fi
export bsort="$hpldir/pl/generic"
export ANA=1
export BIT2MTX=1
export METADICT=metadict
export GSFX=X

bash "$hpldir/mak/mk1.sh" X xlx

