#!/bin/sh

# Created by Nicolas Stampf <nicolas.stampf+synoindexer@gmail.com>

# Change these to reflect your own configuration
VIDEODIR="/volume1/video"

# You shouldn't touch anything after this line
TIMESTAMPFILE="/var/run/nst-synoindex.timestamp"
INDEXCMD="/usr/syno/bin/synoindex"

### Don't change absolutely anything below this line

if [ `/usr/bin/id -u` != 0 ]; then
	echo "Error: must be run with root privileges."
	exit 1
fi

usage() {
	cat <<EOF
Usage: $0 [-c] [-d dir] [-h] [-i index_cmd] [-n] [-r file] [-t] 
	-c	: create reference file $TIMESTAMPFILE
	-d dir	: use Video directory 'dir' instead of default $VIDEODIR
	-f n	: force indexing of files since last 'n' days
	-h	: show this help
	-i index_cmd	: use 'index_cmd' instead of default $INDEXCMD (must accept -a <file> as argument)
	-n	: do NOT change the timestamp of reference file $TIMESTAMPFILE
	-r file	: set reference file to 'file' instead of default $TIMESTAMPFILE
	-s	: silent mode (otherwise, indexed files are shown)
	-t	: test only, echoes the commands, don't run them
EOF
	exit 0
}

TEST=0
NOT=0
VERBOSE="-print"
DAYS="zzz"
CREATE="no"

while getopts "cd:f:hi:nr:st" opt; do
	case $opt in 
	c) CREATE="yes";;
	d) VIDEODIR=$OPTARG;;
	f) DAYS=$OPTARG;;
	h) usage;;
	i) INDEXCMD=$OPTARG;;
	n) NOT=1;;
	r) TIMESTAMPFILE=$OPTARG;;
	s) VERBOSE="";;
	t) TEST=1;;
	\?) usage;;
	esac	
done

if [ $TEST = 1 ]; then
	FINDEXEC=""
	VERBOSE="-print"
else
	FINDEXEC="-exec $INDEXCMD -a {} \;"
fi

# check existence of synoindex
if [ ! -x $INDEXCMD ]; then
	echo "Error: '$INDEXCMD' doesn't exist, unable to run script."
	exit 1
fi

# create reference file is asked for. If -t, then echo instead of doing it.
if [ $CREATE = "yes" ]; then
	$TEST touch $TIMESTAMPFILE
fi

# if not forced days, then check existence of reference file
if [ "$DAYS" = "zzz" ]; then
	if [ ! -e $TIMESTAMPFILE ]; then
		echo "Error: $TIMESTAMPFILE doesn't exist. Create it first using option '-c'."
		exit 1
	fi
fi

# check existence of video directory
if [ ! -d $VIDEODIR ]; then
	echo "Error: $VIDEODIR doesn't exist. Use option '-d dir' to create it."
	exit 1
fi

# if not forced days, use reference file, otherwise use -mtime -$DAYS for find(1).
if [ "$DAYS" = "zzz" ]; then
	/usr/bin/find $VIDEODIR -type f -newer $TIMESTAMPFILE ! -regex '.*@eaDir.*' ! -name '*crdownload' $VERBOSE $FINDEXEC
else
	/usr/bin/find $VIDEODIR -type f -mtime -$DAYS ! -regex '.*@eaDir.*' ! -name '*crdownload' $VERBOSE $FINDEXEC
fi

# if ask to NOT touch, then, well, do nothing (echo), instead (default): touch reference file.
if [ $NOT != "0" ]; then
	echo "$TIMESTAMPFILE not touched."
else
	touch $TIMESTAMPFILE
fi

