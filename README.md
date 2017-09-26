[![Build status](https://ci.appveyor.com/api/projects/status/00p66jdhcj8nib0c/branch/master?retina=true)](https://ci.appveyor.com/project/ryancbutler/xdreplicate/branch/master)
## XenDesktop 7 Site Export and Import Module

Exports XenDesktop 7.x site information and imports to another 'Site' via remote command or XML file.

## Documentation (in process)
http://xdreplicate.readthedocs.io

### Requirements

- PC\Server with Citrix Snapins installed
- Admin access to XenDesktop site
- PowerShell v3 or greater

### PS Gallery
If running PowerShell version 5 or above you can install via [Microsoft PowerShell Gallery](https://www.powershellgallery.com/)

#### Install
```
Install-Module -Name CTXXD-Replicate -Scope currentuser
```
### Inspect
```
Save-Module -Name CTXXD-Replicate -Path <path>
```
#### Update
```
Update-Module CTXXD-Replicate 
```

## Provisioning Services 7.x vDisk version Export and Import Script

Moved to dedicated repo [PVSReplicate](https://github.com/ryancbutler/PVSReplicate)
