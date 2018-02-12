[![Build status](https://ci.appveyor.com/api/projects/status/00p66jdhcj8nib0c/branch/master?retina=true)](https://ci.appveyor.com/project/ryancbutler/xdreplicate/branch/master)
# XenDesktop 7.x PowerShell Extensions (CTXXD-REPLICATE)

- Exports XenDesktop 7.x site information and imports to another 'Site' via remote command or XML file.
- Eases provisioning and deprovisioning of VDAs
- AND MORE...

## Documentation (in process)
http://xdreplicate.readthedocs.io

## Requirements

- PC\Server with Citrix Snapins installed
- Admin access to XenDesktop site
- PowerShell v3 or greater

## Quick Start
If running PowerShell version 5 or above you can install via [Microsoft PowerShell Gallery](https://www.powershellgallery.com/)

### Install
```
Install-Module -Name CTXXD-Replicate -Scope currentuser
```
### Inspect
```
Save-Module -Name CTXXD-Replicate -Path <path>
```
### Update
```
Update-Module CTXXD-Replicate 
```

## Export and Import Citrix XD\XA Site
```
Export-XDSite|Import-XDSite -xdhost DDC02.DOMAIN.COM
```
Exports from localhost and imports on DDC02.DOMAIN.COM

## VDA Provisioning\Deprovisioning (MCS ONLY)
What it does.
- AD Computer Account Provisioning\Deprovisioning
- VM Provisioning\Deprovisioning
- Machine to Delivery Group Assignment
- User Association (if Dedicated)
- Manages machine name count reset (if pooled)

### Deploy Additional Pooled Desktops
```
New-XDMCSDesktop -machinecat "Windows 10 x64 Dedicated" -dgroup "Windows 10 Desktop" -mctype "Pooled" -howmany "10" -verbose
```
### Remove Pooled Desktops
```
Remove-XDMCSdesktop -howmany 5 -dgroup "Windows 7 Pooled Test" -mctype "Pooled"
```
### Deploy an Additional Dedicated Desktop
```
New-XDMCSDesktop -machinecat "Windows 10 x64 Dedicated" -dgroup "Windows 10 Desktop" -mctype "Dedicated" -user "lab\joeshmith" -verbose
```
### Remove a Dedicated Desktop
```
Remove-XDMCSdesktop -desktop "MYDOMAIN\MYVDI01" -mctype "Dedicated" -verbose
```
## Send a basic Slack Message
Send a Slack message to [Incoming Webhook](https://api.slack.com/incoming-webhooks)
```
send-xdslackmsg -slackurl "https://myslackwebhook.slack.com" -msg "Send this" -emoji ":joy:"
```

## Provisioning Services 7.x vDisk version Export and Import Script

Moved to dedicated repo [PVSReplicate](https://github.com/ryancbutler/PVSReplicate)
