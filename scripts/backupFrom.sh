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

#echo $4
###BEVOR BACKUP REMOTE SCRIPT AUSFUEHREN
#ssh -t  -i /root/.ssh/backup.identity -p $PORT $SERVER "sh -c '( ( /opt/backup/beforebackup.sh asdasdaddddd ) )'"
DATAPATH=$8
SC=10
while [ $SC -gt 0 ]
do
ssh -x -p $PORT $SERVER " /opt/backupScript/scripts/beforeBackupFrom.sh $NAME.$TIME </dev/null >/dev/null 2>&1 & "
echo "---------------------------"
echo "Backup: $NAME"
echo "---------------------------"

echo "Starte BeforBackup Script"


SC=$?
sleep 1
done
SCC=1
while [ $SCC -gt 0  ]
do
    sleep 2
	STATUS=$(ssh -p $PORT $SERVER  cat /opt/backupScript/tmp/$NAME.$TIME 2>&1)
	echo "Warte bis BeforeBackup Script fertig ist Status: $STATUS Counter: $SCC"

	SCC=$[$SCC+1];
	if [ $STATUS -eq 1 ]; then
		SCC=0;
	 fi;
	if [ $SCC -gt 400 ]; then
		echo "BEFOR BACKUP ERROR KILL MYSELF NOW $SCC"
		SCC=0;
		exit;
	fi;

done


for ZEILE in $7
do
#  echo $ZEILE
	BACKUPDIR=$DATAPATH/$NAME'/akt'$ZEILE
#	echo $BACKUPDIR
	if ! [ -d $BACKUPDIR ] ; then
        	mkdir -p $BACKUPDIR
	fi
	COUNTER=$MAXRSYNC
	while [ $COUNTER -gt 0 ]
	do
		rsync -e "ssh  -p $PORT" -avz --numeric-ids --delete --delete-excluded --ignore-errors  $SERVER:$ZEILE/  $BACKUPDIR/


		if  [ $? = 24 -o $? = 0 ] ; then
		echo "Rsync Erfolgreich!"
		COUNTER=0
		fi
		COUNTER=$[$COUNTER-1]
	done



done

       if ! [ -d $DATAPATH/$NAME'/daily' ] ; then
                mkdir -p $DATAPATH/$NAME'/daily'
        fi
#####Ueberpruefe ob tmp ordner exisitiert
        if ! [ -d /opt/backupScript/tmp ] ; then
                mkdir -p /opt/backupScript/tmp
        fi
########################################
MONAT=$(date +%-m)
JAHR=$(date +%Y)
MONAT=$(( ($MONAT * ($JAHR * 12)) ))
ORDNERBEZ=$(date +"%Y.%m.%d-%H.%M")


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
	echo $MONAT > /opt/backup/tmp/lastmon.$NAME
fi


if  [ $SYNCYEAR -gt 0 ] && ! [ $LASTY -eq $JAHR ]
then
        if ! [ -d $DATAPATH/$NAME'/year' ] ; then
                mkdir -p $DATAPATH/$NAME'/year'
        fi
        cp -al $DATAPATH/$NAME'/akt' $DATAPATH/$NAME'/year/'$ORDNERBEZ
        touch $DATAPATH/$NAME'/year/'$ORDNERBEZ
	echo $JAHR > /opt/backup/tmp/lastyear.$NAME
fi


#echo $LASTM
#echo $MONAT
#rsync -e "ssh -i /root/.ssh/backup.identity  -p $PORT" -avz $SERVER:/var/test  $SERVER:/var/tmp $DATAPATH
####AFTER BACKUP
SC=10
while [ $SC -gt 0 ]
do
ssh -x  -p $PORT $SERVER " /opt/backupScript/scripts/afterBackupFrom.sh $NAME.$TIME </dev/null >/dev/null 2>&1 & "
echo "Starte AfterBackup Script"
#echo $?
SC=$?
sleep 1
done

find "$DATAPATH/$NAME/daily/" -mindepth 1 -maxdepth 1 -type d -mtime +$SYNCDAY -exec rm -R {} \;
if [ $SYNCMONTH -gt 0 ]
then
	find  "$DATAPATH/$NAME/month/" -mindepth 1 -maxdepth 1 -type d -mtime +$[$SYNCMONTH * 31] -exec rm -R {} \;
fi
if [ $SYNCYEAR -gt 0 ]
then
	find  "$DATAPATH/$NAME/year/" -mindepth 1 -maxdepth 1 -type d -mtime +$[$SYNCYEAR * 366] -exec rm -R {} \;
fi

