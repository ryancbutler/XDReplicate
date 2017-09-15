function Import-XDsite
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
[CmdletBinding()]
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
        Set-XDExistingDeliveryGroupObject $dg $xdhost
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
        Set-XDAppEntitlement $dgmatch $xdhost

                if($desktops)
                {
                foreach ($desktop in $desktops)
                {
                write-host "Proccessing Desktop $($desktop.name)" -ForegroundColor Magenta
                $desktopmatch = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid -Name $desktop.Name -ErrorAction SilentlyContinue
                    if($desktopmatch)
                    {
                    write-host "Setting desktop" -ForegroundColor Gray
                    Set-XDDesktopobject $desktop $xdhost
                    clear-XDDesktopUserPerm $desktopmatch $xdhost
                    set-XDUserPerm $desktop $xdhost
                   # Set-XDAppEntitlement $dgmatch $desktopmatch $xdhost
                    }
                    else
                    {
                    Write-host "Creating Desktop" -ForegroundColor Green
                    $desktopmatch = New-XDDesktopobject $desktop $xdhost $dgmatch.Uid
                    set-XDUserPerm $desktop $xdhost
                    #Set-XDAppEntitlement $dgmatch $desktopmatch $xdhost
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
                            if (-Not (Test-XDBrokerAdminFolder -folder $folder -xdhost $xdhost))
                            {
                            write-host "Creating folder" -ForegroundColor Green
                            new-xdadminfolder $folder $xdhost
                            }
                        Write-host Moving App to correct folder -ForegroundColor Yellow
                        Move-BrokerApplication -AdminAddress $xdhost $appmatch -Destination $app.AdminFolderName
                        $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername -ErrorAction SilentlyContinue
                        }
                    }
                    set-xdexistingappobject $app $appmatch $xdhost|Invoke-Expression

                    #makes sure to rename app to match
                    if($appmatch.ApplicationName -notlike $app.ApplicationName)
                    {
                        write-host "Renaming Application..." -ForegroundColor Yellow
                        rename-brokerapplication -AdminAddress $xdhost -inputobject $appmatch -newname $app.ApplicationName
                        $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername
                    }

                        if((test-xdicon $app $appmatch $xdhost) -eq $false)
                        {
                        $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                        $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                        }
                    clear-XDAppUserPerm $appmatch $xdhost
                    set-XDNewAppUserPerm $app $appmatch $xdhost
                    }
                    else
                    {
                    write-host "Creating App" -ForegroundColor Green
                    $folder = $app.AdminFolderName
                    if(-not [string]::IsNullOrWhiteSpace($folder))
                    {
                        if (-Not (Test-XDBrokerAdminFolder -folder $folder -xdhost $xdhost))
                        {
                        write-host "Creating folder" -ForegroundColor Green
                        new-xdadminfolder $folder $xdhost
                        }
                    }
                    $appmatch = new-xdappobject $app $xdhost $dgmatch.Name
                    
                    if($appmatch -is [Object])
                    {

                        #sets browsername to match
                        set-brokerapplication -adminaddress $xdhost -inputobject $appmatch -browsername $app.browsername|out-null
                    
                        $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                        $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                        set-XDNewAppUserPerm $app $appmatch $xdhost
                        
                        if($app|Select-Object -ExpandProperty FTA -ErrorAction SilentlyContinue)
                        {
                            foreach ($fta in $app.FTA)
                            {
                            New-XDFTAobject -xdhost $xdhost -fta $fta -newapp $app
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
        $rights = ($admin.Rights) -split ":"
        New-AdminAdministrator -AdminAddress $xdhost -Enabled $admin.Enabled -Sid $admin.Sid|out-null
        #Add-AdminRight -AdminAddress $xdhost -Administrator $admin.Name -InputObject $admin.Rights|Out-Null
        Add-AdminRight -AdminAddress $xdhost -Administrator $admin.name -Role $rights[0] -Scope $rights[1]
        }

    }



}
