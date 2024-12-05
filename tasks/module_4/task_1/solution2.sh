#!/usr/bin/env bash

directory="./"

if [ -n "$1" ]; then
    directory=$1
    cd "$directory"
fi

files_number=$(find . -not -type d | wc -l)

echo "Number of files in the directory (including subdirectories): $files_number"