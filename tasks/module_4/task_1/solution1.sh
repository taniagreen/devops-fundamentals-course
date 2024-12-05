#!/usr/bin/env bash

freespace=$(df -k / | awk 'NR==2 {print $4}')
treshold="141872010"

checkFreeSpace() {
if ((freespace<"$1"))
    then
        echo "$treshold"
        echo "Free storage $freespace kb is less than the threshold $1 kb"
    fi
}

if [ -n "$1" ]
    then
       treshold=$1
    fi

while
checkFreeSpace $treshold; 
do sleep 5; 
done