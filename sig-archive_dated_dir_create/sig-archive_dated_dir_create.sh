#!/bin/bash
###############################################################################
# this script creates dated/weekly dirs in archive section of site easily.
# /glftpd/site/ARCHIVE/FLAC#2011#DAY = /glftpd/site/ARCHIVE/FLAC/2011-01-01 etc
# /glftpd/site/ARCHIVE/MVID#2011#WEEK = /glftpd/site/ARCHIVE/MVID/2011-WEEK_01 etc
###############################################################################
# archive path#year#day dirs/week dirs
DIRS="
/glftpd/site/ARCHIVE/FLAC#2011#DAY
/glftpd/site/ARCHIVE/FLAC#2012#DAY
/glftpd/site/ARCHIVE/FLAC#2013#DAY
/glftpd/site/ARCHIVE/MP3#2011#DAY
/glftpd/site/ARCHIVE/MP3#2012#DAY
/glftpd/site/ARCHIVE/MP3#2013#DAY
/glftpd/site/ARCHIVE/MVID#2011#WEEK
/glftpd/site/ARCHIVE/MVID#2012#WEEK
/glftpd/site/ARCHIVE/MVID#2013#WEEK
"
###############################################################################
# don't edit below here!
###############################################################################

for DIR in $DIRS; do
	CDIR=$(echo $DIR | awk -F# '{print $1}')
	CYEAR=$(echo $DIR | awk -F# '{print $2}')
	CWHAT=$(echo $DIR | awk -F# '{print $3}')
	if [ "$CWHAT" = "DAY" ]; then
		for CMONTH in `seq 12`; do
			if [ $CMONTH -lt 10 ]; then
				CMONTH="0$CMONTH"
			fi
			CDAYS=`echo $(cal $CMONTH $CYEAR) | tail -c 3`
			for CDAY in `seq $CDAYS`; do
				if [ $CDAY -lt 10 ]; then
					CDAY="0$CDAY"
				fi
				FOLDERNAME="$CYEAR-$CMONTH-$CDAY"
				if [ -d "$CDIR/$FOLDERNAME" ]; then
					echo "- directory $CDIR/$FOLDERNAME already exists"
				else
					echo "+ directory $CDIR/$FOLDERNAME created"
					mkdir --mode=777 --parents "$CDIR/$FOLDERNAME"
				fi
			done
		done
	fi
	if [ "$CWHAT" = "WEEK" ]; then
		for CWEEK in `seq 52`; do
			if [ $CWEEK -lt 10 ]; then
				CWEEK="0$CWEEK"
			fi
			FOLDERNAME="$CYEAR-WEEK_$CWEEK"
			if [ -d "$CDIR/$FOLDERNAME" ]; then
				echo "- directory $CDIR/$FOLDERNAME already exists"
			else
				echo "+ directory $CDIR/$FOLDERNAME created"
				mkdir --mode=777 --parents "$CDIR/$FOLDERNAME"
			fi
		done
	fi
done