#!/bin/env python

import os
import sys
import json
import argparse
import subprocess
import urllib3
import re

sys.path.append(os.path.abspath(os.path.join('..')))
sys.path.append(os.path.abspath(os.path.join('../..')))

from AMS.src._AMS import AMS
from device_tools import input_handler, fetch_asset, handle_etraveler

urllib3.disable_warnings()


def update_ams(config, asset_url):
    print("Starting AMS update...")

    payload = {
        "status_id": config["ams_status_id"],
        "_snipeit_ip_address_3": config["ip"],
        "_snipeit_subnet_mask_4": config["subnet"],
        "_snipeit_gateway_5": config["gateway"],
        "_snipeit_firmware_version_11": config["firmware_version"]
    }

    serial = input("Enter the serial number (or press Enter to skip): ").strip()
    if serial:
        payload["serial"] = serial

    mac_choice = input("Update MAC address from network scan? (y/n): ").strip().lower()
    if mac_choice in ('y', 'yes'):
        interface = input("Enter network interface (e.g., eth0): ").strip()
        result = subprocess.getoutput(
            f"sudo arp-scan -I {interface} {config['mac_scan_range']} | grep {config['mac_prefix']}"
        )
        
        if result:
            mac = result.split()[1]
            # Validate MAC address format (e.g., 00:0c:29:3e:53:1a)
            if re.match(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$', mac):
                payload["_snipeit_mac_address_1"] = mac
                print(f"MAC address detected: {mac}")
            else:
                print(f"Invalid MAC address format detected: {mac}")
        else:
            print("MAC address not found.")

    AMS().updateAsset(payload, asset_url)
    print("AMS update complete.")


def main():
    parser = argparse.ArgumentParser(description="Device configurator")
    parser.add_argument('--config', required=True, help='Path to device config JSON file')
    args = parser.parse_args()

    with open(args.config, 'r') as f:
        config = json.load(f)

    input_handler("Connect device to network and press 'y' when ready: ")
    asset_input = input("Scan asset QR code or input asset tag: ").strip()

    asset, asset_url = fetch_asset(asset_input, config["model_name"])
    update_ams(config, asset_url)
    handle_etraveler(asset, asset_url, config)


if __name__ == '__main__':
    main()
