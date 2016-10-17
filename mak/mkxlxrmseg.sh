#!/bin/bash
export X=X
export BASELEX=
export S=X
export LEX=genX.lx2

export hpldir=..
source "$hpldir/mak/setroot.sh"
export EXCL="\"-excl=restr:[gGm]+|infsfx.*(?:IN|EX|AD)L\"" 
export SRFONLY=-rmseg

logfile="$humlogdir""makeXLX$GUESS$x$s.log"
cd $hpldir/gen
make -rR -f $hpldir/mak/xlxu.make 2> "$logfile" $1 

source $hpldir/mak/errchk.sh

