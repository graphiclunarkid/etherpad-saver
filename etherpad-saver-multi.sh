#!/bin/bash
#
# Automatic download of a list of pads where there urls are containted in the file list_pad.txt (one by line)
#

FORMAT=txt
LOCALDIR=(~/etherpad-saver/)  # edit this line to match where you want to have your data saved
WGET_OPTS="-N --no-check-certificate -nd"
WGET="/usr/bin/wget"

if [ ! -d $LOCALDIR ] ; then
   mkdir -p $LOCALDIR
fi

# download each of the pads
# url of the pads are contained on the file list_pad.txt
#
for line in $(cat list_pad.txt)          
do          
   URL=$(echo $line | sed s,/[^/]*$,,)
   CLEAN_URL=$(echo $line | tr '/' '\')  # replace the "/" in the url by "\" for a *nix compatible filename
   PAD=$(echo $line | sed s,^.*/,,)

   if [[ $URL =~ .*etherpad.* ]]; then
      wget $WGET_OPTS -P $LOCALDIR $URL/ep/pad/export/$PAD/latest?format=$FORMAT -O $CLEAN_URL.$FORMAT.temp
   else  # other pads than might use other url schema (like the framapad)
      wget $WGET_OPTS -P $LOCALDIR $URL/$PAD/export/$FORMAT -O $CLEAN_URL.$FORMAT.temp
   fi

   #Test internet connection. Prevent erasure of the files if there is no.
   if [ "$?" = "0" ]; then
	mv $CLEAN_URL.$FORMAT.temp $LOCALDIR$CLEAN_URL.$FORMAT
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



