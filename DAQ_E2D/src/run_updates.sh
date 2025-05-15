#!/bin/bash

# Step 1: Run firmware_update.sh
echo "Running firmware_update.sh..."
./firmware_update.sh

# Step 2: Wait for 1 minute before pinging
echo "Waiting for 1 minute before checking connectivity..."
sleep 60

# Step 3: Wait until ping to 192.168.1.21 is successful
echo "Pinging 192.168.1.21 until successful..."
while ! ping -c 1 -W 1 192.168.1.21 &> /dev/null; do
    sleep 1
done

# Step 4: Run config_update.sh
echo "Ping successful. Running config_update.sh..."
./config_update.sh
