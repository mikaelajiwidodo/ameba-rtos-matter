# Device AT Commands

This page provides clear instructions for using AT commands on Realtek devices, specifically for factory reset and accessing the Matter shell (client).

To view all available AT Commands for Matter, enter `ATMH`

    Matter AT Commands List

        ATM$ : factory reset. (Usage: ATM$)
        ATM% : matter ota query image. (Usage: ATM%)
        ATM^ : matter ota apply update. (Usage: ATM^)
        ATMH : matter help. (Usage: ATMH)
        ATMS : matter client console. (Usage: ATMS=switch / ATMS=manual)

## Ameba D and Z2 SDK (ambd_matter and ambz2_matter)

### Factory Reset

To perform a factory reset on the device:

    ATM$

### Matter Shell (Client) Commands

To interact with the Matter shell (client) via AT commands, use the following syntax:

#### For AmebaZ2 and AmebaZ2Plus

    ATMS=switch

#### For AmebaD

    ATMS switch

**Note**: The AT command for AmebaD does not require the '=' sign.

#### Examples:

Demostrating with `ATMS=switch`, please make sure to replace the '=' sign with space for AmebaD.

##### Turn On/Off Command:

`ATMS=switch onoff on`

##### Level Control Command:

`ATMS=switch levelcontrol movetolevel 100 0 0 0`

##### Color Control Command:

`ATMS=switch colorcontrol movetohue 100 0 0 0 0`

##### Thermostat Command:

`ATMS=switch thermostat SPRL 0 0`

##### Read Attribute

`ATMS=switch <cluster> read <attribute>`

## Ameba Dplus, Lite, and Smart SDK (ameba-rtos)

### Common Guide

AT command implementation for Matter Application is located at component/application/matter/common/atcmd/atcmd_matter.c. How to run:

    ATmatter <command>

or

    ATmatter=<command>

* ATmatter factoryreset     : to factory reset the matter application
* ATmatter queryimage       : query image for matter ota requestor app
* ATmatter applyupdate      : apply update for matter ota requestor app
* ATmatter help             : to show other matter commands
* ATmatter secureheapstatus : to check secure heap status

For IP Mode, to connect device to existing wifi, you can run this AT command:

For new AT command **(default)** :

    AT+WLCONN=ssid,<ssid name>,pw,<password>

For old AT command:

    ATW0=<ssid>
    ATW1=<password>
    ATWC

### Matter Shell (Client) Commands

To interact with the Matter shell (client) via AT commands, use the following syntax:

    ATmatter switch

#### Examples:

##### Turn On/Off Command:

`ATmatter switch onoff on`

##### Level Control Command:

`ATmatter switch levelcontrol movetolevel 100 0 0 0`

##### Color Control Command:

`ATmatter switch colorcontrol movetohue 100 0 0 0 0`

##### Thermostat Command:

`ATmatter switch thermostat SPRL 0 0`

##### Read Attribute

`ATmatter switch <cluster> read <attribute>`
