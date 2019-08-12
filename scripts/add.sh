#!/usr/bin/env bash
echo "Serveradresse:"
C=1

while [ $C -gt 0 ]
do
        read input </dev/tty
        if [ "$input" != "" ]; then
                SERVER=$input
        break
        fi
done
echo "Serverport:"

while [ $C -gt 0 ]
do
        read input </dev/tty
        if [ "$input" != "" ]; then
                PORT=$input
        break
        fi
done
if [ ! -f "~/.ssh/id_rsa" ]
then
    echo "key will be generated, please press only enter"
    SSHK=$(which ssh-keygen)
    echo $SSHK
    $SSHK -t rsa -b 4096
fi

if [  -f "~/.ssh/id_rsa" ]
then
    CAT=$(which cat)
    CAT /root/.ssh/id_rsa.pub | ssh  -p $PORT $SERVER "mkdir -p /root/.ssh/ && cat  >> /root/.ssh/authorized_keys2"


else
    echo "~/.ssh/id_rsa nicht gefunden"
fi