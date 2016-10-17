#!/bin/bash
if [ "$hpldir" == "" ]; then export hpldir=..; fi
source "$hpldir"/mak/setroot.sh
export F=huX

export logfile="$humlogdir"make"$GEN""$APP"lexc.log

make -rR -f "$hpldir"/mak/xlx2lglexc.make 2>"$logfile"

source $hpldir/mak/errchk.sh

