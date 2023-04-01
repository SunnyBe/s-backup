#!/bin/bash

# documentation to help with usage
function show_help {
    echo "Usage: $(basename $0) [-h] [-t TARGET] [-c COMPRESSOR] FILES_OR_FOLDERS"
    echo "Compress and upload specified files or folders to a remote server or cloud storage"
    echo ""
    echo "Options:"
    echo "-h, --help          show help message and exit"
    echo "-t, --target        specify the target remote server or cloud storage (default: Google Drive)"
    echo "-c, --compressor    specify the compressor tool to use (default: tar)"
    echo ""
    echo "example: sbackup -t \"google-drive\" -c \"tar\" ~/Documents/ ~/Pictures"
}

function isToolAvailable {
    tool=$1
    echo "tool check for: $tool"
    if ! [ -x "$(command -v $tool)" ]
    then
        echo "$tool is not installed. Install $tool and try again"
        exit 1
    fi
    echo "$tool is available. Upload will start"
}

# Parse command-line options
while [[ $# -gt 0 ]]
do 
key="$1"    # get the first param and set as key

case $key in
    -h|--help)
    show_help
    exit
    ;;
    -t|--target) # if key is -t or --target, set the TARGET=next param
    TARGET="$2"
    shift # move positional parameter or argument by 2 steps to the left
    shift
    ;;
    -c|--compressor)
    COMPRESSOR="$2"
    shift
    shift
    ;;
    *) # for all remaining arguments[all files & directories after the -t ]
    FILES_OR_FOLDERS+=("$1")
    shift
    ;;
esac 
done

# End program is target is not specified
if [[ -z "$TARGET" ]] 
then
    echo "Target not specified."
    exit 1
fi

# default to tar compressor if compressor is not specified
if [[ -z "$COMPRESSOR" ]]
then
    COMPRESSOR="tar"
fi

if [[ -z "$FILES_OR_FOLDERS" ]]
then
    echo "No files were specified"
    exit 1
fi


#Compress files into backup/<direcotry>
mkdir -p backup/
DATE=$(date +"%Y%m%d%H%M%S")

if [ "$COMPRESSOR" == "tar" ]
then
    BACKUP_FILENAME="backup_$DATE.tar.gz"
    tar -czvf "backup/${BACKUP_FILENAME}" "${FILES_OR_FOLDERS[@]}"
else
    BACKUP_FILENAME="backup_$DATE.zip"
    zip backup/${BACKUP_FILENAME}
fi

# Uplaod compressed file to remote server using rsync
if [ "$TARGET" == "google-drive" ]
then
    # Upload to Google Drive using rclone
    isToolAvailable "rclone"
    rclone copy $BACKUP_FILENAME remote:backup/
else
    # Upload to remote server using scp
    scp $BACKUP_FILENAME "$TARGET:/backup"
fi