etherpad-saver
==============
Many public etherpad instances delete pads after a certain time period.
Instances can become flaky, delete pads at random or even vanish completely.
Sometimes malicious users delete everything you typed and the timeline feature
screws up so you can't get it back. So I wrote this script to grab copies of an
etherpad page (or similar) and keep track of changes using git. I run it from
cron when I'm working on an important pad to make sure I don't lose anything.

Usage
-----
1. mkdir ~/etherpad-saver
2. cd ~/etherpad-saver
3. git init

4. Edit etherpad-saver.sh with the URL you wish to save (hint: grab the "export
   as text" URL from the etherpad)

5. chmod +x etherpad-saver.sh
6. Run etherpad-saver.sh

Scheduling snapshots
--------------------
Run crontab -e and append the following line (or similar):

*/10 * * * * /home/user/path/to/etherpad-saver.sh > /dev/null 2>&1

This will run the script every 10 minutes. Nothing happens if the pad hasn't
changed. If it has changed the new version will be downloaded and committed to
the git repository.
