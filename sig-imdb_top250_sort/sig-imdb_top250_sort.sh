#!/bin/bash
###############################################################################
# script to sort imdb top 250 movies within a directory. updated 2014-03-17.
#
# this script will search and rename your movie folders with reference to the
# imdb top 250 list. if the top 250 list ranking has changed, then the script
# will update your movie folders to the correct ranking. the script processes
# titles in alphabetical order, not by imdb rank.
#
# ./IMDB_TOP_250/The.Shawshank.Redemption.1994.iNTERNAL.DVDrip.XViD-DCA
# will become
# ./IMDB_TOP_250/IMDB_001-The.Shawshank.Redemption.1994.iNTERNAL.DVDrip.XViD-DCA
#
# if a movie in the list is not found inside the $MOVIEDIR, then it will mkdir
# ./IMDB_TOP_250/IMDB_001-The.Shawshank.Redemption.1994.MISSING.PLEASE.UPLOAD
###############################################################################
# imdb top 250 directory
MOVIEDIR="/glftpd/site/ARCHIVE/MOVIE/IMDB_TOP_250"
###############################################################################
# don't edit below here!
###############################################################################

if [ -f "imdbtop250.list" ]; then
	echo "[IMDB] DELETING THE OLD IMDB TOP 250 LIST AND DOWNLOADING A NEW ONE"
	rm -f "imdbtop250.list"
	wget -q --referer="http://www.google.com" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6" --header="Accept-Language: en-US,en;q=0.5" -O "imdbtop250.list" http://akas.imdb.com/chart/top
fi

TOP250LIST=$(cat imdbtop250.list | sed 's/<[^>]\+>/ /g' | tr -s " " | tr "\r" "\n" | grep -E "^ [[:digit:]]{1,3}\. .* \([[:digit:]]{4}\)" | sed 's/ \([0-9]\{1,3\}\.\) \(.*\) [(]\(.*\)[)]/\1 \2 \3/g' | iconv -f UTF8 -t US-ASCII//TRANSLIT | sed 's/^\([0-9]\.\)/00\1/g' | sed 's/^\([0-9]\{2\}\.\)/0\1/g')

if [ -z "$TOP250LIST" ]; then
	echo "[IMDB] ERROR WITH PARSING TOP 250 LIST, EXITING"
	exit 0
else
	NOW=$(date "+%Y-%m-%d")
	NOWDIR="[ IMDB TOP 250 LIST - $NOW ]"
	OLDDIR=$(ls -A "$MOVIEDIR" | grep -E "\[ IMDB TOP 250 LIST \- .* \]")
	if [ ! -z "$OLDDIR" ]; then
		echo "[IMDB] DELETING OLD HEADER -> $OLDDIR"
		rmdir "$MOVIEDIR/$OLDDIR"
	fi
	if [ ! -d "$MOVIEDIR/$NOWDIR" ]; then
		echo "[IMDB] CREATING NEW HEADER -> $NOWDIR"
		mkdir -m755 "$MOVIEDIR/$NOWDIR"
	fi
	echo "$NOWDIR" > "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
	echo "" >> "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
	echo "$TOP250LIST" >> "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
fi

TOP250LIST=$(echo "$TOP250LIST" | sort -t . -k 2)

OIFS="$IFS"
IFS=$'\n'

for LIST in $TOP250LIST; do
	RANK=$(echo $LIST | awk '{print $1}' | tr -d ".")
	TITLE=$(echo $LIST | sed 's/^[0-9]\{1,3\}\. \(.*\) [0-9]\{4\}.*/\1/' | sed -e 's/[ \.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]/ /g' | sed -e "s/[\']//g" | tr -s " ")
	YEAR=$(echo $LIST | awk '{print $(NF-0)}' | sed 's/[^0-9]//g')
	SEARCHTITLE=$(echo "$TITLE" | sed -e 's/\<[Aa]\>\|\<[Oo][Ff]\>\|\<[Tt][Hh][Ee]\>\|\<[Aa][Nn][Dd]\>//g' | sed -e 's/\-/ /g' | sed -e 's/[\.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]//g' | sed -e "s/[\']//g" | tr -s " " | sed 's/ /.*/g')
	MKDIRTITLE=$(echo "$TITLE" | sed -e 's/\-/ /g' | sed -e 's/[ \.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]/./g' | sed -e "s/[\']//g" | tr -s ".")
	FOUNDTITLE=$(ls -A "$MOVIEDIR" | grep -v "IMDB_" | grep -Eiw "^$SEARCHTITLE")
	IMDBTITLE=$(ls -A "$MOVIEDIR" | grep "IMDB_" | grep -Eiw "^IMDB_[0-9]{1,3}-$SEARCHTITLE.*$YEAR")
	if [ -z "$IMDBTITLE" ]; then
		IMDBTITLE=$(ls -A "$MOVIEDIR" | grep "IMDB_" | grep -Eiw "^IMDB_[0-9]{1,3}-$SEARCHTITLE")
	fi
	if [ ! -z "$FOUNDTITLE" ]; then
		for TITLE in $FOUNDTITLE; do
			if [ -d "$MOVIEDIR/$TITLE" ]; then
				echo "[IMDB] ($RANK) FOUND -> IMDB_$RANK-$TITLE (UNRANKED, TITLE DIRECTORY RENAMED)"
				mv -f "$MOVIEDIR/$TITLE" "$MOVIEDIR/IMDB_$RANK-$TITLE"
				if [ -d "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD" ]; then
					echo "[IMDB] ($RANK) RMDIR -> IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD (TITLE FOUND, MISSING DIRECTORY DELETED)"
					rmdir "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
				fi
			fi
		done
	else
		if [ -z "$IMDBTITLE" ]; then
			if [ ! -d "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD" ]; then
				echo "[IMDB] ($RANK) MKDIR -> IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD (TITLE NOT FOUND, MISSING DIRECTORY CREATED)"
				mkdir -m755 "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
			fi
		else
			for IMDBEXISTS in $IMDBTITLE; do
				MATCHRANK=$(echo "$IMDBEXISTS" | sed -e 's/IMDB\_\([0-9]\{3\}\)\-.*/\1/')
				MATCHTITLE=$(echo "$IMDBEXISTS" | sed -e 's/IMDB\_[0-9]\{3\}\-\(.*\)/\1/')
				if [ "$RANK" == "$MATCHRANK" ]; then
					echo "[IMDB] ($RANK) FOUND -> $IMDBEXISTS (RANK MATCH, TITLE DIRECTORY SKIPPED)"
				else
					if [ -d "$MOVIEDIR/$IMDBEXISTS" ]; then
						echo "[IMDB] ($RANK) FOUND -> $IMDBEXISTS TO IMDB_$RANK-$MATCHTITLE (RANK MISMATCH, TITLE DIRECTORY RENAMED)"
						mv -f "$MOVIEDIR/$IMDBEXISTS" "$MOVIEDIR/IMDB_$RANK-$MATCHTITLE"
					fi
				fi
			done
		fi
	fi
done
