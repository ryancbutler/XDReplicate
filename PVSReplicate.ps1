<#
.SYNOPSIS
   Keep PVS vDisk versioning consistent across multiple PVS sites and additional PVS farms
.DESCRIPTION
   Checks for vDisk versioning and will export XML if required.  Script will then robocopy all vDisk files out to all PVS servers.  Once copied script will import and set versioning to match local server.
   Version: 1.0
   By: Ryan Butler 02-28-17
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
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore"
   Copies and imports disk versions to all PVS farm servers accessible via localhost and uses the vDisk store at "E:\teststore" for each server.
.EXAMPLE
   .\PVSReplicate.ps1 -StorePath "E:\teststore" -PVSServers "PVSFARM01","PVSFARM02"
   Copies and imports disk versions to all PVS farm servers accessible via localhost, PVSFARM01, PVSFARM02 and uses the vDisk store at "E:\teststore" for each server.
#>
Param
(
    [array]$PVSServers,
    [Parameter(mandatory=$true)][string]$storepath

)

import-module "C:\Program Files\Citrix\Provisioning Services Console\Citrix.PVS.SnapIn.dll"
CLS

#Builds server array
$adminservers = @($env:computername)
if($PVSServers.Count -gt 0)
{
    $adminservers += $PVSServers
}


$localstorepath = $storepath


#Uses robocopy to mirror local disk store
function copy-vhds {
    $pvsservers = Get-PvsServer|where{$_.name -ne $env:computername}

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

#Checks through disks and exports XML if a new version exists or override present
function export-alldisks {
    Set-PvsConnection -Server $env:computername -PassThru|out-null
    $pvsserversite = Get-PvsServer -ServerName $env:computername
    $pvssite = get-pvssite -SiteName $pvsserversite.SiteName
        write-host "Checking Site: $($pvssite.Name)" -ForegroundColor Yellow
        $stores = Get-PvsStore|where{$_.SiteName -eq $pvssite.Name}
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
                        $xmlversion = ($diskxml.versionManifest.version|Sort-Object versionnumber -Descending|select -First 1).versionnumber
                        $overridexml = ($diskxml.versionManifest.version|where{$_.access -eq 3}).versionnumber

                            if($diskinfo.DiskLocatorId)
                            {
                            $diskversion = ($diskinfo|Get-PvsDiskVersion|where{$_.CanPromote -eq $false}|Sort-Object version -Descending|select -First 1).version
                            $overridedisk = ($diskinfo|Get-PvsDiskVersion|where{$_.Access -eq 3}).version
                            write-host "Disk Version: $($diskversion) XMLVersion: $($xmlversion)"
                            Write-host "Selected Version: $($overridedisk) XMLOverride: $($overridexml)"
                                if($diskversion -ne $xmlversion -or $overridedisk -ne $overridexml )
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
    $pvssites = get-pvssite
    foreach($pvssite in $pvssites)
    {
        write-host "Checking Site: $($pvssite.Name)" -ForegroundColor Yellow
        $stores = Get-PvsStore|where{$_.SiteName -eq $pvssite.Name}
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
                        $xmlversion = ($diskxml.versionManifest.version|Sort-Object versionnumber -Descending|select -First 1).versionnumber
                        $overridexml = ($diskxml.versionManifest.version|where{$_.access -eq 3}).versionnumber

                            if($diskinfo.DiskLocatorId)
                            {

                            $diskversion = ($diskinfo|Get-PvsDiskVersion|where{$_.CanPromote -eq $false}|Sort-Object version -Descending|select -First 1).version
                            $overridedisk = ($diskinfo|Get-PvsDiskVersion|where{$_.Access -eq 3}).version
                            write-host "Disk Version: $($diskversion) XMLVersion: $($xmlversion)"
                            Write-host "Disk Selected Version: $($overridedisk) XMLOverride: $($overridexml)"
                                if($diskversion -lt $xmlversion)
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

#call script functions here

export-alldisks

foreach ($adminserver in $adminservers)
{
    write-host "Connecting to $($adminserver)" -ForegroundColor Yellow
    if(Test-Connection $adminserver -Quiet -Count 2)
    {
    Set-PvsConnection -Server $adminserver -PassThru|out-null
    copy-vhds
    import-versions
    }
    else
    {
    throw "Can't connect to server $($adminserver)"
    }
}
