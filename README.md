[![Build status](https://ci.appveyor.com/api/projects/status/00p66jdhcj8nib0c/branch/master?retina=true)](https://ci.appveyor.com/project/ryancbutler/xdreplicate/branch/master)
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
### Inspect
```
Save-Script -Name XDReplicate -Path <path>
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
- 09-12-17: Fix for desktop permissions
- 09-13-17: Fix for admin permsissions

### XenDesktop Versions Tested

- 7.6 (LTSR)
- 7.11
- 7.12
- 7.14.1
- 7.15

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
  - Multiple Delivery Groups
 
 - Application Groups
 
   - Users
   - Applications
   - Settings
   - Delivery Groups
 

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

Moved to dedicated repo [PVSReplicate](https://github.com/ryancbutler/PVSReplicate)
