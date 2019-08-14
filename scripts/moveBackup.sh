#!/usr/bin/env bash

#DATAPATH="/var/backup"
echo "$1 $2 $3 $4 $5 " > /var/backup/backupScript/log.log
DATAPATH=$5
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

       if ! [ -d $DATAPATH/$NAME'/daily' ] ; then
                mkdir -p $DATAPATH/$NAME'/daily'
        fi
#####Ueberpruefe ob tmp ordner exisitiert
        if ! [ -d /opt/backupScript/tmp ] ; then
                mkdir -p /opt/backupScript/tmp
        fi
###########################################
MONAT=$(date +%m)
JAHR=$(date +%Y)
ORDNERBEZ=$(date +"%Y.%m.%d-%H.%M")
MONAT=$(( ($MONAT * ($JAHR * 12)) ))

#################################################
#################################################
cp -al $DATAPATH/$NAME'/akt' $DATAPATH/$NAME'/daily/'$ORDNERBEZ
touch $DATAPATH/$NAME'/daily/'$ORDNERBEZ
#####Check Letzter Monat
if [ -f "/opt/backup/tmp/lastmon" ]; then  LASTM=$(tail /opt/backupScript/tmp/lastmon) ; else   LASTM=0 ; fi
if [ -f "/opt/backup/tmp/lastyear" ]; then  LASTY=$(tail /opt/backupScript/tmp/lastyear) ; else   LASTY=0 ; fi

if [ $SYNCMONTH -gt 0 ] && ! [ $LASTM -eq $MONAT ]
then
        if ! [ -d $DATAPATH/$NAME'/month' ] ; then
                mkdir -p $DATAPATH/$NAME'/month'
        fi
        cp -al $DATAPATH/$NAME'/akt' $DATAPATH/$NAME'/month/'$ORDNERBEZ
        touch $DATAPATH/$NAME'/month/'$ORDNERBEZ
	echo $MONAT > /opt/backupScript/tmp/lastmon

fi


if  [ $SYNCYEAR -gt 0 ] && ! [ $LASTY -eq $JAHR ]
then
        if ! [ -d $DATAPATH/$NAME'/year' ] ; then
                mkdir -p $DATAPATH/$NAME'/year'
        fi
        cp -al $DATAPATH/$NAME'/akt' $DATAPATH/$NAME'/year/'$ORDNERBEZ
        touch $DATAPATH/$NAME'/year/'$ORDNERBEZ
	echo $JAHR > /opt/backupScript/tmp/lastyear
fi

find  "$DATAPATH/$NAME/daily/" -mindepth 1 -maxdepth 1 -type d -ctime +$SYNCDAY -exec echo {} \;
if [ $SYNCMONTH -gt 0 ]
then
        find  "$DATAPATH/$NAME/month/" -mindepth 1 -maxdepth 1 -type d -mtime +$[$SYNCMONTH * 31] -exec rm -R {} \;
fi
if [ $SYNCYEAR -gt 0 ]
then
        find  "$DATAPATH/$NAME/year/" -mindepth 1 -maxdepth 1 -type d -mtime +$[$SYNCYEAR * 366] -exec rm -R {} \;
fi

