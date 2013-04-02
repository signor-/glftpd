#!/bin/bash
###############################################################################
# this script outputs EOM stats to a txt file.
# use sig-eom.sh to run this script at the end of each month.
###############################################################################

# site name.
sitename="site"
# users to ignore? '-e <user>' for each user to ignore.
bncacc="-e bncer -e glftpd -e siteop"
# number to list.
numtolist="100"
# glftpd path.
glftpd='/glftpd'
# glftpd config file.
glftpd_conf='/glftpd/etc/glftpd.conf'
# where to output the stats.txt file, make sure this directory exists!
stats='/glftpd/site/PRIVATE/SITEOP/STATS'

###############################################################################
# don't edit below here!
###############################################################################

month=`date +%B`
year=`date +%Y`

cd $glftpd/bin
echo "$sitename stats for $month $year ->" > $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -m -u -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -m -d -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -M -u -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -M -d -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
