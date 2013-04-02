#!/bin/bash
###############################################################################
# script to limit number of subdirectories in a glftpd section directory.
GLFTPDLOG="/glftpd/ftp-data/logs/glftpd.log"
#/directory/path#max diretories allowed
LIMITDIRS="
/glftpd/site/TV_576P#6000
/glftpd/site/TV_720P#4500
/glftpd/site/TV_1080P#1000
"
# dont put last slash on path!
ARCHIVEDIR="/glftpd/site/ARCHIVE/UNSORTED"
# this can only be 'archive' or 'delete' else it wont work! archive the release? or just delete it?
DELORARC="archive"
###############################################################################
# don't edit below here!
###############################################################################

for LIMITDIR in $LIMITDIRS; do
	LIMITPATH=$(echo $LIMITDIR | awk -F# '{print $1}')
	LIMITSECT=$(basename $LIMITPATH)
	LIMITNUMB=$(echo $LIMITDIR | awk -F# '{print $2}')
	LIMITCOUN=$(find $LIMITPATH -maxdepth 1 -type d -print| wc -l)
	FINALCOUN=$(($LIMITCOUN-$LIMITNUMB))
	FINALBYTE=0
	FINALBYTH=0
	[ "$DELORARC" == "delete" ] && DELORMOVE="DELETED";
	[ "$DELORARC" == "archive" ] && DELORMOVE="MOVED";
	[ -z "$DELORARC" ] && {
		echo "ERROR : Please set variable DELORARC"
		exit 0;
	}
	echo "$DELORMOVE : $LIMITPATH contains $LIMITCOUN directories (maximum $LIMITNUMB allowed)"
	if [ $FINALCOUN -gt 0 ]; then
		echo "$DELORMOVE : $LIMITPATH has $FINALCOUN directories more than the $LIMITNUMB limit"
		DELETELIST=$(ls -lA $LIMITPATH | grep -v ^total | grep ^d | awk '{print $(NF-2)"#"$(NF-1)"#"$(NF-0)}' | sort -n -r | tail -$FINALCOUN | sort -n)
		for DELETEDIR in $DELETELIST; do
			DATESTAMP=$(echo $DELETEDIR | awk -F# '{print $1}')
			TIMESTAMP=$(echo $DELETEDIR | awk -F# '{print $2}')
			RELEANAME=$(echo $DELETEDIR | awk -F# '{print $3}')
			DELSECTIO=$(basename $LIMITPATH)
			SIZEFREED=$(du -bs $LIMITPATH/$RELEANAME | awk '{print $1}')
			FINALBYTE=$(($FINALBYTE+$SIZEFREED))
			SIZEFREEH=$(($SIZEFREED/1000000))
			case $DELORARC in
				delete)
					rm -rf "${LIMITPATH}/${RELEANAME}"
				;;
				archive)
					cp -rf --preserve "${LIMITPATH}/${RELEANAME}" "${ARCHIVEDIR}/${LIMITSECT}/"
					DIFFERENCE=$(diff -qr "${LIMITPATH}/${RELEANAME}" "${ARCHIVEDIR}/${LIMITSECT}/${RELEANAME}")
					while [ ! -z "$DIFFERENCE" ]
					do
						echo "$DELORMOVE : copy of $RELEANAME unsuccessful, redoing move! (DIFF)"
						rm -rf "${ARCHIVEDIR}/${LIMITSECT}/${RELEANAME}"
						cp -rf --preserve "${LIMITPATH}/${RELEANAME}" "${ARCHIVEDIR}/${LIMITSECT}/"
						DIFFERENCE=$(diff -qr "${LIMITPATH}/${RELEANAME}" "${ARCHIVEDIR}/${LIMITSECT}/${RELEANAME}")
					done
					if [ -z "$DIFFERENCE" ]; then
						echo "$DELORMOVE : copy of $RELEANAME successful. deleting source! (DIFF)"
						rm -rf "${LIMITPATH}/${RELEANAME}"
					fi
				;;
			esac
		done
		FINALBYTH=$((FINALBYTE/1000000))
		echo ""
		if [ "$DELORARC" == "delete" ]; then
			echo "$DELORMOVE : $FINALBYTH MB in $LIMITPATH"
		fi
		if [ "$DELORARC" == "archive" ]; then
			echo "$DELORMOVE : $FINALBYTH MB from $LIMITPATH to $ARCHIVEDIR/$LIMITSECT"
		fi
		echo ""
		echo "----------------------------------------------------------------"
		echo `date "+%a %b %d %T %Y"` DIRLIMIT: \"$DELSECTIO\" \"$LIMITCOUN\" \"$LIMITNUMB\" \"$FINALBYTH\" \"$FINALCOUN\" >> $GLFTPDLOG
	else
		echo "$DELORMOVE : $LIMITPATH has $FINALCOUN directories less than the $LIMITNUMB limit... skipping!"
	fi
	
done