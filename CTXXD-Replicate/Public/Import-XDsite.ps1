function Import-XDsite
{
<#
.SYNOPSIS
    Imports XD site information from object
.DESCRIPTION
    Imports XD site information from object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER XMLPATH
   Path used for XML file location on import and export operations
.PARAMETER XDEXPORT
    XD site object to import
.EXAMPLE
   $exportedobject|Import-XDSite -xdhost DDC02.DOMAIN.COM
   Imports data to DDC02.DOMAIN.COM and returns as object
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xmlpath "C:\temp\mypath.xml"
   Imports data to DDC02.DOMAIN.COM from XML file C:\temp\mypath.xml
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xdexport $myexport
   Imports data to DDC02.DOMAIN.COM from variable $myexport
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='High')]
Param (
    [Parameter(Mandatory=$false)][string]$xdhost="localhost",
    [Parameter(Mandatory=$false)][String]$xmlpath,
    [Parameter(ValueFromPipeline=$true)]$xdexport)
    
begin{
    #Checks for Snappins
    Test-XDmodule
    if(-not ([string]::IsNullOrWhiteSpace($xmlpath)))
    {
        if(Test-Path $xmlpath)
        {
            $xdexport = Import-Clixml $xmlpath
        }
        else {
            throw "XML file not found"
        }
    }
}

process 
    {

    if (!($XDEXPORT))
    {
    throw "Nothing to import"
    }
    
        if ($PSCmdlet.ShouldProcess("Import Site")) 
        { 
        write-verbose "Proccessing Tags"
        
        #Description argument not added until 7.11
        $ddcver = (Get-BrokerController -AdminAddress $xdhost).ControllerVersion | Select-Object -first 1
        foreach($tag in $XDEXPORT.tags)
        {  

        $tagmatch = Get-BrokerTag -AdminAddress $xdhost -name $tag.name -ErrorAction SilentlyContinue
            if($tagmatch -is [object])
            {
            write-verbose "Found TAG $($tag.name)"
            }
            else
            {
            write-verbose "Creating TAG $($tag.name)"
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
        write-verbose "Proccessing $($dg.name)"

        $dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.NAME -ErrorAction SilentlyContinue

            if ($dgmatch -is [object])
            {
            write-verbose "Setting $($dgmatch.name)"
            Set-XDExistingDeliveryGroupObject $dg $xdhost
            Get-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid -adminaddress $xdhost|remove-BrokerAccessPolicyRule -AdminAddress $xdhost -ErrorAction SilentlyContinue|Out-Null
            $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid -adminaddress $xdhost|Out-Null
                
                if($dg.powertime -is [object])
                {
                    ($dg.PowerTime)|ForEach-Object{
                    write-verbose "Setting Power Time Scheme $($_.name)"
                    Set-BrokerPowerTimeScheme -AdminAddress $xdhost -Name $_.name -DisplayName $_.displayname -DaysOfWeek $_.daysofweek -PeakHours $_.peakhours -PoolSize $_.poolsize -PoolUsingPercentage $_.poolusingpercentage -ErrorAction SilentlyContinue|Out-Null
                    }
                }
            }
            else
            {
            write-verbose "Creating Delivery Group"
                try
                {
                write-verbose $dg.Name
                $dgmatch = New-XDDeliveryGroupObject $dg $xdhost
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
            write-verbose "Setting pre-launch"
            Remove-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupName $dg.Name -ErrorAction SilentlyContinue
            $dg.PreLaunch|New-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null
            }

            }
            

            if(-not([string]::IsNullOrWhiteSpace($dg.tags)))
            {
                foreach ($tag in $dg.tags)
                {
                write-verbose "Adding TAG $tag"
                add-brokertag -Name $tag -AdminAddress $xdhost -DesktopGroup $dgmatch.name
                }
            }
        
            $desktops = $XDEXPORT.desktops|where-object{$_.DGNAME -eq $dg.name}
            Set-XDAppEntitlement $dgmatch $xdhost

                    if($desktops)
                    {
                        foreach ($desktop in $desktops)
                        {
                        write-verbose "Proccessing Desktop $($desktop.name)"
                        $desktopmatch = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid -Name $desktop.Name -ErrorAction SilentlyContinue
                            if($desktopmatch)
                            {
                            write-verbose "Setting desktop"
                            Set-XDDesktopobject $desktop $xdhost
                            clear-XDDesktopUserPerm $desktopmatch $xdhost
                            set-XDUserPerm $desktop $xdhost
                            }
                            else
                            {
                            write-verbose "Creating Desktop"
                            $desktopmatch = New-XDDesktopobject $desktop $xdhost $dgmatch.Uid
                            set-XDUserPerm $desktop $xdhost
                            }

                        }
                    }

            $apps = $XDEXPORT.apps|where-object{$_.DGNAME -eq $dgmatch.name -and $_.multi -eq $false}
            $apps|import-xdapp -xdhost $xdhost -dgmatch $dgmatch -Verbose:$VerbosePreference 
            
                
    
        }
        

        Write-Verbose "Processing App Groups"
        foreach ($ag in $XDEXPORT.appgroups)
        {
            $agmatch = Get-BrokerApplicationGroup -AdminAddress $xdhost -Name $ag.name -ErrorAction SilentlyContinue
            if ($agmatch -is [object])
            {
            write-verbose "Found $($ag.Name)"
            Set-XDAppGroup -xdhost $xdhost -appgroupmatch $agmatch -appgroup $ag
            Clear-XDAppGroupUserPerm -appgroup $agmatch -xdhost $xdhost
            Set-XDNewAppGroupUserPerm -xdhost $xdhost -appgroupmatch $agmatch -appgroup $ag 
            }
            else
            {
            write-verbose "Adding $($ag.name)"
            $agmatch = New-XDAppGroup -xdhost $xdhost -appgroup $ag
            Set-XDNewAppGroupUserPerm -xdhost $xdhost -appgroupmatch $agmatch -appgroup $ag 
            }
        }

        write-verbose "Processing Apps with multiple Delivery groups and Application groups"
        $multi = $XDEXPORT.apps|where-object{$_.multi -eq $true}
        if($multi)
        {
            foreach ($mapp in $multi) 
            {
                if(($mapp.dgname).count -gt 0)
                {
                $dgmatch = $mapp.dgname|Select-Object -First 1
                }
                else 
                {
                $dgmatch = $mapp.dgname|Select-Object -First 1
                }
            Write-Verbose "HERHEHRR"
                import-xdapp -xdhost $xdhost -app $mapp -dgmatch $dgmatch|Set-XDMultiApp -xdhost $xdhost
            }

        }

        
        write-verbose "Processing Admin Roles"
        foreach ($role in $XDEXPORT.adminroles)
        {
            $rolematch = Get-AdminRole -AdminAddress $xdhost -Name $role.name -ErrorAction SilentlyContinue
            if ($rolematch -is [object])
            {
            write-verbose "Found $($role.Name)"
            }
            else
            {
            write-verbose "Adding $($role.name)"
            New-AdminRole -AdminAddress $xdhost -Description $role.Description -Name $role.Name|out-null
            Add-AdminPermission -AdminAddress $xdhost -Permission $role.Permissions -Role $role.name|out-null
            }
        }


        write-verbose "Processing admins"
        foreach ($admin in $XDEXPORT.admins)
        {

            $adminmatch = Get-AdminAdministrator -Sid $admin.Sid -AdminAddress $xdhost -ErrorAction SilentlyContinue
            if ($adminmatch -is [object])
            {
            write-verbose "Found $($admin.Name)"
            }
            else
            {
            write-verbose "Adding $($admin.Name)"
            $rights = ($admin.Rights) -split ":"
            New-AdminAdministrator -AdminAddress $xdhost -Enabled $admin.Enabled -Sid $admin.Sid|out-null
            Add-AdminRight -AdminAddress $xdhost -Administrator $admin.name -Role $rights[0] -Scope $rights[1]
            }

        }


    }
}
}

