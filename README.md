# XenDesktop and PVS Export and Import Scripts

Scripts to replicate XenDesktop or Provisioning Services information to additional locations. Can be used to quickly keep additional sites or environments in sync.

## XenDesktop 7 Site Export and Import Script

Exports XenDesktop 7.x site information and imports to another 'Site' via remote command or XML file.

**XDReplicate.ps1**

**PLEASE USE WITH CAUTION. THIS WILL OVERWRITE SETTINGS ON IMPORT**

### Requirements

- PC\Server with Citrix Snapins installed
- Admin access to XenDesktop site
- PowerShell v3 or greater

### PS Gallery
If running PowerShell version 5 or above you can install via [Microsoft PowerShell Gallery](https://www.powershellgallery.com/)

#### Install
```
Install-Script -Name XDReplicate -Scope currentuser
```

#### Update
```
Update-Script XDReplicate
```

### Changelog

- 01-16-17: Initial release
- 05-11-17: Added check for LTSR and fixed ICON creation on new app creation
- 05-12-17: bug fixes
- 05-22-17: browsername in apps and permission fixes
- 06-01-17: Fixes for BrokerPowerTimeScheme on desktop groups
- 06-23-17: Fixes for folder creation and BrokerPowerTimeScheme
- 07-12-17: Fixes for app creation and user permissions (issue #10)
- 07-13-17: Fixes for app creation on command line argument (issue #9)
- 07-23-17: Added arguments to include\exclude apps and delivery groups based on tags
- 07-23-17: Edits to tag import based on XD site version
- 07-23-17: Better handling of app renames
- 07-26-17: Converted to strict-mode and documented functions
- 07-26-17: Added check for name conflict on app creation and warns user of possible name conflict
- 07-26-17: Added some color to output
- 08-04-17: LTSR doesn't like APP tags for get-brokerapplication. Removed strict-mode for now.
- 08-09-17: Changes to DDCVERSION check
- 08-21-17: App Entitlement fixes for DG groups without desktops
- 08-28-17: Updated for PS gallery

### XenDesktop Versions Tested

- 7.6 (LTSR)
- 7.11
- 7.12
- 7.14.1

### What is copied for XenDesktop?

- Administrators

  - Accounts
  - Roles

- Delivery Groups

  - Settings
  - Users
  - Tags

- Published Desktops

  - Settings
  - User Restrictions

- Published Applications

  - Settings
  - "Limit Visibility"
  - Icon
  - File Type Association
  - Admin folders
  - Tags

### What this doesn't process?

- Citrix Policy (use GPO)
- Machine Catalogs
- Hypervisor connections
- App Disks
- Zones
- Scopes
- Removes Administrators

### Usage

Exports data from localhost and exports to C:\temp\my.xml

`.\XDReplicate.ps1 -mode export -XMLPATH "C:\temp\my.xml"`

Exports data from localhost with delivery groups tagged with "replicate" and imports on DDC02.DOMAIN.COM

`\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -dgtag "replicate"`
   
Exports data from localhost while skipping delivery groups tagged with "skip" and imports on DDC02.DOMAIN.COM

`.\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -ignoredgtag "skip"`

Exports data from localhost delivery groups while only including apps tagged with "replicate" and imports on DDC02.DOMAIN.COM   

`.\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -apptag "replicate"`

Exports data from localhost delivery groups while ignoring apps tagged with "skip" and imports on DDC02.DOMAIN.COM

`.\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -ignoreapptag "skip"`

Imports data from C:\temp\my.xml and imports to localhost

`.\XDReplicate.ps1 -mode import -XMLPATH "C:\temp\my.xml"`

Exports data from localhost and imports on DDC02.DOMAIN.COM

`.\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM`

Exports data from DDC01.DOMAIN.COM and imports on DDC02.DOMAIN.COM

`.\XDReplicate.ps1 -mode both -source DDC01.DOMAIN.COM -destination DDC02.DOMAIN.COM`

## Provisioning Services 7.x vDisk version Export and Import Script

Keep PVS vDisk versioning consistent across multiple PVS sites and additional PVS farms

**PVSReplicate.ps1**

**PLEASE USE WITH CAUTION. THIS WILL OVERWRITE SETTINGS ON IMPORT**

### Requirements

- PC\Server with Citrix PVS Console 7.7 or greater installed
- Admin access to PVS farm
- PowerShell v3 or greater
- PassThru is used for all PVS server authentication
- vDisk store path is the same across all servers (eg E:\vdisks)

### PS Gallery
If running PowerShell version 5 or above you can install via [Microsoft PowerShell Gallery](https://www.powershellgallery.com/)

#### Install
```
Install-Script -Name PVSReplicate -Scope currentuser
```

#### Update
```
Update-Script PVSReplicate
```

### Changelog

- 02-28-2017: Initial release
- 05-09-2017: Added "Site" option to only replicate specific site.
- 07-27-2017: Added 'JustAdmin' switch to only replicate to single server
- 07-27-2017: Added 'disk' argument to copy specific disk
- 08-28-17: Updated for PS gallery

### PVS Versions Tested

- 7.13

### What is performed?

- vDisk information is copied to all farm servers utilizing robocopy
- Imports missing vDisks
- vDisk versions are imported to all or specific sites
- vDisk override versions set to all or specific sites
- Remove any unneeded vDisk versions

### What this doesn't do?

- Delete non-used vDisks

### Usage

Copies and imports disks and versions to all PVS farm servers accessible via localhost and uses the vDisk store at "E:\teststore" for robocopy.

`.\PVSReplicate.ps1 -StorePath "E:\teststore"`

Copies and imports disks and versions to all PVS farm servers accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" for robocopy.

`.\PVSReplicate.ps1 -StorePath "E:\teststore" -PVSServers "PVSFARM01","PVSFARM02"`

Copies and imports disk versions to all PVS farm servers accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" and "E:\teststore2" for robocopy.

`.\PVSReplicate.ps1 -StorePath "E:\teststore","E:\teststore2" -PVSServers "PVSFARM01","PVSFARM02"`

Copies and imports disks and versions to all PVS farm servers in 'General' site accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" for robocopy.

`.\PVSReplicate.ps1 -StorePath "E:\teststore" -PVSServers "PVSFARM01","PVSFARM02" -Site "General"`
   
Imports disks and versions on all PVS farm servers accessible via localhost for each server. Does not perform any robocopy

`.\PVSReplicate.ps1 -nocopy`

Copies and imports "MYDISK" ONLY to all servers in "MYSITE"

`.\PVSReplicate.ps1 -StorePath "E:\teststore" -Site "MySite" -Disk "MYDISK"`

Copies and imports disks and versions from MYSITE to PVSFARM01 server ONLY. (Images must be replicated from PVSFARM01)   

`.\PVSReplicate.ps1 -StorePath "E:\teststore" -Site "MySite" -PVSServers "PVSFARM01" -JUSTADMIN`
   
