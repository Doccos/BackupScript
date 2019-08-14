#!/usr/bin/env bash

MAXRSYNC=10

#####START
TIME=$(date +%s)

#echo $TIME
if [ -n "$1" ] ; then
        SERVER="$1"
else
        echo "Error: Usage $0 <fqdn-hostname>"
        exit
fi

#IST PORT GESETZT
if ! [ -n "$2" ]; then  echo "Kein Port gesetzt"; exit; fi
#IST PORT EINE NUMMER
if [ $2 -gt 0 ]; then PORT=$2 ; else echo "Port ist keine Nummer";exit; fi
#IST 4. Parameter gesetzt (NAME)
if [ -n "$3" ]; then NAME=$3 ; else  echo "Kein Name gesetzt"; exit; fi
if [ -n "$4" ]; then SYNCDAY=$4 ; else  SYNCDAY=30;  fi
if [ -n "$5" ]; then SYNCMONTH=$5 ; else  SYNCMONTH=0;  fi
if [ -n "$6" ]; then SYNCYEAR=$6 ; else  SYNCYEAR=0;  fi



for ZEILE in $7
do
  echo "$ZEILE"
        #BACKUPDIR=/var/backup/$NAME'/akt'$ZEILE
        BACKUPDIR=$8/$NAME'/akt'$ZEILE
         if  [ -d $ZEILE ] ; then

                SC=10
                while [ $SC -gt 0 ]
                do
                        ssh -x -p $PORT $SERVER " mkdir -p $BACKUPDIR </dev/null >/dev/null 2>&1 & "
                        echo "Erstelle Verzeichnis $BACKUPDIR"

                        SC=$?
                        sleep 1
                done
        #       echo $BACKUPDIR

                COUNTER=$MAXRSYNC
                while [ $COUNTER -gt 0 ]
                do
                        rsync -e "ssh  -p $PORT" -avz --numeric-ids --delete --delete-excluded $ZEILE/  $SERVER:"$BACKUPDIR"
                        if  [ $? = 24 -o $? = 0 ] ; then
                        echo "Rsync Erfolgreich!"
                        COUNTER=0
                        fi
                        COUNTER=$[$COUNTER-1]
                done
        fi


done
                SC=10
                while [ $SC -gt 0 ]
                do
                        echo "Starte BackupTo ende Script "
                        ssh -x  -p $PORT $SERVER " /opt/backupScript/scripts/afterBackupTo.sh $NAME $SYNCDAY $SYNCMONTH $SYNCYEAR $8 </dev/null >/dev/null 2>&1 & "

                        SC=$?
                        sleep 1
                done

