#!/bin/bash
if [ "$hpldir" == "" ]; then export hpldir=..; fi
source "$hpldir"/mak/setroot.sh
export logfile="$humlogdir"make"$GEN""$APP"hfst.log

cd $hpldir/lexc
make -rR -f "$hpldir"/mak/hu-hfst.make 2>"$logfile"

source $hpldir/mak/errchk.sh

