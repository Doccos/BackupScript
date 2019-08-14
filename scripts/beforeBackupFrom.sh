#!/usr/bin/env bash
if ! [ -d /opt/backupScript/tmp ] ; then
        mkdir -P /opt/backupScript/tmp
fi
if [ -n "$1" ] ; then
        BEZ="$1"
else
        echo "Error: Keine Bezeichnung übergeben"
        exit
fi
echo 0 > /opt/backup/tmp/$1

if [ -f /opt/backupScript/scripts/executeBeforeFrom.sh ] ; then
        /bin/bash /opt/backupScript/executeBeforeFrom.sh $BEZ
fi



echo 1 > /opt/backup/tmp/$1
