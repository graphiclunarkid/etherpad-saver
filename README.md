etherpad-saver
==============
Many public etherpad instances delete pads after a certain time period.
Instances can become flaky, delete pads at random or even vanish completely.
Sometimes malicious users delete everything you typed and the timeline feature
screws up so you can't get it back. So I wrote this script to grab copies of an
etherpad page (or similar) and keep track of changes using git. I run it from
cron when I'm working on an important pad to make sure I don't lose anything.

Pads are saved on filenames related to their URL. For this purpose, URL "/" have 
been replaced by "\" to for valid *nix filenames. 

Usage
-----
0. Install git and wget if they're not already available
1. Edit list_pad.txt. Put pads URL (one by line).
2. Edit the LOCALDIR parameter to point to the local directory for backups
   (default is ~/etherpad-saver/)
3. Set the format to either txt or html (default is txt)
4. chmod +x etherpad-saver-multi.sh
5. Run etherpad-saver-multi.sh

Scheduling snapshots
--------------------
Run crontab -e and append the following line (or similar):

*/10 * * * * /home/user/path/to/etherpad-saver-multi.sh > /dev/null 2>&1

This will run the script every 10 minutes. Nothing happens if the pad hasn't
changed. If it has changed the new version will be downloaded and committed to
the git repository.
