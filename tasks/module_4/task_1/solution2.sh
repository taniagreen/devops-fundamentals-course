#!/usr/bin/env bash

directory="./"

if [ -n "$1" ]
    then
       directory=$1
       cd "$directory"
    fi

files_number=$(ls -A | wc -l)

echo "Number of files in the directory (including subdirectories): $files_number"
