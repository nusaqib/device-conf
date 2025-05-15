#!/bin/python3

# Script for configuring E-2D

# Import required modules
import pandas as pd
import pexpect
import argparse
import sys
import gspread
sys.path.insert(0, '../../AMS/src')
import AMS

# Parse command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("-d", "--id", help="Device Name/ID from system-level configuration spreadsheet")
parser.add_argument("-s", "--serial", help="Serial Device")
args = parser.parse_args()

def main():
    
    while True:
    
        entry = input('''
        Menu:
        1. Print present settings
        2. Apply device-level configuration
        3. Apply system-level configuration
        4. Verify device-level configuration
        5. Verify system-level configuration
        6. Quit

        Enter your choice: ''')

        if entry == '1':
            pass
            #printSystemLevelSettings()

        if entry == '2':
         deviceLevelConfig()

        if entry == '3':
         systemLevelConfig()

        if entry == '4':
            pass
            #verifyDeviceLevelConfig()

        if entry == '5':
            pass
            #verifySystemLevelConfig()
        
        if entry == '6':
            break

def deviceLevelConfig():

    # Connect to E2D
    connectToE2D()
    # System Confiugraion
    e2d.sendline("2")
    e2d.sendline("1")
    e2d.sendline("\n\n\n\n\n")
    # Enable NTP if disabled, otherwise skip and press 'Ctrl+]' to continue the script
    e2d.interact()
    e2d.sendline('')
    e2d.send("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
    e2d.sendline("ntp3.lbl.gov")
    e2d.sendline("\t")
    e2d.send("\x1b")
    e2d.send("\x1b")

    print("\nDevice Level Settings applied successfully.....Rebooting E2D\n")

    updateAMS = input('\nDo you want to update AMS? (y/n): ')
    if updateAMS == 'y':
        AMS.updateDeviceLevelConfig()
        print('\nAMS updated\n')
        subMenu()

    else:
        subMenu()

def systemLevelConfig():

    if args.id:
        dev_name = args.id
    else:
        dev_name = input('\nPlease enter the device name/ID from the system-level configuration spreadsheet: ')
    
    sa = gspread.service_account(filename="/home/nusaqib/ap.json")

    sh = sa.open("ARNetwork")

    wks = sh.worksheet("E2D")

    cell = wks.find(dev_name)

    df = pd.DataFrame(wks.get_all_records())

    Name=(df['Device Name'][cell.row-2])
    Location=(df['Rack'][cell.row-2])
    IPAddress=(df['IP Address'][cell.row-2])
    NetworkMask=(df['Subnet Mask'][cell.row-2])
    Gateway=(df['Gateway'][cell.row-2])
    
    print('\n*** E-2D configuration tool ***\n')
    print(f"Name = {Name}\nLocation = {Location}\nIPAddress = {IPAddress}\nNetworkMask = {NetworkMask}\nGateway = {Gateway}\n")

    # Connect to E2D
    connectToE2D()

    # Enterprise Confiugraion
    e2d.sendline("3")
    e2d.send("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
    e2d.sendline(f"{Name}")
    e2d.send("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
    e2d.sendline(f"{Location}")
    e2d.sendline("\t")
    e2d.send("\x1b")
    e2d.send("\x1b")

    # Network Confiugraion
    e2d.sendline("4")
    e2d.sendline("1")
    # Change to Static if DHCP is enabled, otherwise skip and press 'Ctrl+]' to continue the script
    e2d.interact()
    e2d.sendline('')
    #pdu.sendline('n')
    e2d.send("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
    e2d.sendline(f"{IPAddress}")
    e2d.send("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
    e2d.sendline(f"{NetworkMask}")
    e2d.send("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b")
    e2d.sendline(f"{Gateway}")
    e2d.sendline("\t")
    e2d.send("\x1b")
    e2d.send("\x1b")
    e2d.send("\x1b")
    e2d.sendline("\t")
    e2d.sendline(" ")

    print("\nSystem Level Settings applied successfully.....Rebooting E2D\n")

    updateAMS = input('\nDo you want to update AMS? (y/n): ')
    if updateAMS == 'y':
        payload = {
        "_snipeit_ip_address_3": f"{IPAddress}",
        "_snipeit_subnet_mask_4": f"{NetworkMask}",
        "_snipeit_gateway_5": f"{Gateway}",
        "status_id": 2,
        "name": f"{dev_name}"
        }
        AMS.updateSystemLevelConfig(payload)
        print('\nAMS updated\n')
        subMenu()

    else:
        subMenu()

    e2d.interact()


def connectToE2D():
    global e2d

    if args.serial:
        ser_device = args.serial
    else:
        ser_device = input('\nPlease enter the serial device name: ')

    #Connect to E-2D
    e2d = pexpect.spawn(f"minicom -D {ser_device}")

    # User logs in to the E-2D, press 'Ctrl+]' to continue the script
    e2d.interact()

def subMenu():
    sub = input('''
    1. Main Menu
    2. Exit
    ''')

    if sub == '2':
        exit()

if __name__ == '__main__':
    main()


