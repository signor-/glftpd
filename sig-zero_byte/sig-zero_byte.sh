#!/bin/bash
###############################################################################
# this script will remove all zero byte files in $PWD on execution. it will
# also skip *-missing files as they are exempt.
#
# edit your glftpd.conf and put in...
# site_cmd ZEROBYTE       EXEC    /bin/sig-zerobyte.sh
# custom-zerobyte         !8 *
#
# execute this script as a raw command 'site zerobyte' when inside a <REL> dir.
###############################################################################

# where are the files located? release directory.
# eg /site/<SECTION>/<DATE>/<RELEASE>/<FILE>
#      1       2        3       4        5
NNUM="5"
# where are the files located? pre directory.
# eg /site/<PREDIR>/<GROUP>/<RELEASE>/<FILE>
#      1       2        3       4        5
# eg /site/<SECTION>/<PREDIR>/<GROUP>/<RELEASE>/<FILE>
#      1       2        3       4        5        6
PNUM="6"
# pre dir path, use regex.
PDIR=".*\/\_PRE\/.*"

###############################################################################
# don't edit below here!
###############################################################################

RELPATH=$(basename $PWD)
RELDIRPWD=$(echo $PWD | sed 's/\//\n/g' | wc -l)

PREDIR=$(echo $PWD | grep -E "$PDIR")

[ -n $PREDIR ] && DIRNUMBER="$NNUM" || DIRNUMBER="$PNUM";

[ "$RELDIRPWD" = "$DIRNUMBER" ] && {
		echo "Searching for zero byte files in $RELPATH"
		ZEROBYTELIST=$(find $PWD -maxdepth 1 -type f -size 0 | egrep -iv "\-missing$")
        [ -z $ZEROBYTELIST ] && { 
                echo "Found no zero byte files. (*-missing files are exempt)" 
                exit 0 
        } || { 
                for ZEROBYTE in $ZEROBYTELIST; do
                        FILENAME=$(basename $ZEROBYTE)
                        echo "Deleted zero byte file -> $FILENAME"           
                        rm -f "$ZEROBYTE"
                done
        }
} || {
        echo "Error, not inside a release directory, exiting!"
        exit 0
}