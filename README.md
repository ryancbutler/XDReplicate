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

### Changelog

- 01-16-2017: Initial release
- 05-11-2017: Added check for LTSR and fixed ICON creation on new app creation

### XenDesktop Versions Tested

- 7.6 (LTSR)
- 7.11
- 7.12

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

### What this doesn't copy?

- Citrix Policy (use GPO)
- Machine Catalogs
- Hypervisor connections
- App Disks
- Zones
- Scopes (Trying to think through this)

### Usage

Exports data from localhost and exports to C:\temp\my.xml

`.\XDReplicate.ps1 -mode export -XMLPATH "C:\temp\my.xml"`

Exports data and delivery groups that are tagged with "replicate" from localhost and exports to C:\temp\my.xml

`.\XDReplicate.ps1 -mode export -XMLPATH "C:\temp\my.xml" -tag "replicate"`

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

### Changelog

- 02-28-2017: Initial release
- 05-09-2017: Added "Site" option to only replicate specific site.

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
