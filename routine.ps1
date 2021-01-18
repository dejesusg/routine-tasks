# Run Routine Tasks for newly deployed Devices
# Author: Gabriel De Jesus
<#
        DEVICE NAMING
#>
$bldg = Read-Host "Building"
$room = Read-Host "Room Number"
# For this, we should enumerate the devices in $Building$Room through AD in order to incrementally assign a device.
#   e.g. if we have AD10101 and AD10102, then we should make this device AD10103
#   We Can RegEx Match (AD)(101)(Dev#), strip the Dev# and then add 1 to it...or something
#   If we can automate this, it's better than manual look up
$devNum = Read-Host "Device Number"
$devType = Read-Host "Device Type"
$leaseYr = Read-Host "Lease Year"
$devName = "$bldg$room$devNum$devType-$leaseYr"
Rename-Computer -NewName $devName
###     END DEVICE NAMING

<#
    POWER SETTINGS
    Key:
        /setdcvalueindex - Used for any Setting While on BATTERY (DC)
        /setacvalueindex - Used for any Setting While Plugged-In (AC)

    Values:
        0 - Do Nothing
        1 - Sleep
        2 - Hibernate
        3 - Shut Down
#>

# Get Current Power Scheme GUID
$activeScheme = cmd /c "powercfg /getactivescheme"
$regEx = '(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}'
$asGuid = [regex]::Match($activeScheme,$regEx).Value

### Lid & Power Button Settings
# Relative GUIDs for LidClose & Power Btn Settings
$pwrGuid = '4f971e89-eebd-4455-a8de-9e59040e7347'
$pwrBtnGuid = '7648efa3-dd9c-4e3e-b566-50f929386280'
$lidClosedGuid = '5ca83367-6e45-459f-a27b-476b1d01c936'
## On Battery Related Settings
    # Power-button - Sleep (1)
    cmd /c "powercfg /setdcvalueindex $asGuid $pwrGuid $pwrBtnGuid 1"
    # When on Battery and Lid Closed, Sleep (1)
    cmd /c "powercfg /setdcvalueindex $asGuid $pwrGuid $lidClosedGuid 1"
## AC-Power Settings (Plugged-in)
    # Power-button - Turn Off (3)
    cmd /c "powercfg /setacvalueindex $asGuid $pwrGuid $pwrBtnGuid 3"
    # When Plugged In and Lid Closed, Do Nothing (0)
    cmd /c "powercfg /setacvalueindex $asGuid $pwrGuid $lidClosedGuid 0"

### Display Settings
# Relative GUIDs for Display Settings
$displayGuid = '7516b95f-f776-4464-8c53-06167f40cc99'
$disIdleGuid = '3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e'
## Set Time before Diplay Turns Off
    # On Battery - 20 Minutes
    cmd /c "powercfg /setdcvalueindex $asGuid $displayGuid $disIdleGuid 20"
    # Plugged-In - Never (0)
    cmd /c "powercfg /setacvalueindex $asGuid $displayGuid $disIdleGuid 0"

### Sleep Settings
# Relative GUIDs for Sleep/Hibernate
## On Battery - Time till auto-sleep
## Plugged-In - Time till auto-sleep

### Apply Settings
cmd /c "powercfg /s $asGuid"

<#
        END POWER SETTINGS
#>
