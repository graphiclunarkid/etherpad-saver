etherpad-saver
==============
Many public etherpad instances delete pads after a certain time period.
Instances can become flaky, delete pads at random or even vanish completely.
Sometimes malicious users delete everything you typed and the timeline feature
screws up so you can't get it back.

This script grabs copies of one or more etherpad pages and keeps track of
changes using git. Run it from cron when you're working on an important pad to
make sure you don't lose anything.

Pads are saved in files named according to their URL.

Usage
-----
0. Install git and wget if they're not already available
1. Edit pad_list.example.conf and save as pad_list.conf
2. Edit etherpad_saver.example.conf and save as etherpad_saver.conf
3. Run etherpad-saver.sh

Scheduling snapshots
--------------------
Run crontab -e and append the following line (or similar):

`*/10 * * * * /home/user/path/to/etherpad-saver.sh > /dev/null 2>&1`

This will run the script every 10 minutes. Nothing happens if no pads have
changed. New versions of changed pads will be downloaded and committed to the
git repository individually.

Safety
------

The config file etherpad_saver.conf is sourced by the program, so any
code written in it is executed with the rights of the program.
