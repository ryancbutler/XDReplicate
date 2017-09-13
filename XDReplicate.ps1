<#PSScriptInfo

.VERSION 1.4.5

.GUID a71f41cd-c06d-4735-803c-c3689b962f0a

.AUTHOR @ryan_c_butler

.COMPANYNAME Techdrabble.com

.COPYRIGHT 2017

.TAGS Citrix XenDesktop Export Import PublishedApps

.LICENSEURI https://github.com/ryancbutler/XDReplicate/blob/master/License.txt

.PROJECTURI https://github.com/ryancbutler/XDReplicate

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
05-11-17 Added LTSR Check and fix ICON creation
05-12-17 Bug fixes
05-22-17 fixes around browsername and permissions
06-01-17 Fixes for BrokerPowerTimeScheme on desktop groups
06-23-17 Fixes for folder creation and BrokerPowerTimeScheme
07-12-17 Fixes for app creation and user permissions
07-13-17 String fix for app creation on command line argument. Also fixes thanks to Joe Shonk
07-23-17: Added arguments to include\exclude apps and delivery groups based on tags
07-23-17: Edits to tag import based on XD site version
07-23-17: Better handling of app renames
07-26-17: Converted to strict-mode and documented functions
07-26-17: Added check for name conflict on app creation and warns user of possible name conflict
07-26-17: Added some color to output
08-04-17: LTSR doesn't like APP tags for get-brokerapplication.  Removed strict-mode for now
08-09-17: Changes to DDCVERSION check
08-21-17: App Entitlement fixes for DG groups without desktops
08-28-17: Updated for PS gallery
09-12-17: Fix for desktop permissions
#> 

<#
.SYNOPSIS
   Exports XenDesktop 7.x site information and imports to another Site
.DESCRIPTION
   Exports XenDesktop site information such as administrators, delivery groups, desktops, applications and admin folder to either variable or XML file.  Then will import same information and either create or update.   
.NOTES 
   Twitter: ryan_c_butler
   Website: Techdrabble.com
   Requires: Powershell v3 or greater and Citrix snapins
.LINK
   https://github.com/ryancbutler/XDReplicate
.PARAMETER SOURCE
   XenDesktop DDC source hostname to import (Default: localhost)
.PARAMETER DESTINATION
   XenDesktop DDC destination hostname to export
.PARAMETER MODE
   Export: Exports to XML file (must have XMLPATH set)
   Import: Import from XML file (must have XMLPATH set)
   BOTH: Exports and imports in the same run (must have DESTINATION set)
.PARAMETER XMLPATH
   Path used for XML file location on import and export operations
.PARAMETER DGTAG
   Only export delivery groups with specified tag
.PARAMETER IGNOREDGTAG
   Skips export of delivery groups with specified tag
.PARAMETER APPTAG
   Export delivery group applications with specific tag
.PARAMETER IGNOREAPPTAG
   Exports all delivery group applications except ones with specific tag
.EXAMPLE
   .\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM
   Exports data from localhost and imports on DDC02.DOMAIN.COM
.EXAMPLE
   .\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -dgtag "replicate"
   Exports data from localhost with delivery groups tagged with "replicate" and imports on DDC02.DOMAIN.COM
.EXAMPLE
   .\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -ignoredgtag "skip"
   Exports data from localhost while skipping delivery groups tagged with "skip" and imports on DDC02.DOMAIN.COM
.EXAMPLE
   .\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -apptag "replicate"
   Exports data from localhost delivery groups while only including apps tagged with "replicate" and imports on DDC02.DOMAIN.COM
.EXAMPLE
   .\XDReplicate.ps1 -mode both -destination DDC02.DOMAIN.COM -ignoreapptag "skip"
   Exports data from localhost delivery groups while ignoring apps tagged with "skip" and imports on DDC02.DOMAIN.COM
.EXAMPLE
   .\XDReplicate.ps1 -mode export -XMLPATH "C:\temp\my.xml"
   Exports data from localhost and exports to C:\temp\my.xml
.EXAMPLE
   .\XDReplicate.ps1 -mode import -XMLPATH "C:\temp\my.xml"
   Imports data from C:\temp\my.xml and imports to localhost
#>
Param
(
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateSet('import','export','both')]
    [string]$mode,
    [String]$source = $env:COMPUTERNAME ,
    [String]$destination,
    [String]$xmlpath,
    [String]$dgtag = "",
    [string]$ignoredgtag ="",
    [String]$apptag = "",
    [String]$ignoreapptag = ""

)
#Set-StrictMode -Version Latest
Clear-Host
Add-PSSnapin citrix*
function export-xd 
{
<#
.SYNOPSIS
    Exports XD site information to variable
.DESCRIPTION
    Exports XD site information to variable
.PARAMETER XDHOST
   XenDesktop DDC hostname to connect to
.PARAMETER MODE
   Script mode (provides further option validation)
.PARAMETER DGTAG
   Only export delivery groups with specified tag
.PARAMETER IGNOREDGTAG
   Skips export of delivery groups with specified tag
.PARAMETER APPTAG
   Export delivery group applications with specific tag
.PARAMETER IGNOREAPPTAG
   Exports all delivery group applications except ones with specific tag
#>

Param (
[Parameter(Mandatory=$true)][string]$xdhost,
[Parameter(Mandatory=$true)][string]$mode,
[Parameter(Mandatory=$false)][string]$dgtag,
[Parameter(Mandatory=$false)][string]$ignoredgtag,
[Parameter(Mandatory=$false)][string]$apptag,
[Parameter(Mandatory=$false)][string]$ignoreapptag
)
    
    #Need path for XML while in EXPORT
    if($mode -like "export" -and ([string]::IsNullOrWhiteSpace($XMLPath)))
    {
    throw "Must Set Export Path while mode is set to EXPORT"
    }
    $ddcver = (Get-BrokerController -AdminAddress $xdhost).ControllerVersion | select -first 1


    if(-not ([string]::IsNullOrWhiteSpace($dgtag)))
    {
    $DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -Tag $dgtag -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoredgtag}
    }
    else
    {
    $DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoredgtag}
    }

    if(!($DesktopGroups -is [object]))
    {
    throw "NO DELIVERY GROUPS FOUND"
    }

    #Create Empty arrays
    $appobject = @()
    $desktopobject = @()

    #Each delivery group
    foreach ($DG in $DesktopGroups)
    {
        write-host $DG.Name
        $dg|add-member -NotePropertyName 'AccessPolicyRule' -NotePropertyValue (Get-BrokerAccessPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid -MaxRecordCount 2000)
        $dg|add-member -NotePropertyName 'PreLaunch' -NotePropertyValue (Get-BrokerSessionPreLaunch -AdminAddress $xdhost -Desktopgroupuid $dg.Uid -ErrorAction SilentlyContinue)
        $dg|add-member -NotePropertyName 'PowerTime' -NotePropertyValue (Get-BrokerPowerTimeScheme -AdminAddress $xdhost -Desktopgroupuid $dg.Uid -ErrorAction SilentlyContinue)
        
        #Grabs APP inf
        if(-not ([string]::IsNullOrWhiteSpace($apptag)))
        {
            #App argument doesn't exist for LTSR.  Guessing 7.11 is the first to support
            if ([version]$ddcver -lt "7.11")
            {
                write-warning "Ignoring APP TAG ARGUMENTS."
                $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000
            }
            else {
                $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -Tag $apptag -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoreapptag}
            }
        
        }
        else
        {
            if ([version]$ddcver -lt "7.11")
            {
            $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000  
            
            }
            else {
            $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoreapptag}
            }
        }

        
        if($apps -is [object])
        {   
            foreach ($app in $apps)
            {
                Write-Host "Processing $($app.ApplicationName)"

                #Icon data
                $BrokerEnCodedIconData = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($app.IconUid)).EncodedIconData
                $app|add-member -NotePropertyName 'EncodedIconData' -NotePropertyValue $BrokerEnCodedIconData
                #Adds delivery group name to object
                $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
    
                #File type associations
                $ftatemp = @()
                Get-BrokerConfiguredFTA -AdminAddress $xdhost -ApplicationUid $app.Uid | ForEach-Object -Process {
                $ftatemp += $_
                }
            
                if($ftatemp.count -gt 0)
                {
                $app|add-member -NotePropertyName "FTA" -NotePropertyValue $ftatemp
                }
          
            $appobject += $app
            }    
        }
    

    #Grabs Desktop info
    $desktops = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid -MaxRecordCount 2000
        if($desktops -is [object])
        {
    
            foreach ($desktop in $desktops)
            {
            Write-Host "Processing $($desktop.Name)"
            #Adds delivery group name to object
            $desktop|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
            $desktopobject += $desktop
            }
    
        }
    #}


}

    #buid output object
    $xdout = New-Object PSCustomObject
    Write-Host "Processing Administrators"
    $xdout|Add-Member -NotePropertyName "admins" -NotePropertyValue (Get-AdminAdministrator -AdminAddress $xdhost)
    Write-Host "Processing Scopes"
    $xdout|Add-Member -NotePropertyName "adminscopes" -NotePropertyValue (Get-AdminScope -AdminAddress $xdhost|where-object{$_.BuiltIn -eq $false})
    Write-Host "Processing Roles"
    $xdout|Add-Member -NotePropertyName "adminroles" -NotePropertyValue (Get-AdminRole -AdminAddress $xdhost|where-object{$_.BuiltIn -eq $false})
    $xdout|Add-Member -NotePropertyName "dgs" -NotePropertyValue $DesktopGroups
    $xdout|Add-Member -NotePropertyName "apps" -NotePropertyValue $appobject
    $xdout|Add-Member -NotePropertyName "desktops" -NotePropertyValue $desktopobject
    Write-Host "Processing Tags"
    $xdout|Add-Member -NotePropertyName "tags" -NotePropertyValue (Get-BrokerTag -AdminAddress $xdhost -MaxRecordCount 2000)

    #Export to either variable or XML
    if($mode -like "export")
    {
    write-host "Writing to $($XMLPath)" -ForegroundColor Green
    $xdout|Export-Clixml -Path ($XMLPath)
    }
    else
    {
    return $xdout
    }

}


function Test-BrokerAdminFolder 
{
<#
.SYNOPSIS
    Tests if administrative folder exists
.DESCRIPTION
    Checks for administrative folder and returns bool
.PARAMETER FOLDER
    Folder to validate
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>

Param(
[Parameter(Mandatory=$true)][string]$folder,
[Parameter(Mandatory=$true)][string]$xdhost)
    
    write-host "Processing Folder $folder" -ForegroundColor Magenta
    #Doesn't follow normal error handling so can't use try\catch
    Get-BrokerAdminFolder -AdminAddress $xdhost -name $folder -ErrorVariable myerror -ErrorAction SilentlyContinue
    if ($myerror -like "Object does not exist")
    {
    write-host "FOLDER NOT FOUND" -ForegroundColor YELLOW
    $found = $false
    }
    else
    {
    write-host "FOLDER FOUND" -ForegroundColor GREEN
    $found = $true
    }
return $found
}

function new-adminfolders 
{
<#
.SYNOPSIS
    Creates new administrative folder
.DESCRIPTION
    Checks for and creates administrative folder if not found
.PARAMETER FOLDER
    Folder to validate
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param(
[Parameter(Mandatory=$true)][string]$folder,
[Parameter(Mandatory=$true)][string]$xdhost
)
$paths = @($folder -split "\\"|where-object{$_ -ne ""})

            $lastfolder = $null
            for($d=0; $d -le ($paths.Count -1); $d++)
            {          
            if($d -eq 0)
                {                  
                    if((Test-BrokerAdminFolder -folder ($paths[$d] + "\") -xdhost $xdhost) -eq $false)
                    {
                     New-BrokerAdminFolder -AdminAddress $xdhost -FolderName $paths[$d]|Out-Null
                    }
                $lastfolder = $paths[$d]
                }
                else
                {                    
                    if((Test-BrokerAdminFolder -folder ($lastfolder + "\" + $paths[$d] + "\") -xdhost $xdhost) -eq $false)
                    {
                    New-BrokerAdminFolder -AdminAddress $xdhost -FolderName $paths[$d] -ParentFolder $lastfolder|Out-Null
                    }
                $lastfolder = $lastfolder + "\" + $paths[$d]
                }            
            }
}

function new-appobject 
{
<#
.SYNOPSIS
    Creates broker application script block
.DESCRIPTION
    Script block to create application is returned to be piped to invoke-command
.PARAMETER APP
    Broker Application to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER DGMATCH
    Delivery group to create application

#>
Param(
[Parameter(Mandatory=$true)]$app,
[Parameter(Mandatory=$true)][string]$xdhost, 
[Parameter(Mandatory=$true)][string]$dgmatch
)

$tempvarapp = "New-BrokerApplication -adminaddress $($xdhost) -DesktopGroup `"$($dgmatch)`""
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
         $tempstring = "" 
            switch ($t.name)
            {
                "AdminFolderName" {$tempstring = " -AdminFolder `"$($t.value)`""}
                "ApplicationGroup" {$tempstring = " -ApplicationGroup `"$($t.value)`""}
                "ApplicationType" {$tempstring = " -ApplicationType `"$($t.value)`""}
                "BrowserName" {$tempstring = " -BrowserName `"$($t.value)`""}
                "ClientFolder" {$tempstring = " -ClientFolder `"$($t.value)`""}
                "CommandLineArguments" {$tempstring = " -CommandLineArguments '{0}'" -f $t.value }
                #"CommandLineArguments" {$tempstring = " -CommandLineArguments `"$($t.value)`"" }
                "CommandLineExecutable" {$tempstring = " -CommandLineExecutable `"$($t.value)`""}
                "CpuPriorityLevel" {$tempstring = " -CpuPriorityLevel `"$($t.value)`""}
                "DesktopGroup" {$tempstring = " -DesktopGroup `"$($t.value)`""}
                "Description" {$tempstring = " -Description `"$($t.value)`""}
                "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
                "MaxPerUserInstances" {$tempstring = " -MaxPerUserInstances `"$($t.value)`""}
                "MaxTotalInstances" {$tempstring = " -MaxTotalInstances `"$($t.value)`""}
                "Name" {$tempstring = " -name `"$($app.applicationname)`""}
                "Priority" {$tempstring = " -Priority `"$($t.value)`""}
                "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
                "SecureCmdLineArgumentsEnabled" {$tempstring = " -SecureCmdLineArgumentsEnabled `$$($t.value)"}
                "ShortcutAddedToDesktop" {$tempstring = " -ShortcutAddedToDesktop `$$($t.value)"}
                "ShortcutAddedToStartMenu" {$tempstring = " -ShortcutAddedToStartMenu `$$($t.value)"}
                "StartMenuFolder" {$tempstring = " -StartMenuFolder `"$($t.value)`""}
                "UserFilterEnabled" {$tempstring = " -UserFilterEnabled `$$($t.value)"}
                "Visible" {$tempstring = " -Visible `$$($t.value)"}
                "WaitForPrinterCreation" {$tempstring = " -WaitForPrinterCreation `$$($t.value)"}
                "WorkingDirectory" {$tempstring = " -WorkingDirectory `"$($t.value)`""}
            
            }
         $tempvarapp = $tempvarapp +  $tempstring
         }
    }

return $tempvarapp
}

function set-existingappobject 
{
<#
.SYNOPSIS
    Sets an existing broker application settings
.DESCRIPTION
    Script block to set an application is returned to be piped to invoke-command
.PARAMETER APP
    Exported aplication
.PARAMETER APPMATCH
    Existing application
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param(
[Parameter(Mandatory=$true)]$app,
[Parameter(Mandatory=$true)]$appmatch, 
[Parameter(Mandatory=$true)][string]$xdhost)

$tempvarapp = "Set-BrokerApplication -adminaddress $($xdhost)"
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
                "ClientFolder" {$tempstring = " -ClientFolder `"$($t.value)`""}
                #"CommandLineArguments" {$tempstring = " -CommandLineArguments `"$($t.value)`"" }
                "CommandLineArguments" {$tempstring = " -CommandLineArguments '{0}'" -f $t.value }
                "CommandLineExecutable" {$tempstring = " -CommandLineExecutable `"$($t.value)`""}
                "CpuPriorityLevel" {$tempstring = " -CpuPriorityLevel `"$($t.value)`""}
                "Description" {$tempstring = " -Description `"$($t.value)`""}
                "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
                "MaxPerUserInstances" {$tempstring = " -MaxPerUserInstances `"$($t.value)`""}
                "MaxTotalInstances" {$tempstring = " -MaxTotalInstances `"$($t.value)`""}
                "Name" {$tempstring = " -name `"$($appmatch.Name)`""}
                "Priority" {$tempstring = " -Priority `"$($t.value)`""}
                "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
                "SecureCmdLineArgumentsEnabled" {$tempstring = " -SecureCmdLineArgumentsEnabled `$$($t.value)"}
                "ShortcutAddedToDesktop" {$tempstring = " -ShortcutAddedToDesktop `$$($t.value)"}
                "ShortcutAddedToStartMenu" {$tempstring = " -ShortcutAddedToStartMenu `$$($t.value)"}
                "StartMenuFolder" {$tempstring = " -StartMenuFolder `"$($t.value)`""}
                "UserFilterEnabled" {$tempstring = " -UserFilterEnabled `$$($t.value)"}
                "Visible" {$tempstring = " -Visible `$$($t.value)"}
                "WaitForPrinterCreation" {$tempstring = " -WaitForPrinterCreation `$$($t.value)"}
                "WorkingDirectory" {$tempstring = " -WorkingDirectory `"$($t.value)`""}
            }
         $tempvarapp = $tempvarapp +  $tempstring
         }
    }
return $tempvarapp
}

function Set-Desktopobject 
{
<#
.SYNOPSIS
    Sets existing desktop entitlement settings
.DESCRIPTION
    Script block to set desktop entitlement is returned to be piped to invoke-expression
.PARAMETER Desktop
    Exported Desktop
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
[Parameter(Mandatory=$true)]$desktop, 
[Parameter(Mandatory=$true)][string]$xdhost)

$tempvardesktop = "Set-BrokerEntitlementPolicyRule -adminaddress $($xdhost)"
foreach($t in $desktop.PSObject.Properties)
    {
           
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
                "Name" {$tempstring = " -name `"$($t.value)`""}
                "ColorDepth" {$tempstring = " -ColorDepth `"$($t.value)`""}
                "Description" {$tempstring = " -Description `"$($t.value)`""}
                "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
                "LeasingBehavior" {$tempstring = " -LeasingBehavior `"$($t.value)`""}
                "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
                "RestrictToTag" {$tempstring = " -RestrictToTag `"$($t.value)`""}
                "SecureIcaRequired" {$tempstring = " -SecureIcaRequired `"$($t.value)`""}
                "SessionReconnection" {$tempstring = " -SessionReconnection `"$($t.value)`""}
               
            }
         $tempvardesktop = $tempvardesktop +  $tempstring
         }
    }
return $tempvardesktop
}

function New-Desktopobject 
{
<#
.SYNOPSIS
    Creates new Desktop entitlement policy Object script block
.DESCRIPTION
    Creates new Desktop entitlement policy object script block and returns to be used by invoke-expression
.PARAMETER Desktop
    New desktop object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER DGUID
    Delivery group UID to create desktop
#>
Param(
[Parameter(Mandatory=$true)]$desktop, 
[Parameter(Mandatory=$true)][string]$xdhost, 
[Parameter(Mandatory=$true)][string]$dguid)

$tempvardesktop = "New-BrokerEntitlementPolicyRule -adminaddress $($xdhost) -DesktopGroupUid $($dguid)"
foreach($t in $desktop.PSObject.Properties)
    {
           
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
                "Name" {$tempstring = " -name `"$($t.value)`""}
                "ColorDepth" {$tempstring = " -ColorDepth `"$($t.value)`""}
                "Description" {$tempstring = " -Description `"$($t.value)`""}
                "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
                "IncludedUserFilterEnabled" {$tempstring = " -IncludedUserFilterEnabled `$$($t.value)"}
                "LeasingBehavior" {$tempstring = " -LeasingBehavior `"$($t.value)`""}
                "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
                "RestrictToTag" {$tempstring = " -RestrictToTag `"$($t.value)`""}
                "SecureIcaRequired" {$tempstring = " -SecureIcaRequired `"$($t.value)`""}

                #"SessionReconnection" {$tempstring = " -SessionReconnection `"$($t.value)`""} Fails for LTSR
               
            }
         $tempvardesktop = $tempvardesktop +  $tempstring
         }
    }
return $tempvardesktop
}

function New-DeliveryGroupObject 
{
<#
.SYNOPSIS
    Creates new Desktop Delivery Group Object script block
.DESCRIPTION
    Creates new Desktop Delivery Group Object script block and returns to be used by invoke-command
.PARAMETER DG
    New Delivery group object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param(
[Parameter(Mandatory=$true)]$dg, 
[Parameter(Mandatory=$true)][string]$xdhost
)
$tempvardg = "New-BrokerDesktopGroup -adminaddress $($xdhost)"
foreach($t in $dg.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
            "Name" {$tempstring = " -Name `"$($t.value)`""}
            "DesktopKind" {$tempstring = " -DesktopKind `"$($t.value)`""}
            "AutomaticPowerOnForAssigned" {$tempstring = " -AutomaticPowerOnForAssigned `$$($t.value)"}
            "AutomaticPowerOnForAssignedDuringPeak" {$tempstring = " -AutomaticPowerOnForAssignedDuringPeak `$$($t.value)"}
            "ColorDepth" {$tempstring = " -ColorDepth `"$($t.value)`""}
            "DeliveryType" {$tempstring = " -DeliveryType `"$($t.value)`""}
            "Description" {$tempstring = " -Description `"$($t.value)`""}
            "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
            "InMaintenanceMode" {$tempstring = " -InMaintenanceMode `$$($t.value)"}
            "IsRemotePC" {$tempstring = " -IsRemotePC `$$($t.value)"}
            "MinimumFunctionalLevel" {$tempstring = " -MinimumFunctionalLevel `"$($t.value)`""}
            "OffPeakBufferSizePercent" {$tempstring = " -OffPeakBufferSizePercent `"$($t.value)`""}
            "OffPeakDisconnectAction" {$tempstring = " -OffPeakDisconnectAction `"$($t.value)`""}
            "OffPeakDisconnectTimeout" {$tempstring = " -OffPeakDisconnectTimeout `"$($t.value)`""}
            "OffPeakExtendedDisconnectAction" {$tempstring = " -OffPeakExtendedDisconnectAction `"$($t.value)`""}
            "OffPeakExtendedDisconnectTimeout" {$tempstring = " -OffPeakExtendedDisconnectTimeout `"$($t.value)`""}
            "OffPeakLogOffAction" {$tempstring = " -OffPeakLogOffAction `"$($t.value)`""}
            "OffPeakLogOffTimeout" {$tempstring = " -OffPeakLogOffTimeout `"$($t.value)`""}
            "PeakBufferSizePercent" {$tempstring = " -PeakBufferSizePercent `"$($t.value)`""}
            "PeakDisconnectAction" {$tempstring = " -PeakDisconnectAction `"$($t.value)`""}
            "PeakDisconnectTimeout" {$tempstring = " -PeakDisconnectTimeout `"$($t.value)`""}
            "PeakExtendedDisconnectAction" {$tempstring = " -PeakExtendedDisconnectAction `"$($t.value)`""}
            "PeakExtendedDisconnectTimeout" {$tempstring = " -PeakExtendedDisconnectTimeout `"$($t.value)`""}
            "PeakLogOffAction" {$tempstring = " -PeakLogOffAction `"$($t.value)`""}
            "PeakLogOffTimeout" {$tempstring = " -PeakLogOffTimeout `"$($t.value)`""}
            "ProtocolPriority" {$tempstring = " -ProtocolPriority `"$($t.value)`""}
            "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
            "SecureIcaRequired" {$tempstring = " -SecureIcaRequired `$$($t.value)"}
            "SessionSupport" {$tempstring = " -SessionSupport `"$($t.value)`""}
            "ShutdownDesktopsAfterUse" {$tempstring = " -ShutdownDesktopsAfterUse `$$($t.value)"}
            "SettlementPeriodBeforeAutoShutdown" {$tempstring = " -SettlementPeriodBeforeAutoShutdown `"$($t.value)`""}
            "TimeZone" {$tempstring = " -TimeZone `"$($t.value)`""}
            "TurnOnAddedMachine" {$tempstring = " -TurnOnAddedMachine `$$($t.value)"}
            }
            $tempvardg = $tempvardg +  $tempstring
             
         }
    }
 return $tempvardg
}

function Set-ExistingDeliveryGroupObject
{
<#
.SYNOPSIS
    Creats existing delivery group object scriptblock
.DESCRIPTION
    Creats existing delivery group object scriptblock and returned to be used with invoke-expression
.PARAMETER DG
    Delivery Group object to be created
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
[Parameter(Mandatory=$true)]$dg,
[Parameter(Mandatory=$true)][string]$xdhost
)

$tempvardg = "Set-BrokerDesktopGroup -adminaddress $($xdhost)"
foreach($t in $dg.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
            "Name" {$tempstring = " -Name `"$($t.value)`""}
            "AutomaticPowerOnForAssigned" {$tempstring = " -AutomaticPowerOnForAssigned `$$($t.value)"}
            "AutomaticPowerOnForAssignedDuringPeak" {$tempstring = " -AutomaticPowerOnForAssignedDuringPeak `$$($t.value)"}
            "ColorDepth" {$tempstring = " -ColorDepth `"$($t.value)`""}
            "DeliveryType" {$tempstring = " -DeliveryType `"$($t.value)`""}
            "Description" {$tempstring = " -Description `"$($t.value)`""}
            "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
            "InMaintenanceMode" {$tempstring = " -InMaintenanceMode `$$($t.value)"}
            "IsRemotePC" {$tempstring = " -IsRemotePC `$$($t.value)"}
            "MinimumFunctionalLevel" {$tempstring = " -MinimumFunctionalLevel `"$($t.value)`""}
            "OffPeakBufferSizePercent" {$tempstring = " -OffPeakBufferSizePercent `"$($t.value)`""}
            "OffPeakDisconnectAction" {$tempstring = " -OffPeakDisconnectAction `"$($t.value)`""}
            "OffPeakDisconnectTimeout" {$tempstring = " -OffPeakDisconnectTimeout `"$($t.value)`""}
            "OffPeakExtendedDisconnectAction" {$tempstring = " -OffPeakExtendedDisconnectAction `"$($t.value)`""}
            "OffPeakExtendedDisconnectTimeout" {$tempstring = " -OffPeakExtendedDisconnectTimeout `"$($t.value)`""}
            "OffPeakLogOffAction" {$tempstring = " -OffPeakLogOffAction `"$($t.value)`""}
            "OffPeakLogOffTimeout" {$tempstring = " -OffPeakLogOffTimeout `"$($t.value)`""}
            "PeakBufferSizePercent" {$tempstring = " -PeakBufferSizePercent `"$($t.value)`""}
            "PeakDisconnectAction" {$tempstring = " -PeakDisconnectAction `"$($t.value)`""}
            "PeakDisconnectTimeout" {$tempstring = " -PeakDisconnectTimeout `"$($t.value)`""}
            "PeakExtendedDisconnectAction" {$tempstring = " -PeakExtendedDisconnectAction `"$($t.value)`""}
            "PeakExtendedDisconnectTimeout" {$tempstring = " -PeakExtendedDisconnectTimeout `"$($t.value)`""}
            "PeakLogOffAction" {$tempstring = " -PeakLogOffAction `"$($t.value)`""}
            "ProtocolPriority" {$tempstring = " -ProtocolPriority `"$($t.value)`""}
            "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
            "SecureIcaRequired" {$tempstring = " -SecureIcaRequired `$$($t.value)"}
            "ShutdownDesktopsAfterUse" {$tempstring = " -ShutdownDesktopsAfterUse `$$($t.value)"}
            "TimeZone" {$tempstring = " -TimeZone `"$($t.value)`""}
            "TurnOnAddedMachine" {$tempstring = " -TurnOnAddedMachine `$$($t.value)"}
            }
            $tempvardg = $tempvardg +  $tempstring
             
         }
    }
return $tempvardg
}

function set-UserPerms
{
<#
.SYNOPSIS
    Sets user permissions on desktop
.DESCRIPTION
    Sets user permissions on desktop
.PARAMETER APP
    Exported desktop object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
[Parameter(Mandatory=$true)]$desktop, 
[Parameter(Mandatory=$true)][string]$xdhost)
    
    if ($desktop.IncludedUserFilterEnabled)
    {
        Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -AddIncludedUsers $desktop.includedusers -Name $desktop.Name
    }

    if ($desktop.ExcludedUserFilterEnabled)
    {
        Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -AddExcludedUsers $desktop.excludedusers -Name $desktop.Name
    }

}

function set-NewAppUserPerms
{
<#
.SYNOPSIS
    Sets user permissions on NEW app
.DESCRIPTION
    Sets user permissions on NEW app
.PARAMETER APP
    Exported application
.PARAMETER APPMATCH
    Newly created app
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)]$appmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )

if ($app.UserFilterEnabled)
        {
        write-host "Setting App Permissions" -ForegroundColor Green
             foreach($user in $app.AssociatedUserNames)
             {
                write-host $user
                Add-BrokerUser -AdminAddress $xdhost -Name $user -Application $appmatch.Name
             }
        }
    

}

function Set-AppEntitlement  {
<#
.SYNOPSIS
    Sets AppEntitlement if missing
.DESCRIPTION
    Sets AppEntitlement if missing
.PARAMETER DG
    Desktop Group where to create entitlement
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
    [Parameter(Mandatory=$true)]$dg, 
    [Parameter(Mandatory=$true)][string]$xdhost)
    if (($dg.DeliveryType -like "AppsOnly" -or $dg.DeliveryType -like "DesktopsAndApps"))
    {
        if((Get-BrokerAppEntitlementPolicyRule -name $dg.Name -AdminAddress $xdhost -ErrorAction SilentlyContinue) -is [Object])
        {
        write-host "AppEntitlement already present"
        }
        ELSE
        {
        write-host "Creating AppEntitlement"
        New-BrokerAppEntitlementPolicyRule -Name $dg.Name -DesktopGroupUid $dg.uid -AdminAddress $xdhost -IncludedUserFilterEnabled $false|Out-Null
        }
    }
    else
    {
    write-host "No AppEntitlement needed"
    }

}

function clear-AppUserPerms 
{
<#
.SYNOPSIS
    Clears permissions from App
.DESCRIPTION
    Clears permissions from App
.PARAMETER APP
    Application to remove permissions
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )
    
    if ($app.UserFilterEnabled)
        {
             foreach($user in $app.AssociatedUserNames)
             {
                $user = get-brokeruser $user
                Remove-BrokerUser -AdminAddress $xdhost -inputobject $user -Application $app.Name|Out-Null
             }
        }
}

function clear-DesktopUserPerms
{
<#
.SYNOPSIS
    Clears permissions from Desktop object
.DESCRIPTION
    Clears permissions from Desktop object
.PARAMETER DESKTOP
    Desktop to remove permissions
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
Param (
    [Parameter(Mandatory=$true)]$desktop, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )


        if ($desktop.IncludedUserFilterEnabled)
        {
            foreach($user in $desktop.IncludedUsers)
            {
            Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -RemoveIncludedUsers $user -Name $desktop.Name
            }
        }

        if ($desktop.ExcludedUserFilterEnabled)
        {
            foreach($user in $desktop.ExcludedUsers)
            {
            Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -RemoveExcludedUsers $user -Name $desktop.Name
            }
        }
 
}

function New-FTAobject
{
<#
.SYNOPSIS
    Creates object to create FTA (File Type Association) object
.DESCRIPTION
    Creates object to create FTA (File Type Association) object
.PARAMETER FTA
    Existing FTA object

#>
Param (
    [Parameter(Mandatory=$true)]$FTA
    )

$tempvarfta = New-Object PSCustomObject
foreach($t in $fta.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
            switch ($t.name)
            {
                "ExtensionName" {$tempvarfta|Add-Member -MemberType NoteProperty -Name "ExtensionName" -Value $t.Value}
                "ContentType" {$tempvarfta|Add-Member -MemberType NoteProperty -Name "ContentType" -Value $t.Value}
                "HandlerOpenArguments" {$tempvarfta|Add-Member -MemberType NoteProperty -Name "HandlerOpenArguments" -Value $t.Value}
                "HandlerDescription" {$tempvarfta|Add-Member -MemberType NoteProperty -Name "HandlerDescription" -Value $t.Value}
                "HandlerName" {$tempvarfta|Add-Member -MemberType NoteProperty -Name "HandlerName" -Value $t.Value}
            }
         }
    }

return $tempvarfta
}

function test-icon
{
<#
.SYNOPSIS
    Tests to see if Icon exists and matches new application
.DESCRIPTION
    Tests to see if Icon exists and matches new application
.PARAMETER APP
    Newly created application
.PARAMETER APPMATCH
    Existing application
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to

#>
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)]$appmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )

    $newicon = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($appmatch.IconUid)).EncodedIconData
    if($newicon -like $app.EncodedIconData)
    {
    write-host Icons Match
    $match = $true
    }
    else
    {
    write-host Icons do not match -ForegroundColor Yellow
    $match = $false
    }
return $match
}

function import-xd
{
<#
.SYNOPSIS
    Imports XD site information from object
.DESCRIPTION
    Imports XD site information from object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER XDEXPORT
    XD site object to import
#>

Param (
    [Parameter(Mandatory=$true)][string]$xdhost, 
    [Parameter(Mandatory=$true)]$xdexport)
    if (!($XDEXPORT))
    {
    throw "Nothing to import"
    }

    write-host "Proccessing Tags" -ForegroundColor Magenta
    #Description argument not added until 7.11
    $ddcver = (Get-BrokerController -AdminAddress $xdhost).ControllerVersion | select -first 1
    foreach($tag in $XDEXPORT.tags)
    {  

    $tagmatch = Get-BrokerTag -AdminAddress $xdhost -name $tag.name -ErrorAction SilentlyContinue
        if($tagmatch -is [object])
        {
        write-host "Found TAG $($tag.name)"
        }
        else
        {
        write-host "Creating TAG $($tag.name)" -ForegroundColor Gray
            #Description argument not added until 7.11
            if ([version]$ddcver -lt "7.11")
            {
            New-BrokerTag -AdminAddress $xdhost -Name $tag.name|Out-Null
            }
            else
            {
            New-BrokerTag -AdminAddress $xdhost -Name $tag.name -Description $tag.description|Out-Null
            }
        }
    }
    
    foreach($dg in $XDEXPORT.dgs)
    {
    write-host "Proccessing $($dg.name)" -ForegroundColor Magenta

    $dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.NAME -ErrorAction SilentlyContinue

        if ($dgmatch -is [object])
        {
        write-host "Setting $($dgmatch.name)"
        Set-ExistingDeliveryGroupObject $dg $xdhost|Invoke-Expression
        Get-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid -adminaddress $xdhost|remove-BrokerAccessPolicyRule -AdminAddress $xdhost -ErrorAction SilentlyContinue|Out-Null
        $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid -adminaddress $xdhost|Out-Null
            
            if($dg.powertime -is [object])
            {
                ($dg.PowerTime)|ForEach-Object{
                write-host "Setting Power Time Scheme $($_.name)"
                Set-BrokerPowerTimeScheme -AdminAddress $xdhost -Name $_.name -DisplayName $_.displayname -DaysOfWeek $_.daysofweek -PeakHours $_.peakhours -PoolSize $_.poolsize -PoolUsingPercentage $_.poolusingpercentage -ErrorAction SilentlyContinue|Out-Null
                }
            }
        }
        else
        {
        Write-host "Creating Delivery Group" -ForegroundColor Green
            try
            {
            write-host $dg.Name
            $dgmatch = New-DeliveryGroupObject $dg $xdhost|Invoke-Expression
            }
            Catch
            {
            throw "Delivery group failed. $($_.Exception.Message)"
            }
        $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null
            if($dg.powertime -is [object])
            {        
                ($dg.PowerTime)|ForEach-Object{
                "Creating Power Time Scheme $($_.name)"
                New-BrokerPowerTimeScheme -AdminAddress $xdhost -DesktopGroupUid $dgmatch.uid -Name $_.name -DaysOfWeek $_.daysofweek -PeakHours $_.peakhours -PoolSize $_.poolsize -PoolUsingPercentage $_.poolusingpercentage -DisplayName $_.displayname|Out-Null
                }
            }
        
        if($dg.prelaunch -is [object])
        {
        write-host "Setting pre-launch" -ForegroundColor Gray
        Remove-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupName $dg.Name -ErrorAction SilentlyContinue
        $dg.PreLaunch|New-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null

        }

        }
        

        if(-not([string]::IsNullOrWhiteSpace($dg.tags)))
        {
            foreach ($tag in $dg.tags)
            {
            write-host "Adding TAG $tag" -ForegroundColor gray
            add-brokertag -Name $tag -AdminAddress $xdhost -DesktopGroup $dgmatch.name
            }
        }
    
        $desktops = $XDEXPORT.desktops|where-object{$_.DGNAME -eq $dg.name}
        Set-AppEntitlement $dgmatch $xdhost

                if($desktops)
                {
                foreach ($desktop in $desktops)
                {
                write-host "Proccessing Desktop $($desktop.name)" -ForegroundColor Magenta
                $desktopmatch = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid -Name $desktop.Name -ErrorAction SilentlyContinue
                    if($desktopmatch)
                    {
                    write-host "Setting desktop" -ForegroundColor Gray
                    Set-Desktopobject $desktop $xdhost|invoke-expression
                    clear-DesktopUserPerms $desktopmatch $xdhost
                    set-userperms $desktop $xdhost
                   # Set-AppEntitlement $dgmatch $desktopmatch $xdhost
                    }
                    else
                    {
                    Write-host "Creating Desktop" -ForegroundColor Green
                    $desktopmatch = New-Desktopobject $desktop $xdhost $dgmatch.Uid|invoke-expression
                    set-userperms $desktop $xdhost
                    #Set-AppEntitlement $dgmatch $desktopmatch $xdhost
                    }

                }
            }

        $apps = $XDEXPORT.apps|where-object{$_.DGNAME -eq $dg.name}
        
            if($apps)
            {
                foreach ($app in $apps)
                {
                write-host "Proccessing App $($app.browsername)" -ForegroundColor Magenta
                $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername -ErrorAction SilentlyContinue
                    if($appmatch -is [Object])
                    {
                    write-host "Setting App" -ForegroundColor Gray
                    $folder = $app.AdminFolderName
                    if($folder -is [object])
                    {
                        if ($folder -like $appmatch.AdminFolderName)
                        {
                        write-host In correct folder
                        }
                        else
                        {
                            if (-Not (Test-BrokerAdminFolder -folder $folder -xdhost $xdhost))
                            {
                            write-host "Creating folder" -ForegroundColor Green
                            new-adminfolders $folder $xdhost
                            }
                        Write-host Moving App to correct folder -ForegroundColor Yellow
                        Move-BrokerApplication -AdminAddress $xdhost $appmatch -Destination $app.AdminFolderName
                        $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername -ErrorAction SilentlyContinue
                        }
                    }
                    set-existingappobject $app $appmatch $xdhost|Invoke-Expression

                    #makes sure to rename app to match
                    if($appmatch.ApplicationName -notlike $app.ApplicationName)
                    {
                        write-host "Renaming Application..." -ForegroundColor Yellow
                        rename-brokerapplication -AdminAddress $xdhost -inputobject $appmatch -newname $app.ApplicationName
                        $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername
                    }

                        if((test-icon $app $appmatch $xdhost) -eq $false)
                        {
                        $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                        $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                        }
                    clear-AppUserPerms $appmatch $xdhost
                    set-NewAppUserPerms $app $appmatch $xdhost
                    }
                    else
                    {
                    write-host "Creating App" -ForegroundColor Green
                    $folder = $app.AdminFolderName
                    if(-not [string]::IsNullOrWhiteSpace($folder))
                    {
                        if (-Not (Test-BrokerAdminFolder -folder $folder -xdhost $xdhost))
                        {
                        write-host "Creating folder" -ForegroundColor Green
                        new-adminfolders $folder $xdhost
                        }
                    }
                    $appmatch = new-appobject $app $xdhost $dgmatch.Name|Invoke-Expression
                    
                    if($appmatch -is [Object])
                    {

                        #sets browsername to match
                        set-brokerapplication -adminaddress $xdhost -inputobject $appmatch -browsername $app.browsername|out-null
                    
                        $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                        $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                        set-NewAppUserPerms $app $appmatch $xdhost
                        
                        if($app|Select-Object -ExpandProperty FTA -ErrorAction SilentlyContinue)
                        {
                            foreach ($fta in $app.FTA)
                            {
                            New-FTAobject -AdminAddress $xdhost $fta|New-BrokerConfiguredFTA -AdminAddress $xdhost -ApplicationUid $newapp.Uid
                            }
                        }
                     
                     if(-not([string]::IsNullOrWhiteSpace($app.tags)))
                        {
                         foreach ($tag in $app.tags)
                         {
                           write-host "Adding TAG $tag" -ForegroundColor gray
                           add-brokertag -Name $tag -AdminAddress $xdhost -Application $appmatch.name
                         }
                        }
                     
                     }
                    else
                    {
                        Write-Warning "App Creation failed.  Check for name conflict. An ApplicationName of $($app.ApplicationName) already exists when using the browser name of $($app.BrowserName)."
 
                    }

                }
 
            }  
  
    }
    }
<#
    $currentscopes = Get-AdminScope -AdminAddress $xdhost
    write-host "Checking Admin scopes"
    foreach ($scope in $XDEXPORT.adminscopes)
    {
        $scopematch = get-adminscope -AdminAddress $xdhost -Name $scope.Name -ErrorAction SilentlyContinue
        if ($scopematch -is [object])
        {
        write-host "Found $($scope.Name)"
        }
        else
        {
        write-host "Adding $($scope.name)" -foreground green
        ## TO DO
        #New-AdminScope -AdminAddress $xdhost -Name $scope.Name

        }

    }
#>


    #$currentroles = Get-AdminPermission -AdminAddress $xdhost
    write-host "Processing Admin Roles" -ForegroundColor Magenta
    foreach ($role in $XDEXPORT.adminroles)
    {
        $rolematch = Get-AdminRole -AdminAddress $xdhost -Name $role.name -ErrorAction SilentlyContinue
        if ($rolematch -is [object])
        {
        write-host "Found $($role.Name)"
        }
        else
        {
        write-host "Adding $($role.name)" -foreground green
        New-AdminRole -AdminAddress $xdhost -Description $role.Description -Name $role.Name|out-null
        Add-AdminPermission -AdminAddress $xdhost -Permission $role.Permissions -Role $role.name|out-null
        }
    }


    #$currentadmins = Get-AdminAdministrator -AdminAddress $xdhost
    write-host "Processing admins" -ForegroundColor Magenta
    foreach ($admin in $XDEXPORT.admins)
    {

        $adminmatch = Get-AdminAdministrator -Sid $admin.Sid -AdminAddress $xdhost -ErrorAction SilentlyContinue
        if ($adminmatch -is [object])
        {
        write-host "Found $($admin.Name)"
        }
        else
        {
        write-host "Adding $($admin.Name)" -ForegroundColor Green
        New-AdminAdministrator -AdminAddress $xdhost -Enabled $admin.Enabled -Sid $admin.Sid|out-null
        Add-AdminRight -AdminAddress $xdhost -Administrator $admin.Name -InputObject $admin.Rights|Out-Null
        }

    }



}

#Start process

#LTSR doesn't have TAG argument in get-brokerapplication.
$ddcver = (Get-BrokerController -AdminAddress $source).ControllerVersion | select -first 1
if ([version]$ddcver -lt 7.11 -and (-not [string]::IsNullOrWhiteSpace($ignoreapptag) -or -not [string]::IsNullOrWhiteSpace($apptag) ))
{
    write-warning "TAGS not available for Get-BrokerApplication in $ddcver version.  APP TAG filtering not possible.  ALL APPLICATIONS WILL BE EXPORTED! `nContinue in 10 seconds..."
    Start-Sleep -Seconds 10
}


        switch ($mode)
            {
               "both"{
                    if([string]::IsNullOrWhiteSpace($destination))
                    {
                    throw "Must have destination DDC set"
                    }
                write-host "Begining export..." -ForegroundColor Yellow
                $xdexport = export-xd -xdhost $source -mode $mode -dgtag $dgtag -ignoredgtag $ignoredgtag -apptag $apptag -ignoreapptag $ignoreapptag
                write-host "Begining import..." -ForegroundColor Yellow
                import-xd -xdhost $destination -xdexport $xdexport
                }
                "import"{
                    if([string]::IsNullOrWhiteSpace($XMLPATH))
                    {
                    throw "Must XMLPATH set"
                    }

                    if([string]::IsNullOrWhiteSpace($destination))
                    {
                    $destination = "localhost"
                    }
                
                import-xd -xdhost $destination -xdexport (Import-Clixml $xmlpath)
                }
                "export"{
                    if([string]::IsNullOrWhiteSpace($XMLPATH))
                    {
                    throw "Must have XMLPATH set"
                    }
                export-xd -xdhost $source -mode $mode -dgtag $dgtag -ignoredgtag $ignoredgtag -apptag $apptag -ignoreapptag $ignoreapptag
                }
            }

#attempts to set the connection back to the local host
Get-BrokerDBConnection -AdminAddress $env:COMPUTERNAME -ErrorAction SilentlyContinue|Out-Null
