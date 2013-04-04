#!/bin/bash - 

# place this script in your /glftpd/etc folder and run it.
# this will retouch the passwd file to mask all users groups to 'glftpd'
#
# you only need to run this script once!

touch passwd.ren
echo "backing up passwd file"
cp passwd passwd.ren.backup
echo "masking existing users group"
cat passwd | while read line; do
awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> passwd.ren
done
echo "masking complete!"