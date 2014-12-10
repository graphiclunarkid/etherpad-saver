#!/bin/bash
#
# Automatic download of a list of pads where there urls are containted in the file list_pad.txt (one by line)
#

FORMAT=txt
WGET_OPTS="-N --no-check-certificate -nd"
LOCALDIR=(~/etherpad-saver/)  # edit this line to match where you want to have your data saved
WGET="/usr/bin/wget"

if [ ! -d $LOCALDIR ] ; then
	mkdir -p $LOCALDIR
fi

#Test internet connection. Prevent erasure of the files if there is no.
$WGET -q --tries=20 --timeout=10 http://www.seeks.fr -O /tmp/there_is_an_internet_connection &> /dev/null
if [ ! -s /tmp/there_is_an_internet_connection ] ; then
   echo "Error: No internet connectivity."
   exit 1
fi
rm /tmp/there_is_an_internet_connection

# download each of the pads
# url of the pads are contained on the file list_pad.txt
#
for line in $(cat list_pad.txt)          
do          
   URL=$(echo $line | sed s,/[^/]*$,,)
   CLEAN_URL=$(echo $line | tr '/' '\')  # replace the "/" in the url by "\" for a *nix compatible filename
   PAD=$(echo $line | sed s,^.*/,,)

   echo $URL
   echo $CLEAN_URL
   echo $PAD

   if [[ $URL =~ .*etherpad.* ]]; then
      wget $WGET_OPTS -P $LOCALDIR $URL/ep/pad/export/$PAD/latest?format=$FORMAT -O $LOCALDIR$CLEAN_URL.$FORMAT
   else  # other pads than might use other url schema (like the framapad)
      wget $WGET_OPTS -P $LOCALDIR $URL/$PAD/export/$FORMAT -O $LOCALDIR$CLEAN_URL.$FORMAT
   fi
	
   	(
		cd $LOCALDIR

		if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
			git init -q
		fi

		git update-index -q --refresh

#		if ! git diff-index --quiet HEAD -- > /dev/null 2>&1 ; then
#			git add .
#			git commit -a -m"$PAD Change detected - automatic commit"
#		fi

		git add .
		git commit -a -m"$PAD Change detected - automatic commit"

      )
	

done          



