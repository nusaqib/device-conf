#!/bin/bash

# NTI Enviromux-xD Auto Configuration File Upload Script
# http://www.networktechinc.com
# Copyright 2018 Network Technologies Inc, All rights reserved.
# 
# Requirements: Curl, Perl
# Usage: bash config_update.sh
# Uploads the specified config file to one E-xD unit as set below
# After update, E-xD unit will have the same network settings as in config file
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

CONFIG_FILE=./backup.cfg


#########################################################################

echo `date` "Starting Config update for $IP_ADDRESS" >> $LOGFILE

RESPONSE=`curl -is -X POST -m 10 -d "username=$USERNAME&password=$PASSWORD" $PROTOCOL://$IP_ADDRESS/goform/login 2>&1`

if [[ $RESPONSE == *"sessionId"* ]]; then
	SESSIONID=`echo $RESPONSE | perl -n -e'/sessionId=([^"]*)"/ && print $1'`
	echo `date` "Logged in successfully with sessionid $SESSIONID" >> $LOGFILE
else
	echo `date` "ERROR: Login failed" >> $LOGFILE
	echo `date` "Login Response $RESPONSE" >> $LOGFILE
	exit
fi

if [ ! -e "$CONFIG_FILE" ]; then
   echo `date` "config file $CONFIG_FILE does not exist" >> $LOGFILE
   echo `date` "exiting" >> $LOGFILE
   exit
fi

# constructing payload for config update
rm -f temp_config.cfg >> $LOGFILE 2>&1
echo -n -e '------WebKitFormBoundaryzrglVuTTUNmMoaeU\r\nContent-Disposition: form-data; name="config_file"; filename="temp_config.cfg"\r\nContent-Type: application/octet-stream\r\n\r\n' >> temp_config.cfg
cat $CONFIG_FILE >> temp_config.cfg
echo -n -e '\r\n------WebKitFormBoundaryzrglVuTTUNmMoaeU--\r\n' >> temp_config.cfg
FILESIZE=`wc -c < temp_config.cfg`

if [ "$FILESIZE" -lt 5000 ]; then
        echo `date` "constructed file size less than 5kB. Something is not right" >> $LOGFILE
        echo `date` "exiting" >> $LOGFILE
        exit
fi

echo `date` "Uploading config with size $FILESIZE bytes" >> $LOGFILE


RESPONSE=`curl -i -s -X POST -H "Host: $IP_ADDRESS" -H "Content-Length: $FILESIZE" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryzrglVuTTUNmMoaeU" -H "Connection: keep-alive" -H "Expect:" -H "Cookie: sessionId=$SESSIONID" --data-binary @temp_config.cfg $PROTOCOL://$IP_ADDRESS/goform/saveSystem 2>&1`

echo `date` "Config uploaded" >> $LOGFILE

RESPONSE=`echo $RESPONSE | tr -d '\r'`
if [[ "$RESPONSE" == *"success\":true"* ]]; then
	echo `date` "Rebooting device" >> $LOGFILE
else
	echo `date` "ERROR: Config update failed" >> $LOGFILE
	echo $RESPONSE >> $LOGFILE
	exit
fi

