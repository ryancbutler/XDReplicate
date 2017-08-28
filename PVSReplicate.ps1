<#PSScriptInfo

.VERSION 1.6.2

.GUID ae5930b7-9160-4a4f-9b65-88a1574eb06e

.AUTHOR @ryan_c_butler

.COMPANYNAME Techdrabble.com

.COPYRIGHT 2017

.TAGS PVS Replicate vDisk Import Export

.LICENSEURI https://github.com/ryancbutler/XDReplicate/blob/master/License.txt

.PROJECTURI https://github.com/ryancbutler/XDReplicate

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
02-28-17: Initial release
05-09-17: Added "Site" option to only replicate specific site.
07-27-17: Added 'JustAdmin' switch to only replicate to single server
07-27-17: Added 'disk' argument to copy specific disk
08-28-17: Updated for PS gallery

#> 





<#
.SYNOPSIS
   Keep PVS vDisks and versioning consistent across multiple PVS sites and additional PVS farms
.DESCRIPTION
   Checks for vDisks and versioning and will export XML if required.  Script will then robocopy all vDisk files out to all PVS servers.  Once copied script will import and set versioning to match local server.
.NOTES
   Twitter: ryan_c_butler
   Website: Techdrabble.com
   Requires: Powershell v3 or greater and Citrix PVS snapins
   If module fails to import run the following command. %systemroot%\Microsoft.NET\Framework64\v4.0.30319\installutil.exe "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll"
.LINK
   https://github.com/ryancbutler/XDReplicate
.PARAMETER PVSServers
   PVS Server hostnames that have access to additonal farms.
.PARAMETER StorePath
   Local Disk Store Path (same path must exist on all servers)
.PARAMETER NoCopy
    Doesn't copy any files to other servers.
.PARAMETER DISK
    Specific Disk to copy and import
.PARAMETER JUSTADMIN
    Copies and imports to only admin servers listed
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore"
   Copies and imports disks and versions to all PVS farm servers accessible via localhost and uses the vDisk store at "E:\teststore" for robocopy.
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore" -Site "MySite" -Disk "MYDISK"
   Copies and imports "MYDISK" ONLY to all servers in "MYSITE"
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore" -Site "MySite" -PVSServers "PVSFARM01" -JUSTADMIN
   Copies and imports disks and versions from MYSITE to PVSFARM01 server ONLY. (Images must be replicated from PVSFARM01)
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore" -PVSServers "PVSFARM01","PVSFARM02"
   Copies and imports disks and versions to all PVS farm servers accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" for robocopy.
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore" -PVSServers "PVSFARM01","PVSFARM02" -Site "General"
   Copies and imports disks and versions to all PVS farm servers in 'General' site accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" for robocopy.
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore","E:\teststore2" -PVSServers "PVSFARM01","PVSFARM02"
   Copies and imports disk versions to all PVS farm servers accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" and "E:\teststore2" for robocopy.
.EXAMPLE
   .\PVSReplicate.ps1 -nocopy
   Imports disks and versions on all PVS farm servers accessible via localhost for each server.  Does not perform any robocopy
#>
Param
(
    [array]$PVSServers,
    [array]$storepaths,
    [string]$site,
    [switch]$nocopy,
    [string]$disk="",
    [switch]$justadmin

)


if(!$nocopy -and ([string]::IsNullOrWhiteSpace($storepaths)))
{
    throw "Need Store Path! Otherwise run with -nocopy switch"
    break
}

if($nocopy -and -not ([string]::IsNullOrWhiteSpace($storepaths)))
{
    throw "-nocopy switch does need storepath"
    break
}

if([string]::IsNullOrWhiteSpace($site))
{
    $site = $null
}

import-module "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll"
CLS
#Builds server array
$adminservers = @($env:computername)
if($PVSServers.Count -gt 0)
{
    $adminservers += $PVSServers
}
#Uses robocopy to mirror local disk store
function copy-vhds ($localstorepath,$disk,$justadmin,$adminserver) {
    if($justadmin)
    {
        if($adminserver -ne $env:computername)
        {
        $pvsservers = Get-PvsServer -ServerName $adminserver
        }
        else
        {
        write-host "Skipping local..."
        $pvsservers = $null
        }
    }
    else
    {    
        if($site -ne $null)
        {
        $pvsservers = Get-PvsServer -sitename $site|where{$_.name -ne $env:computername}
        }
        else
        {
        $pvsservers = Get-PvsServer|where{$_.name -ne $env:computername}
        }
    }
    
    foreach ($pvsserver in $pvsservers)
    {
        
        write-host $pvsserver.Name
            if([string]::IsNullOrWhiteSpace($disk))
            {
                $remotestorepath = "\\" + $pvsserver.Name + "\" + ($localstorepath.Replace(":",'$')) + "\"
                if(test-path $remotestorepath)
                {
                write-host $remotestorepath
                Robocopy $localstorepath $remotestorepath /mir /w:5 /r:3 /xf *.lok /xd WriteCache
                }
                else
                {
                write-host "Path not found skipping..." -ForegroundColor Red
                }
            }
            else
            {
                $remotestorepath = "\\" + $pvsserver.Name + "\" + ($localstorepath.Replace(":",'$')) + "\"
                if(test-path $remotestorepath)
                {
                write-host $remotestorepath
                $diskn = "$($disk)*"
                Robocopy $localstorepath $remotestorepath $diskn /w:5 /r:3 /xf *.lok
                }
                else
                {
                write-host "Path not found skipping..." -ForegroundColor Red
                }
            }

    }
    
}
#Checks through disks and exports XML if a new version exists or override present
function export-alldisks($specdisk) {
    Set-PvsConnection -Server $env:computername -PassThru|out-null
 
 
 
 
    $pvsserversite = Get-PvsServer -ServerName $env:computername
    $pvssite = get-pvssite -SiteName $pvsserversite.SiteName
 
        write-host "Checking Site: $($pvssite.Name)" -ForegroundColor Yellow
        $stores = Get-PvsStore|where{$_.SiteName -eq $pvssite.Name}
      
                    

            foreach ($store in $stores)
            {
            if([string]::IsNullOrWhiteSpace($specdisk))
            {
            write-host "Checking Store: $($store.Name)" -ForegroundColor Yellow
            $testpath = "\\" + $pvssite.DiskUpdateServerName + "\" + (($store.Path).Replace(":",'$')) + "\"
            $disks = Get-PvsDiskLocator -SiteName $pvssite.Name -StoreName $store.Name
                foreach($diskinfo in $disks)
                {
                    write-host "Checking Disk versions for: $($diskinfo.name)"
                        $xmlpath = $testpath + $diskinfo.name + ".xml"
                        if(test-path -Path $xmlpath)
                        {
                        write-host "XML FILE FOUND. Now Checking versions." -ForegroundColor yellow
                        $diskxml = New-Object System.Xml.XmlDocument
                        $diskxml.Load($xmlpath)
                        $xmlversion = ($diskxml.versionManifest.version|Sort-Object versionnumber -Descending|select -First 1).versionnumber
                        $overridexml = ($diskxml.versionManifest.version|where{$_.access -eq 3}).versionnumber
                            if($diskinfo.DiskLocatorId)
                            {
                            $diskversion = ($diskinfo|Get-PvsDiskVersion|where{$_.CanPromote -eq $false}|Sort-Object version -Descending|select -First 1).version
                            $overridedisk = ($diskinfo|Get-PvsDiskVersion|where{$_.Access -eq 3}).version
                            write-host "Disk Version: $($diskversion) XMLVersion: $($xmlversion)"
                            Write-host "Selected Version: $($overridedisk) XMLOverride: $($overridexml)"
                                if($diskversion -ne $xmlversion -or $overridedisk -ne $overridexml -or ([string]::IsNullOrWhiteSpace($diskxml.versionManifest.startingVersion)))
                                {
                                write-host "Exporting vdisk" -ForegroundColor gray
                                $diskinfo|Export-PvsDisk -Version $diskversion
                                }
                                else
                                {
                                write-host "Versions match." -ForegroundColor Green
                                }
                            }
                        }
                        else
                        {
                        write-host "XML File not found.  Exporting vDisk." -ForegroundColor gray
                        $diskversion = ($diskinfo|Get-PvsDiskVersion|where{$_.CanPromote -eq $false}|Sort-Object version -Descending|select -First 1).version
                        $diskinfo|Export-PvsDisk -Version $diskversion
                        }
                }
        }
        else
        {
        $diskinfo = Get-PvsDiskLocator -SiteName $pvssite.Name|where{$_.name -eq $specdisk}
            if ($diskinfo -is [object])
            {
            $diskversion = ($diskinfo|Get-PvsDiskVersion|where{$_.CanPromote -eq $false}|Sort-Object version -Descending|select -First 1).version
            $diskinfo|Export-PvsDisk -Version $diskversion
            }
        }
}
}
#Checks through imported disks and checks for new versions or overrides
function import-versions ($site,$specdisk) {
    if($site -ne $null)
    {
    $pvssites = Get-PvsSite -SiteName $site
    }
    else
    {
    $pvssites = get-pvssite
    }
    foreach($pvssite in $pvssites)
    {
        write-host "Checking Site: $($pvssite.Name)" -ForegroundColor Yellow
        $stores = Get-PvsStore|where{$_.SiteName -eq $pvssite.Name}
        foreach ($store in $stores)
        {
        write-host "Checking Store: $($store.Name)" -ForegroundColor Yellow
        $testpath = "\\" + $pvssite.DiskUpdateServerName + "\" + (($store.Path).Replace(":",'$')) + "\"
            if([string]::IsNullOrWhiteSpace($specdisk))
            {
            $disks = Get-PvsDiskLocator -SiteName $pvssite.Name -StoreName $store.Name
            }
            else
            {
            $disks = Get-PvsDiskLocator -SiteName $pvssite.Name|where{$_.name -eq $specdisk}
            }
                foreach($diskinfo in $disks)
                {
                    write-host "Checking Disk versions for: $($diskinfo.name)"
                        $xmlpath = $testpath + $diskinfo.name + ".xml"
                        if(test-path -Path $xmlpath)
                        {
                        write-host "XML FILE FOUND" -ForegroundColor Green
                        $diskxml = New-Object System.Xml.XmlDocument
                        $diskxml.Load($xmlpath)
                        $xmlversion = ($diskxml.versionManifest.version|Sort-Object versionnumber -Descending|select -First 1).versionnumber
                        $overridexml = ($diskxml.versionManifest.version|where{$_.access -eq 3}).versionnumber
                            if($diskinfo.DiskLocatorId)
                            {
                            $diskversion = ($diskinfo|Get-PvsDiskVersion|where{$_.CanPromote -eq $false}|Sort-Object version -Descending|select -First 1).version
                            $overridedisk = ($diskinfo|Get-PvsDiskVersion|where{$_.Access -eq 3}).version
                            write-host "Disk Version: $($diskversion) XMLVersion: $($xmlversion)"
                            Write-host "Disk Selected Version: $($overridedisk) XMLOverride: $($overridexml)"
                                if($diskversion -lt $xmlversion -AND -not ([string]::IsNullOrWhiteSpace($diskxml.versionManifest.startingVersion)))
                                {
                                write-host "Importing new version(s)" -ForegroundColor DarkGray|Sort-Object version -Descending
                                $diskinfo|Add-PvsDiskVersion
                                }
                                else
                                {
                                write-host "Versions match OR Disk version is greater. Skipping..." -ForegroundColor Green
                                }

                                write-host "Checking for versions to delete"
                                $staleversions = $diskinfo|Get-PvsDiskVersion|where{$_.DeleteWhenFree -eq $true}|Sort-Object -Descending
                                    foreach($staleversion in $staleversions)
                                    {
                                    $stalepath = $testpath + $staleversion.DiskFileName


                                        if(test-path $stalepath)
                                        {
                                        write-host "Disk file still exists. Skipping: $($staleversion.Version)..."
                                        }
                                        else
                                        {
                                        write-host "Removing stale version: $($staleversion.version)" -ForegroundColor Gray
                                        $staleversion|remove-pvsdiskversion -DiskLocatorId $diskinfo.DiskLocatorId -Version $staleversion.version
                                        }
                                    }

                                if($overridedisk -ne $overridexml -and -not ([string]::IsNullOrWhiteSpace($overridexml)))
                                {
                                write-host "Setting override version to: $($overridexml)" -ForegroundColor Gray
                                $diskinfo|Set-PvsOverrideVersion -Version $overridexml
                                }
                                elseif($overridedisk -ne $overridexml -and ([string]::IsNullOrWhiteSpace($overridexml)))
                                {
                                write-host "Setting to use latest version" -ForegroundColor Gray
                                $diskinfo|Set-PvsOverrideVersion
                                }

                             }
                        }
                }
        }
    }
}

function test-pvsdisk ($site,$store,$name) {
    try {
    $disk = Get-PvsDiskLocator -SiteName $site -StoreName $store -DiskLocatorName $name
    }
    catch
    {
        return $false
        break
    }
return $disk
}

function test-pvsvhdx ($xmlfile) {

$xmldisk = New-Object System.Xml.XmlDocument
$xmldisk.Load($xmlfile.FullName)
$found = $xmldisk.versionManifest.version|where{$_.diskfilename -like "*.vhdx"}
    if($found)
    {
    return $true
    }
    else
    {
    return $false
    }
}

function test-private ($xmlfile) {

$xmldisk = New-Object System.Xml.XmlDocument
$xmldisk.Load($xmlfile.FullName)
$found = ([string]::IsNullOrWhiteSpace($xmldisk.versionManifest.startingVersion))
    if($found)
    {
    return $true
    }
    else
    {
    return $false
    }
}

function import-vdisks ($site,$specdisk,$justadmin,$pvserver) {
    if($site -ne $null)
    {
    $pvssites = Get-PvsSite -SiteName $site
    }
    else
    {
    $pvssites = get-pvssite
    }

    foreach($pvssite in $pvssites)
    {

        write-host "Checking Site: $($pvssite.Name)" -ForegroundColor Yellow
        $stores = Get-PvsStore|where{$_.SiteName -eq $pvssite.Name}
        foreach ($store in $stores)
        {
        write-host "Checking Store: $($store.Name)" -ForegroundColor Yellow
        if($justadmin)
        {
        $testpath = "\\" + $pvserver + "\" + (($store.Path).Replace(":",'$')) + "\"
        }
        else
        {
        $testpath = "\\" + $pvssite.DiskUpdateServerName + "\" + (($store.Path).Replace(":",'$')) + "\"
        }
            if (test-path $testpath)
            {
            
                if([string]::IsNullOrWhiteSpace($specdisk))
                {
                write-host $testpath
                $xmls = Get-childitem -Path $testpath -Filter *.xml
                }
                else
                {
                $xmls = Get-childitem -Path $testpath -Filter "$($specdisk).xml"
                }
                
                foreach($xml in $xmls)
                {
                    $xml
                    $disk = test-pvsdisk -site $pvssite.Name -store $store.Name -DiskLocatorName -name $xml.baseName
                        if($disk -ne $false -or (test-private $xml) -eq $true)
                        {
                        write-host "$($xml.baseName) already present or in private mode" -ForegroundColor Green
                        }
                        else
                        {
                        write-host "Importing $($xml.baseName)" -ForegroundColor Gray
                            if(test-pvsvhdx $xml)
                            {
                            write-host "VHDX found"
                            Import-PvsDisk -Name $xml.BaseName -SiteName $pvssite.Name -StoreName $store.Name -VHDX|Out-Null
                            }
                            else
                            {
                            write-host "VHD Found"
                            Import-PvsDisk -Name $xml.BaseName -SiteName $pvssite.Name -StoreName $store.Name|Out-Null
                            }

                        }
                }

            }
        
    }

    }
}
#call script functions here

export-alldisks $disk
foreach ($adminserver in $adminservers)
{
    write-host "Connecting to $($adminserver)" -ForegroundColor Yellow
    if(Test-Connection $adminserver -Quiet -Count 2)
    {
    Set-PvsConnection -Server $adminserver -PassThru|out-null
        if(!$nocopy)
        {
            foreach($storepath in $storepaths)
            {
            write-host "Copying out $($storepath)" -ForegroundColor Yellow
            copy-vhds $storepath $disk $justadmin $adminserver
            }
        }
        
        if(-not ($adminserver -like $env:computername))
        {

        import-vdisks $site $disk $justadmin $adminserver
        import-versions $site $disk
        }
    }
    else
    {
    throw "Can't connect to server $($adminserver)"
    }
}
