# nst-synoindexer.sh

This script will index new video files on your Synology since the last time you run it.

Useful when you drop files on your Synology through NFS since the index is not automatically updated in this case.

    Usage: ./nst-synoindexer.sh [-c] [-d dir] [-f n] [-h] [-i index_cmd] [-n] [-r file]
        -c      : create reference file $TIMESTAMPFILE
        -d dir  : use Video directory 'dir' instead of default $VIDEODIR
        -f n    : force indexing of files since last 'n' days
        -h      : show this help
        -i index_cmd    : use 'index_cmd' instead of default $INDEXCMD (must accept -a <file> as argument)
        -n      : do NOT change the timestamp of reference file $TIMESTAMPFILE
        -r file : set reference file to 'file' instead of default $TIMESTAMPFILE

