#!/bin/bash

# NTI Enviromux-xD Firmware Change Script
# http://www.networktechinc.com
# Copyright 2017 Network Technologies Inc, All rights reserved.
# 
# Instructions: It is recommended to verify firmware release notes before triggering upgrade.
# Requirements: Curl, Perl
# Usage: bash change_script.sh
# Downloads the specified firmware version from website and updates one E-xD unit as set below
# Version: 1.0

# Username and password of Enviromux-xD unit with admin privileges
USERNAME=root
PASSWORD=nti

# IP Address or domain name of Enviromux-xD unit
IP_ADDRESS=192.168.3.221

# Enviromux-xD unit protocol to be used: http/https
PROTOCOL=http

# log file to send errors and upgrade details
LOGFILE=/dev/stdout

# Firmware version to update the unit with. 
# Example: if unit is to be updated with version 2.48, specify
#          2 for major version and 48 for minor version
TARGET_MAJOR_VERSION=2
TARGET_MINOR_VERSION=48


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


# Filename for target firmware to be downloaded
FILENAME="enviromux-xd-v$TARGET_MAJOR_VERSION-$TARGET_MINOR_VERSION"


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

