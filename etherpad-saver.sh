#!/bin/bash

URL=https://pad.riseup.net/p
PAD=B7VT41OAfOe3
FORMAT=txt
WGET_OPTS="-N --no-check-certificate -nd"
LOCALDIR=(~/etherpad-saver/)

if [ ! -d $LOCALDIR ] ; then
	mkdir -p $LOCALDIR
fi

wget $WGET_OPTS -P $LOCALDIR $URL/$PAD/export/$FORMAT

(
	cd $LOCALDIR

	if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
		git init -q
	fi

	git update-index -q --refresh

	if ! git diff-index --quiet HEAD -- > /dev/null 2>&1 ; then
		git add .
		git commit -a -m"Change detected - automatic commit"
	fi
)

