#!/bin/bash

URL=https://pad.riseup.net/p
PAD=B7VT41OAfOe3
FORMAT=txt
WGET_OPTS="-N --no-check-certificate -nd"
LOCALDIR=(~/etherpad-saver/)

wget $WGET_OPTS -P $LOCALDIR $URL/$PAD/export/$FORMAT

(
	cd $LOCALDIR
	git update-index -q --refresh
	if ! git diff-index --quiet HEAD --; then
		git add .
		git commit -a -m"Change detected - automatic commit"
	fi
)

