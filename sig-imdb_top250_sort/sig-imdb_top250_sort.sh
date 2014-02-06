#!/bin/bash
###############################################################################
# script to sort imdb top 250 movies within a directory.
#
# for this script to function, you must run, manually do...
# wget -q -O "imdbtop250.list" http://www.imdb.com/chart/top
# in a shell prompt where ever this script is placed, eg in /glftpd/bin
# so that the script has a top 250 movie list to refer to.
#
# this script will search and rename you movie folders with reference to the
# top 250 imdb chart.
#
# ./MOVIE_576P/The.Shawshank.Redemption.1994.iNTERNAL.DVDrip.XViD-DCA
# will become
# ./MOVIE_576P/IMDB_001-The.Shawshank.Redemption.1994.iNTERNAL.DVDrip.XViD-DCA
#
# if a movie in the list is not found inside the $MOVIEDIR, then it will mkdir
# ./MOVIE_576P/IMDB_001-The.Shawshank.Redemption.1994.MISSING.PLEASE.UPLOAD
###############################################################################
# imdb top 250 directory
MOVIEDIR="/glftpd/site/ARCHIVE/MOVIE/MOVIE_576P"
###############################################################################
# don't edit below here!
###############################################################################

TOP250LIST=$(cat imdbtop250.list | sed 's/<[^>]\+>/ /g' | tr "\n" " " | tr -s " " | tr "\r" "\n" | sed -e 's/.* Rank Rating Title Votes \(1\. [0-9]\.[0-9] .* ([0-9]\{4\}) [0-9]\{1,3\}\,[0-9]\{1,3\}.*250\. [0-9]\.[0-9] .* ([0-9]\{4\}) [0-9]\{1,3\}\,[0-9]\{1,3\}\) The formula for calculating the Top Rated 250.*/\1/' | grep -Ei "^1. [0-9]\.[0-9]" | sed 's/\([0-9]\{1,3\}\. [0-9]\.[0-9]\)/\n\1/g' | sed 's/\&\#...\;//g' | tr -d "(" | tr -d ")")
echo "$TOP250LIST" > "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
OIFS="$IFS"
IFS='
'
for LIST in $TOP250LIST; do
	RANK=$(echo $LIST | awk '{print $1}' | tr -d ".")
	if [ "$RANK" -lt "10" ];then
		RANK="00$RANK"
	elif [ "$RANK" -ge "10" ] && [ "$RANK" -lt "100" ];then
		RANK="0$RANK"
	fi
	IMDBRATING=$(echo $LIST | awk '{print $2}')
	TITLE=$(echo $LIST | sed 's/^[0-9]\{1,3\}\. [0-9]\.[0-9] \(.*\) [0-9]\{4\}.*/\1/')
	VOTES=$(echo $LIST | awk '{print $(NF-0)}')
	YEAR=$(echo $LIST | awk '{print $(NF-1)}' | sed 's/[^0-9]//g')
	SEARCHTITLE=$(echo "$TITLE" | sed -e 's/\<[Aa]\>\|\<[Oo][Ff]\>\|\<[Tt][Hh][Ee]\>\|\<[Aa][Nn][Dd]\>//g' | sed -e 's/\-/ /g' | sed -e 's/[\.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]//g' | tr -s " " | sed 's/ /.*/g')
	MKDIRTITLE=$(echo "$TITLE" | sed -e 's/\-/ /g' | sed -e 's/[ \.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]/./g' | tr -s ".")
	FOUNDTITLE=$(ls -A "$MOVIEDIR" | grep -v "IMDB_" | grep -Eiw "^$SEARCHTITLE")
	IMDBTITLE=$(ls -A "$MOVIEDIR" | grep "IMDB_" | grep -Eiw "^IMDB_[0-9]{1,3}-$SEARCHTITLE")
	echo "[SEARCH] $SEARCHTITLE"
	if [ ! -z "$FOUNDTITLE" ]; then
		for TITLE in $FOUNDTITLE; do
			if [ -d "$MOVIEDIR/$TITLE" ]; then
				echo "[FOUND] IMDB_$RANK-$TITLE"			
				mv -f "$MOVIEDIR/$TITLE" "$MOVIEDIR/IMDB_$RANK-$TITLE"
				if [ -d "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD" ]; then
					echo "[REMOVING] IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
					rmdir "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
				fi
			fi
		done
	else
		if [ -z "$IMDBTITLE" ]; then
			if [ ! -d "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD" ]; then
				echo "[MISSING] IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
				mkdir -m755 "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
			fi
		fi
	fi
done