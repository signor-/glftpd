#!/bin/bash
###############################################################################
# crontab this script to run daily 5 minutes before midnight.
# 55 23 * * *     /glftpd/bin/sig-eom.sh >/dev/null 2>&1
#
# the script will check todays date against the last day of the current month,
# if it matches it will execute all your listed EOM (end of month) scripts.
###############################################################################

EOMRUN="
/glftpd/bin/sig-monthstats.sh
"

###############################################################################
# don't edit below here!
###############################################################################

month=$(cal -h | awk -v nr=1 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }' | tr -s '[:blank:]' '\n' | head -1)
lastday=$(cal -h | awk -v nr=1 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }' | tr -s '[:blank:]' '\n' | tail -1)
today=$(date +%d)

if [ "$today" == "$lastday" ]; then
	for EOM in $EOMRUN; do
		$EOM >/dev/null 2>&1
	done
fi