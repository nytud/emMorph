ERR=$?
if [ $ERR -gt 0 ]; then
echo There were errors in ${0##*/}... see $logfile
echo There were errors in ${0##*/}... >>"$logfile"
else
echo Done ${0##*/}
echo Done ${0##*/} >>"$logfile"
fi
exit $ERR
