function Export-XDsite
{
<#
.SYNOPSIS
    Exports XD site information to variable
.DESCRIPTION
    Exports XD site information to variable
.PARAMETER XDHOST
   XenDesktop DDC hostname to connect to
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
   Export-XDSite -xdhost DDC02.DOMAIN.COM
   Exports data from DDC02.DOMAIN.COM and returns as object
.EXAMPLE
   Export-XDSite -xdhost DDC02.DOMAIN.COM -dgtag "replicate"
   Exports data from DDC02.DOMAIN.COM with delivery groups tagged with "replicate" and returns as object.
.EXAMPLE
   Export-XDSite -xdhost DDC02.DOMAIN.COM -ignoredgtag "skip"
   Exports data from DDC02.DOMAIN.COM while skipping delivery groups tagged with "skip" and returns as object.
.EXAMPLE
   Export-XDSite -xdhost DDC02.DOMAIN.COM -apptag "replicate"
   Exports data from DDC02.DOMAIN.COM delivery groups while only including apps tagged with "replicate" and returns as object.
.EXAMPLE
   Export-XDSite -xdhost DDC02.DOMAIN.COM -ignoreapptag "skip"
   Exports data from DDC02.DOMAIN.COM delivery groups while ignoring apps tagged with "skip" and returns as object.
.EXAMPLE
   .\XDReplicate.ps1 -xdhost DDC02.DOMAIN.COM -XMLPATH "C:\temp\my.xml"
   Exports data from DDC02.DOMAIN.COM and exports to C:\temp\my.xml
#>
[CmdletBinding()]
Param (
[Parameter(Mandatory=$false)][string]$xdhost="localhost",
[Parameter(Mandatory=$false)][String]$xmlpath,
[Parameter(Mandatory=$false)][string]$dgtag,
[Parameter(Mandatory=$false)][string]$ignoredgtag,
[Parameter(Mandatory=$false)][string]$apptag,
[Parameter(Mandatory=$false)][string]$ignoreapptag
)

begin{
    #Checks for Snappins
    Test-XDmodule

}

process {
        #Need path for XML while in EXPORT
        $ddcver = (Get-BrokerController -AdminAddress $xdhost).ControllerVersion | Select-Object -first 1

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
        $appgroupobject = @()

        #Each delivery group
        foreach ($DG in $DesktopGroups)
        {
            Write-Verbose $DG.Name
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
                    Write-Verbose "Processing $($app.ApplicationName)"

                    #Icon data
                    $BrokerEnCodedIconData = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($app.IconUid)).EncodedIconData
                    $app|add-member -NotePropertyName 'EncodedIconData' -NotePropertyValue $BrokerEnCodedIconData
                    #Adds delivery group name to object
                    if(($app.AssociatedDesktopGroupUids).count -gt 1)
                    {
                        $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue ($app|export-xdappdg -xdhost $xdhost)
                    }
                    else
                    {
                        $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
                    }

                    if(($app.AssociatedApplicationGroupUids).count -gt 0)
                    {
                        $app|add-member -NotePropertyName 'AGNAME' -NotePropertyValue ($app|export-xdappag -xdhost $xdhost)
                    }
        
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
                Write-Verbose "Processing $($desktop.Name)"
                #Adds delivery group name to object
                $desktop|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
                $desktopobject += $desktop
                }
        
            }
        #Grabs App Groups

        if(-not ([string]::IsNullOrWhiteSpace($dgtag)))
        {
           #Guessing 7.11 is the first to support app groups
            if ([version]$ddcver -lt "7.11")
            {
                write-warning "Skipping App Groups due to DDC version." 
            }
            else {
                $appgroups = Get-BrokerApplicationGroup -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -Tag $dgtag -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoredgtag}
                $appgroupobject += $appgroups
            }
        
        }
        else
        {
            if ([version]$ddcver -lt "7.11")
            {
                write-warning "Skipping App Groups due to DDC version." 
            
            }
            else {
                $appgroups = Get-BrokerApplicationGroup -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoredgtag}
                $appgroupobject += $appgroups
            }
        }


    }

        #buid output object
        $xdout = New-Object PSCustomObject
        Write-Verbose "Processing Administrators"
        $xdout|Add-Member -NotePropertyName "admins" -NotePropertyValue (Get-AdminAdministrator -AdminAddress $xdhost)
        Write-Verbose "Processing Scopes"
        $xdout|Add-Member -NotePropertyName "adminscopes" -NotePropertyValue (Get-AdminScope -AdminAddress $xdhost|where-object{$_.BuiltIn -eq $false})
        Write-Verbose "Processing Roles"
        $xdout|Add-Member -NotePropertyName "adminroles" -NotePropertyValue (Get-AdminRole -AdminAddress $xdhost|where-object{$_.BuiltIn -eq $false})
        $xdout|Add-Member -NotePropertyName "dgs" -NotePropertyValue $DesktopGroups
        $xdout|Add-Member -NotePropertyName "apps" -NotePropertyValue ($appobject|sort-object browsername -Unique)
        $xdout|Add-Member -NotePropertyName "appgroups" -NotePropertyValue ($appgroupobject|export-xdappgroup -xdhost $xdhost)
        $xdout|Add-Member -NotePropertyName "desktops" -NotePropertyValue $desktopobject
        Write-Verbose "Processing Tags"
        $xdout|Add-Member -NotePropertyName "tags" -NotePropertyValue (Get-BrokerTag -AdminAddress $xdhost -MaxRecordCount 2000)

        #Export to either variable or XML
        if($xmlpath)
        {
        Write-Verbose "Writing to $($XMLPath)"
        $xdout|Export-Clixml -Path ($XMLPath)
        }
        else
        {
        return $xdout
        }

    }
}
