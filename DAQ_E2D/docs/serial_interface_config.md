## Configuration of NTI E-2D via command line
---
- Connect PDU with USB A to USB B cable and initiate communication as follows:

        minicom -D <device>
        minicom -D /dev/ttyACM0

- Enter login credentials
  - Default username: root
  - Default password: nti

## Device Level Configuration
2. System Configuration
    1. Time Settings

                Enable NTP: Enabled
                NTP server: ntp1.lbl.gov
                
                [save]

4. Network Configuration
   
    2. SNMP Settings
   
                Enable SNMP Agent: SNMPv3
                Read-write community name: <RW-name>
                Read-only community name: <R-name>

                [save]

    3. Misc. Service Settings

                Enable SSH: Disabled
                Enable Telnet: Disabled
                Enable HTTP Access: Disabled

                [save]

5. User Configuration
    1. root

        1. SNMP Settings

                Authentication Protocol: SHA
                Authentication Passphrase: <Auth passphrase>
                Privacy Protocol: AES
                Privacy Passphrase: <Priv passphrase>

                [save]

## System Level Configuration
4. Network Configuration
    1. IPv4 Settings

                IPv4 Mode: Static
                IPv4 Address: <IP Address>
                IPv4 Subnet Mask: <Subnet Mask>
                Default Gateway: <Gateway>

                [save]

3. Enterprise Configuration
                
                Enterprise Name: <Unit Name>
                Location: <Unit Location>
                Contact: <Contact Person>
                Phone: <Phone No>
                E-mail: <email>
                
                [save]

9. Reboot




        


