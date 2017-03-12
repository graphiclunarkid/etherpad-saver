#!/bin/bash
#
# Automatically download a list of etherpads where their URLs are containted in
# the file pad_list.conf (one per line)

# Source the configuration file
. etherpad_saver.conf

WGET_OPTS="--no-check-certificate -nd"
WGET=`which wget`

# Create LOCALDIR if it doesn't exist already
if [ ! -d $LOCALDIR ] ; then
        mkdir -p $LOCALDIR
fi

# Initialize git in LOCALDIR if necessary.
# Do this in a sub-shell to avoid changing the user's current working
# directory.
(
        cd $LOCALDIR

        if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
                git init -q
        fi
)

# Download each pad. URLs of the pads are contained in the file pad_list.conf
while read line
do
        # Remove leading whitespace characters from the line
        line="${line#"${line%%[![:space:]]*}"}"

        # Skip the line if it is empty.
        [ -z "$line" ] && continue

        # Skip the line if it starts with '#' - this is a comment.
        [[ $line = \#* ]] && continue

        # The URL is the portion of the line up to, but not including, the last
        # "/" character.
        URL=$(echo $line | sed s,/[^/]*$,,)

        # Replace the "/" characters in the url with "." characters for a *nix
        # compatible filename.
        FILENAME=$(echo $line | tr '/' '.')

        # Remove "https:.." from the start of the *nix compatible filename.
        FILENAME="${FILENAME##*:..}"

        # The PAD is the portion of the line after the last "/" character.
        PAD=$(echo $line | sed s,^.*/,,)

        # Some etherpad services format their APIs differently.
        if [[ $URL =~ .*etherpad.* ]]; then
                wget $WGET_OPTS -P $LOCALDIR $URL/ep/pad/export/$PAD/latest?format=$FORMAT -O $FILENAME.$FORMAT.temp
        else  # Other pads than might use other url schema (like the framapad)
                wget $WGET_OPTS -P $LOCALDIR $URL/$PAD/export/$FORMAT -O $FILENAME.$FORMAT.temp
        fi

        # If wget succeeded (exit code == 0).
        if [ "$?" = "0" ]; then
                # Move the temp file to LOCALDIR and commit it to the git repository.
                mv $FILENAME.$FORMAT.temp $LOCALDIR$FILENAME.$FORMAT
                (
                        cd $LOCALDIR
                        git update-index -q --refresh
                        git add .
                        git commit -a -m"$PAD Change detected - automatic commit"
                )
        else
                # Wget failed. Delete the temporary file.
                rm $FILENAME.$FORMAT.temp
        fi

done < pad_list.conf

