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

## VDA Provisioning\Deprovisioning (MCS)
What it does.
- AD Computer Account Provisioning
- VM Provisioning
- Delivery Group Assignment
- User Association (if Dedicated) 

### Deploy Additional Pooled Desktops
```
New-XDDesktopPooled -machinecat "Windows 10 x64 Random" -dgroup "Windows 10 Desktop" -howmany 5
```
### Remove Pooled Desktops
```
Remove-XDDesktopPooled -dgroup "Windows 10 Desktop" -howmany 10
```
### Deploy an Additional Dedicated Desktop
```
New-XDDesktopDed -machinecat "Windows 10 x64 Random" -dgroup "Windows 10 Desktop" -user "lab\joeshmith"
```
### Remove a Dedicated Desktop
```
Remove-XDDesktopDed -desktop "MYDOMAIN\MYVDI01"
```

## Provisioning Services 7.x vDisk version Export and Import Script

Moved to dedicated repo [PVSReplicate](https://github.com/ryancbutler/PVSReplicate)
