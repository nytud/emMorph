#!/bin/bash
if [ "$hpldir" == "" ]; then export hpldir=..; fi
source "$hpldir"/mak/setroot.sh
mkdir $hpldir/gen
export APP=$1
if [ "$1" == "." ]; then export APP=; fi
shift
export logfile="$humlogdir"make"$GEN""$APP".log
cd $hpldir/gen
make -rR -f "$hpldir"/mak/uhun.make 2>"$logfile" $1 

source $hpldir/mak/errchk.sh

