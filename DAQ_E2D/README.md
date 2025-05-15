## Configuration of E-2D

- [Configuration of E-2D](#configuration-of-e-2d)
- [Required Components](#required-components)
- [Configuration](#configuration)
  - [Workflow](#workflow)
  - [Settings](#settings)
    - [Device Level Configuration](#device-level-configuration)
    - [System Level Configuration](#system-level-configuration)
- [Specific Configurations](#specific-configurations)
  - [BBPS E2D Configuration](#bbps-e2d-configuration)
    - [Network](#network)
    - [Device](#device)

## Required Components
- E-2D unit
- Ethernet cable
- USB A to USB B cable

## Configuration

### Workflow
1. Restore default settings: Press 'RESTORE DEFAULTS' button on the front panel for 5 seconds
2. Update firmware (if needed): run [firmware_update.sh](./src/firmware_update.sh)
3. Upload configuration file: run [config_update.sh](./src/config_update.sh)
4. Inventorize: Attach AMS label (if not present)
5. Update AMS & etraveler: run [ams_update.py](./src/ams_update.py)


Please see [Configuration using command line](./docs/serial_interface_config.md) to configure E-2D manually via command line

### Settings

#### Device Level Configuration

| Network Service | Value |
| --- | --- |
| SSH | Enable |
| Telnet | Disable |
| HTTP | Disable |
| HTTPS | Enable (Can't disable) |
| HTTPS Port | 443 (default) |
| IPv6 | Disable |
| PING | Disable |
| SNMP v1 | Disable |
| SNMP v2 | Disable |
| SNMP v3 | Enable |
| SNMP Port | 5723 |
| SNMP Community | alsuctrlsnmp |


| Digital Intput | Setting |
| --- | --- |
| Digital Input 1 | SMS1 |
| Digital Input 2 | WLS1 |

| User | Permission | Password | Purpose |
| --- | --- | --- | --- |
| root | Admin  | alsU4evR! | Serial console |
| alsuctrladmin | Admin | alsU4evR! | Device setup |
| ctrlsnmp | Operator | ctrl4evR! | IOC |

| SNMPv3 | Value |
| --- | --- |
| Authentication phrase | *user password* |
| Authentication protocol | SHA |
| Privacy phrase | *user password* |
| Privacy protocol | AES |

#### System Level Configuration
- To be done after AMS checkout

| Device Settings |
| --- |
| Name |
| Location |
| Rack |

| Network Settings (via DHCP)|
| --- |
| IP Address |
| Subnet Mask |
| Gateway |

## Specific Configurations

### BBPS E2D Configuration
- The configuration file is located at [E2D_bbps](./config/E2D_bbps.json)

The custom settings are as follows:

#### Network
- IP: 131.243.89.189
- Subnet: 255.255.255.0
- Gateway: 131.243.89.1
- DNS: 131.243.89.1

#### Device
- Name: BE0116-5-E2D1
- Location: BRPIT
- Rack: BE0116-5

