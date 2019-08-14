#!/usr/bin/env bash

if [ -n "$1" ] ; then
        BEZ="$1"
else
        echo "Error: Keine Bezeichnung übergeben"
        exit
fi
rm /opt/backupScript/tmp/$1
