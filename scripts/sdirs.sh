#!/bin/bash
# This scripts prompts users to provide list of directories or files and a corresponding tar.gz compressed file will be created

SCRIPT_NAME=$(basename $0)
echo "running: $SCRIPT_NAME"

# check if there are any arguments
if [ $# -eq 0 ] # if number of arguments is equal to 0, then show the usage
then
    echo "Usage: $0 <file/directory1> [<file/directory2> ...]"
    exit 1
fi

# iterate over each argument and create backup
for arg in "$@" # for arg in list of arguments
do
    # check if argument is a directory of file
    if [ -d "$arg" ]
    then
        echo "Backing up directory: $arg"
        tar -czvf $arg-backup.tar.gz $arg
    elif [[ -f "$arg" ]]
    then
        echo "Backing up file: $arg"
        tar -czvf $arg-backup.tar.gz $arg
    else
        echo "$arg - File or directory is invalid or does not exist"
    fi
done


