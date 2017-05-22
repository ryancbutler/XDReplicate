<#
.SYNOPSIS
   Keep PVS vDisks and versioning consistent across multiple PVS sites and additional PVS farms
.DESCRIPTION
   Checks for vDisks and versioning and will export XML if required.  Script will then robocopy all vDisk files out to all PVS servers.  Once copied script will import and set versioning to match local server.
   Version: 1.5.1
   By: Ryan Butler 02-28-17
   Updated: 5-9-17
   5-22-17 Error checking
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
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore"
   Copies and imports disks and versions to all PVS farm servers accessible via localhost and uses the vDisk store at "E:\teststore" for robocopy.
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
    [switch]$nocopy

)

#Argument checking
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

#Import PVS module
try{
import-module "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll"
}
Catch
{
    throw "Error Importing PVS module"
    break
}

Clear-Host
#Builds server array
$adminservers = @($env:computername)
if($PVSServers.Count -gt 0)
{
    $adminservers += $PVSServers
}

#Uses robocopy to mirror local disk store
function copy-vhds ($localstorepath) {
    if($site -ne $null)
    {
    $pvsservers = Get-PvsServer -sitename $site|where-object{$_.name -ne $env:computername}
    }
    else
    {
    $pvsservers = Get-PvsServer|where-object{$_.name -ne $env:computername}
    }

if($pvsservers.count)
{
    foreach ($pvsserver in $pvsservers)
    {
        write-host $pvsserver.Name
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
}
else
{
write-host "No PVS servers bound to site" -ForegroundColor Red
}
}

#Checks through disks and exports XML if a new version exists or override present
function export-alldisks {
    Set-PvsConnection -Server $env:computername -PassThru|out-null
    $pvsserversite = Get-PvsServer -ServerName $env:computername
    $pvssite = get-pvssite -SiteName $pvsserversite.SiteName
        write-host "Checking Site: $($pvssite.Name)" -ForegroundColor Yellow
        $stores = Get-PvsStore|where-object{$_.SiteName -eq $pvssite.Name}
        foreach ($store in $stores)
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
                        $xmlversion = ($diskxml.versionManifest.version|Sort-Object versionnumber -Descending|select-object -First 1).versionnumber
                        $overridexml = ($diskxml.versionManifest.version|where-object{$_.access -eq 3}).versionnumber
                            if($diskinfo.DiskLocatorId)
                            {
                            $diskversion = ($diskinfo|Get-PvsDiskVersion|where-object{$_.CanPromote -eq $false}|Sort-Object version -Descending|select-object -First 1).version
                            $overridedisk = ($diskinfo|Get-PvsDiskVersion|where-object{$_.Access -eq 3}).version
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
                        $diskinfo|Export-PvsDisk
                        }
                }
        }
}

#Checks through imported disks and checks for new versions or overrides
function import-versions {
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
        $stores = Get-PvsStore|where-object{$_.SiteName -eq $pvssite.Name}
        foreach ($store in $stores)
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
                        write-host "XML FILE FOUND" -ForegroundColor Green
                        $diskxml = New-Object System.Xml.XmlDocument
                        $diskxml.Load($xmlpath)
                        $xmlversion = ($diskxml.versionManifest.version|Sort-Object versionnumber -Descending|select-object -First 1).versionnumber
                        $overridexml = ($diskxml.versionManifest.version|where-object{$_.access -eq 3}).versionnumber
                            if($diskinfo.DiskLocatorId)
                            {
                            $diskversion = ($diskinfo|Get-PvsDiskVersion|where-object{$_.CanPromote -eq $false}|Sort-Object version -Descending|select-object -First 1).version
                            $overridedisk = ($diskinfo|Get-PvsDiskVersion|where-object{$_.Access -eq 3}).version
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
                                $staleversions = $diskinfo|Get-PvsDiskVersion|where-object{$_.DeleteWhenFree -eq $true}|Sort-Object -Descending
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

#Checks to see if the vdisk is found
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

#Checks to see if the vdisk is found
function test-pvsvhdx ($xmlfile) {
$xmldisk = New-Object System.Xml.XmlDocument
$xmldisk.Load($xmlfile.FullName)
$found = $xmldisk.versionManifest.version|where-object{$_.diskfilename -like "*.vhdx"}
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

function import-vdisks {
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
        $stores = Get-PvsStore|where-object{$_.SiteName -eq $pvssite.Name}
        foreach ($store in $stores)
        {
        write-host "Checking Store: $($store.Name)" -ForegroundColor Yellow
        $testpath = "\\" + $pvssite.DiskUpdateServerName + "\" + (($store.Path).Replace(":",'$')) + "\"
            if (test-path $testpath)
            {
            $xmls = Get-childitem -Path $testpath -Filter *.xml
                foreach($xml in $xmls)
                {

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

export-alldisks

foreach ($adminserver in $adminservers)
{
    write-host "Connecting to $($adminserver)" -ForegroundColor Yellow
    if(Test-Connection $adminserver -Quiet -Count 2)
    {
    
    #Connect to PVS server
    try 
    {
        Set-PvsConnection -Server $adminserver -PassThru|out-null
        }
        Catch
        {
        Write-Error $_
        break
    } 

        if(!$nocopy)
        {
            foreach($storepath in $storepaths)
            {
            write-host "Copying out $($storepath)" -ForegroundColor Yellow
            copy-vhds $storepath
            }
        }
    import-vdisks
    import-versions
    }
    else
    {
    throw "Can't connect to server $($adminserver)"
    }
}