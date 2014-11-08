#!/bin/sh

# Created by Nicolas Stampf <nicolas.stampf+synoindexer@gmail.com>

# Change these to reflect your own configuration
VIDEODIR="/volume1/video"

# change this one to reject some filenames from the find. See man find(1) for usage. Used after a "\!"
IGNORE="-name '*download'"

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
Usage: $0 [-d dir] [-h] [-i index_cmd] [-n] [-r file] [-t] 
	-d dir	: use Video directory 'dir' instead of default $VIDEODIR
	-h	: show this help
	-i index_cmd	: use 'index_cmd' instead of default $INDEXCMD (must accept -a <file> as argument)
	-n	: do NOT change the timestamp of reference file $TIMESTAMPFILE
	-r file	: set reference file to 'file' instead of default $TIMESTAMPFILE
	-t	: test only, echoes the commands, don't run them
	-v	: verbose (show files indexed)
EOF
	exit 0
}

TEST=""
NOT=0
VERBOSE=""

while getopts "d:hi:nr:tv" opt; do
	case $opt in 
	d) VIDEODIR=$OPTARG;;
	h) usage;;
	i) INDEXCMD=$OPTARG;;
	n) NOT=1;;
	r) TIMESTAMPFILE=$OPTARG;;
	t) TEST=echo;;
	v) VERBOSE="-print0";;
	\?) usage;;
	esac
done

FINDEXEC="$INDEXCMD -a {}"

if [ ! -x $INDEXCMD ]; then
	echo "Error: '$INDEXCMD' doesn't exist, unable to run script."
	exit 1
fi

if [ ! -e $TIMESTAMPFILE ]; then
	echo "Error: $TIMESTAMPFILE doesn't exist. Create it first and predate it using 'touch -d XXX $TIMESTAMPFILE'."
	exit 1
fi

if [ ! -d $VIDEODIR ]; then
	echo "Error: $VIDEODIR doesn't exist. Use option '-d dir' to create it."
	exit 1
fi

$TEST find $VIDEODIR -type f -newer $TIMESTAMPFILE \! $IGNORE $VERBOSE -exec $FINDEXEC \;

if [ "x$NOT" != "x0" ]; then
	echo "$TIMESTAMPFILE not touched."
else
	touch $TIMESTAMPFILE
fi

