#!/bin/bash

wget -N --no-check-certificate -nd -P ~/etherpad-saver/ https://pad.riseup.net/p/B7VT41OAfOe3/export/txt

(
	cd ~/etherpad-saver/
	git update-index -q --refresh
	if ! git diff-index --quiet HEAD --; then
		git add .
		git commit -a -m"Change detected - automatic commit"
	fi
)

