#!/bin/bash
#
# Automatic download of a list of pads where there urls are containted
# in the file list_pad.conf (one by line)
#

. etherpad_saver.conf

WGET_OPTS="-N --no-check-certificate -nd"
WGET="/usr/bin/wget"

# make sure LOCALDIR exists
if [ ! -d $LOCALDIR ] ; then
   mkdir -p $LOCALDIR
fi

# Initialize git if necessary
[[ -d "${LOCALDIR}/.git" ]] || git init "${LOCALDIR}"

# download each of the pads
# url of the pads are contained on the file list_pad.conf
while read line
do
    line="${line#"${line%%[![:space:]]*}"}"
    if [[ "$line"x == x || "$line" == "#"* ]]; then
        continue
    fi

   URL=$(echo $line | sed s,/[^/]*$,,)
     # replace the "/" in the url by "." for a *nix compatible filename
   CLEAN_URL=$(echo $line | tr '/' '.')
   CLEAN_URL="${CLEAN_URL##*:..}"
   PAD=$(echo $line | sed s,^.*/,,)

   if [[ $URL =~ .*etherpad.* ]]; then
      wget $WGET_OPTS -P $LOCALDIR $URL/ep/pad/export/$PAD/latest?format=$FORMAT -O $CLEAN_URL.$FORMAT.temp
   else  # other pads than might use other url schema (like the framapad)
      wget $WGET_OPTS -P $LOCALDIR $URL/$PAD/export/$FORMAT -O $CLEAN_URL.$FORMAT.temp
   fi

   #Test internet connection. Prevent erasure of the files if there is no.
   if [ "$?" = "0" ]; then
       mv $CLEAN_URL.$FORMAT.temp $LOCALDIR$CLEAN_URL.$FORMAT
   else
       rm $CLEAN_URL.$FORMAT.temp
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


done < list_pad.conf



