#!/bin/bash

# NTI Enviromux-xD Auto Firmware Upgrade Script
# http://www.networktechinc.com
# Copyright 2017 Network Technologies Inc, All rights reserved.
# 
# Instructions: It is recommended to verify firmware release notes before triggering upgrade.
# Requirements: Curl, Perl
# Usage: bash upgrade_script.sh
# Downloads latest firmware from website and upgrades one E-xD unit as set below
# Version: 1.0

# Username and password of Enviromux-xD unit with admin privileges
USERNAME=root
PASSWORD=nti

# IP Address or domain name of Enviromux-xD unit
IP_ADDRESS=192.168.1.21

# Enviromux-xD unit protocol to be used: http/https
PROTOCOL=http

# log file to send errors and upgrade details
LOGFILE=/dev/stdout


#########################################################################

echo `date` "Starting firmware update for $IP_ADDRESS" >> $LOGFILE

RESPONSE=`curl -is -X POST -m 10 -d "username=$USERNAME&password=$PASSWORD" $PROTOCOL://$IP_ADDRESS/goform/login 2>&1`

if [[ $RESPONSE == *"sessionId"* ]]; then
	SESSIONID=`echo $RESPONSE | perl -n -e'/sessionId=([^"]*)"/ && print $1'`
	echo `date` "Logged in successfully with sessionid $SESSIONID" >> $LOGFILE
else
	echo `date` "ERROR: Login failed" >> $LOGFILE
	echo `date` "Login Response $RESPONSE" >> $LOGFILE
	exit
fi

# checking current firmware
RESPONSE=`curl -is -X GET -H "Cookie: sessionId=$SESSIONID" $PROTOCOL://$IP_ADDRESS/firmware.asp 2>&1`
if [[ $RESPONSE == *"Current firmware version"* ]]; then
	CUR_MAJ_VER=`echo $RESPONSE | perl -n -e'/Current firmware version is <b>([0-9]*)\.[0-9]*/ && print $1'`
	CUR_MIN_VER=`echo $RESPONSE | perl -n -e'/Current firmware version is <b>[0-9]*\.([0-9]*)/ && print $1'`
	echo `date` "Current version is $CUR_MAJ_VER.$CUR_MIN_VER" >> $LOGFILE
else
	echo `date` "ERROR: Unable to get current version"
	echo `date` "RESPONSE: $RESPONSE"
	exit
fi


# checking available firmwares on NTI website
FILENAME=`curl -s -X GET http://www.networktechinc.com/download/d-environment-monitor-16.html | perl -n -e'/href="([^"]*)\.bin/ && print $1 and exit'`

AVAIL_MAJ_VER=`echo $FILENAME | perl -n -e'/enviromux-xd-v([0-9]*)-[0-9]*/ && print $1'`
AVAIL_MIN_VER=`echo $FILENAME | perl -n -e'/enviromux-xd-v[0-9]*-([0-9]*)/ && print $1'`

if [ "$AVAIL_MAJ_VER" -gt "$CUR_MAJ_VER" -o "$AVAIL_MIN_VER" -gt "$CUR_MIN_VER" ]; then
	echo `date` "Newer version $AVAIL_MAJ_VER.$AVAIL_MIN_VER available" >> $LOGFILE
else
	echo `date` "Latest available version is $AVAIL_MAJ_VER.$AVAIL_MIN_VER" >> $LOGFILE
	echo `date` "exiting upgrade" >> $LOGFILE
	exit
fi
echo `date` "Downloading firmware version $FILENAME.bin" >> $LOGFILE
curl -s -o $FILENAME.bin http://www.networktechinc.com/download/$FILENAME.bin
FILESIZE=`wc -c < $FILENAME.bin`
echo `date` "Downloaded $FILENAME.bin with size $FILESIZE bytes" >> $LOGFILE

if [ "$FILESIZE" -lt 5000000 ]; then
	echo `date` "downloaded file size less than 5MB. Something is not right" >> $LOGFILE
	echo `date` "exiting"
	exit
fi

# constructing payload for firmware update
rm -f web_update.bin >> $LOGFILE 2>&1
echo -e '------WebKitFormBoundaryzrglVuTTUNmMoaeU\r\nContent-Disposition: form-data; name="config_file"; filename="web_update.bin"\r\nContent-Type: application/octet-stream\r\n\r\n' >> web_update.bin


cat $FILENAME.bin >> web_update.bin
echo -e '\r\n------WebKitFormBoundaryzrglVuTTUNmMoaeU--\r\n' >> web_update.bin
FILESIZE=`wc -c < web_update.bin`

if [ "$FILESIZE" -lt 5000000 ]; then
        echo `date` "constructed file size less than 5MB. Something is not right" >> $LOGFILE
        echo `date` "exiting"
        exit
fi

echo `date` "Uploading firmware with size $FILESIZE bytes" >> $LOGFILE
echo `date` "This may take 5 minutes.." >> $LOGFILE
RESPONSE=`curl -i -s -X POST -H "Host: $IP_ADDRESS" -H "Content-Length: $FILESIZE" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryzrglVuTTUNmMoaeU" -H "Connection: keep-alive" -H "Expect:" -H "Cookie: sessionId=$SESSIONID" --data-binary @web_update.bin $PROTOCOL://$IP_ADDRESS/goform/upgrade 2>&1`

echo `date` "Firmware uploaded.." >> $LOGFILE

RESPONSE=`echo $RESPONSE | tr -d '\r'`
if [[ "$RESPONSE" == *"302 Redirect"* && "$RESPONSE" == *"reboot.asp"* ]]; then
	echo `date` "Rebooting device" >> $LOGFILE
	RESPONSE=`curl -s -X GET -H "Cookie: sessionId=$SESSIONID" $PROTOCOL://$IP_ADDRESS/reboot.asp?reason=upgrade`
else
	echo `date` "ERROR: Firmware update failed" >> $LOGFILE
	echo $RESPONSE >> $LOGFILE
	exit
fi

