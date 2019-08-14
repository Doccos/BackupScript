#!/usr/bin/env bash
echo "$1 $2 $3 $4 $5 " > /opt/backupScript/log.log
if [ -n "$1" ] ; then
        NAME="$1"
else
        echo "Error: Kein Name übergeben"
        exit
fi

#IST 4. Parameter gesetzt (NAME)
if [ -n "$2" ]; then SYNCDAY=$2 ; else  SYNCDAY=30;  fi
if [ -n "$3" ]; then SYNCMONTH=$3 ; else  SYNCMONTH=0;  fi
if [ -n "$4" ]; then SYNCYEAR=$4 ; else  SYNCYEAR=0;  fi

        /opt/backupScript/script/moveBackup.sh $1 $2 $3 $4 $5 &
