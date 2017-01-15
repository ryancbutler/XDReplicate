Add-PSSnapin citrix*
CLS
$XDEXPORT = Import-Clixml "C:\Temp\XDEXPORT.xml"
$xdhost = "localhost"


function check-BrokerAdminFolder ($folder)
{
    write-host "Processing $folder"
    $foldermatch = Get-BrokerAdminFolder -AdminAddress $xdhost -name $folder -ErrorAction SilentlyContinue
    if ($foldermatch -is [Object])
    {
    write-host "FOLDER FOUND" -ForegroundColor GREEN
    $found = $true
    }
    else
    {
    write-host "FOLDER NOT FOUND" -ForegroundColor YELLOW
    $found = $false
    }
return $found
}

function create-adminfolders ($folder)
{
$paths = $folder -split "\\"|where{$_ -ne ""}

            $lastfolder = $null
            for($d=0; $d -le ($paths.Count -1); $d++)
            {          
            if($d -eq 0)
                {                  
                    if((check-BrokerAdminFolder ($paths[$d] + "\")) -eq $false)
                    {
                     New-BrokerAdminFolder -AdminAddress $xdhost -FolderName $paths[$d]|Out-Null
                    }
                $lastfolder = $paths[$d]
                }
                else
                {                    
                    if((check-BrokerAdminFolder ($lastfolder + "\" + $paths[$d])) -eq $false)
                    {
                    New-BrokerAdminFolder -FolderName $paths[$d] -ParentFolder $lastfolder|Out-Null
                    }
                $lastfolder = $lastfolder + "\" + $paths[$d]
                }            
            }
}

function clean-newappobject ($app)
{
$tempvar = New-Object PSCustomObject
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
            switch ($t.name)
            {
                "AdminFolderName" {$tempvar|Add-Member -MemberType NoteProperty -Name "AdminFolder" -Value $t.Value}
                "ApplicationGroup" {$tempvar|Add-Member -MemberType NoteProperty -Name "ApplicationGroup" -Value $t.Value}
                "ApplicationType" {$tempvar|Add-Member -MemberType NoteProperty -Name "ApplicationType" -Value $t.Value}
                "AssociatedUserNames" {$tempvar|Add-Member -MemberType NoteProperty -Name "AssociatedUserNames" -Value $t.Value}
                "BrowserName" {$tempvar|Add-Member -MemberType NoteProperty -Name "BrowserName" -Value $t.Value}
                "ClientFolder" {$tempvar|Add-Member -MemberType NoteProperty -Name "ClientFolder" -Value $t.Value}
                "CommandLineArguments" {$tempvar|Add-Member -MemberType NoteProperty -Name "CommandLineArguments" -Value $t.Value}
                "CommandLineExecutable" {$tempvar|Add-Member -MemberType NoteProperty -Name "CommandLineExecutable" -Value $t.Value}
                "CpuPriorityLevel" {$tempvar|Add-Member -MemberType NoteProperty -Name "CpuPriorityLevel" -Value $t.Value}
                "Description" {$tempvar|Add-Member -MemberType NoteProperty -Name "Description" -Value $t.Value}
                "Enabled" {$tempvar|Add-Member -MemberType NoteProperty -Name "Enabled" -Value $t.Value}
                "MaxPerUserInstances" {$tempvar|Add-Member -MemberType NoteProperty -Name "MaxPerUserInstances" -Value $t.Value}
                "MaxTotalInstances" {$tempvar|Add-Member -MemberType NoteProperty -Name "MaxTotalInstances" -Value $t.Value}
                "Name" {$tempvar|Add-Member -MemberType NoteProperty -Name $t.Name -Value $app.BrowserName}
                "Priority" {$tempvar|Add-Member -MemberType NoteProperty -Name "Priority" -Value $t.Value}
                "PublishedName" {$tempvar|Add-Member -MemberType NoteProperty -Name "PublishedName" -Value $t.Value}
                "SecureCmdLineArgumentsEnabled" {$tempvar|Add-Member -MemberType NoteProperty -Name "SecureCmdLineArgumentsEnabled" -Value $t.Value}
                "ShortcutAddedToDesktop" {$tempvar|Add-Member -MemberType NoteProperty -Name "ShortcutAddedToDesktop" -Value $t.Value}
                "ShortcutAddedToStartMenu" {$tempvar|Add-Member -MemberType NoteProperty -Name "ShortcutAddedToStartMenu" -Value $t.Value}
                "StartMenuFolder" {$tempvar|Add-Member -MemberType NoteProperty -Name "StartMenuFolder" -Value $t.Value}
                "UserFilterEnabled" {$tempvar|Add-Member -MemberType NoteProperty -Name "UserFilterEnabled" -Value $t.Value}
                "Visible" {$tempvar|Add-Member -MemberType NoteProperty -Name "Visible" -Value $t.Value}
                "WaitForPrinterCreation" {$tempvar|Add-Member -MemberType NoteProperty -Name "WaitForPrinterCreation" -Value $t.Value}
                "WorkingDirectory" {$tempvar|Add-Member -MemberType NoteProperty -Name "WorkingDirectory" -Value $t.Value}
            }
         }
    }

return $tempvar
}

function clean-existingappobject ($app, $appmatch)
{
$tempvarapp = "Set-BrokerApplication"
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
                "ClientFolder" {$tempstring = " -ClientFolder `"$($t.value)`""}
                "CommandLineArguments" {$tempstring = " -CommandLineArguments $($t.value)"}
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

function clean-Desktopobject ($desktop)
{
$tempvardesktop = "Set-BrokerEntitlementPolicyRule"
foreach($t in $desktop.PSObject.Properties)
    {
           
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
                "Name" {$tempstring = " -name `"$($t.value)`""}
                "ColorDepth" {$tempstring = " -Description `"$($t.value)`""}
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

function clean-ExistingDeliveryGroupObject ($dg)
{
write-host HERE OM FIM
$tempvardg = "Set-BrokerDesktopGroup"
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
            "OffPeakDisconnectTimeout" {$tempstring = " -OffPeakDisconnectTimeout `"$($t.value)`""}
            "OffPeakExtendedDisconnectAction" {$tempstring = " -OffPeakExtendedDisconnectAction `"$($t.value)`""}
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
            "ShutdownDesktopsAfterUse" {$tempstring = " -ProtocolPriority `$$($t.value)"}
            "TimeZone" {$tempstring = " -TimeZone `"$($t.value)`""}
            "TurnOnAddedMachine" {$tempstring = " -TurnOnAddedMachine `$$($t.value)"}
            }
            $tempvardg = $tempvardg +  $tempstring
            write-host $tempstring
             
         }
    }
return $tempvardg
}

function set-UserPerms ($app)
{
    if($app.ResourceType -eq "Desktop")
    {
        if ($app.IncludedUserFilterEnabled)
        {
        Set-BrokerEntitlementPolicyRule -AddIncludedUsers $app.includedusers -Name $app.Name
        }

        if ($app.ExcludedUserFilterEnabled)
        {
        Set-BrokerEntitlementPolicyRule -AddExcludedUserss $app.excludedusers -Name $app.Name
        }
    }
    else
    {
        if ($app.UserFilterEnabled)
        {
        write-host "Setting App Permissions" -ForegroundColor Green
             foreach($user in $app.AssociatedUserNames)
             {
                write-host $user
                Add-BrokerUser -AdminAddress $xdhost -Name $user -Application $app.Name
             }
        }
    }
}

function set-NewAppUserPerms ($app, $appmatch)
{

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

function clear-AppUserPerms ($app)
{
    if ($app.UserFilterEnabled)
        {
             foreach($user in $app.AssociatedUserFullNames)
             {
                Remove-BrokerUser -AdminAddress $xdhost -Name $user -Application $app.Name
             }
        }
}

function clear-DesktopUserPerms ($desktop)
{

        if ($desktop.IncludedUserFilterEnabled)
        {
            foreach($user in $desktop.IncludedUsers)
            {
            Set-BrokerEntitlementPolicyRule -RemoveIncludedUsers $user -Name $desktop.Name
            }
        }

        if ($desktop.ExcludedUserFilterEnabled)
        {
            foreach($user in $desktop.ExcludedUsers)
            {
            Set-BrokerEntitlementPolicyRule -RemoveExcludedUsers $user -Name $desktop.Name
            }
        }
 
}

function clean-FTAobject ($FTA)
{
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

function compare-icon ($app, $appmatch)
{
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

if ($XDEXPORT)
{

foreach($dg in $XDEXPORT.dgs)
{
write-host "Proccessing $($dg.name)"

$dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.NAME -ErrorAction SilentlyContinue

    if ($dgmatch -is [object])
    {
    write-host "Setting $($dgmatch.name)"
    clean-ExistingDeliveryGroupObject $dg|Invoke-Expression
    #$dg.AccessPolicyRule|Invoke-Expression
    }
    else
    {
    Write-host "Creating Delivery Group" -ForegroundColor Green
    $dgmatch = $dg|New-BrokerDesktopGroup|Out-Null
    $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid|Out-Null
    
    #throw "Missing DG Group"
    }
    ######{}
    
    $desktops = $XDEXPORT.desktops|where{$_.DGNAME -eq $dg.name}

        if($desktops)
        {
            foreach ($desktop in $desktops)
            {
            write-host "Proccessing Desktop $($desktop.name)"
            $desktopmatch = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid -Name $desktop.Name -ErrorAction SilentlyContinue
                if($desktopmatch)
                {
                write-host "Setting desktop" -ForegroundColor Gray
                clean-Desktopobject $desktop|invoke-expression
                clear-DesktopUserPerms $desktopmatch
                set-userperms $desktop
                }
                else
                {
                Write-host "Creating Desktop" -ForegroundColor Green
                $newdesktop = $desktop|New-BrokerEntitlementPolicyRule -DesktopGroupUid $dgmatch.Uid
                set-userperms $desktop
                }

            }
        }
    $apps = $XDEXPORT.apps|where{$_.DGNAME -eq $dg.name}
        
        if($apps)
        {
            foreach ($app in $apps)
            {
            write-host "Proccessing App $($app.browsername)"
            $appmatch = Get-BrokerApplication -AdminAddress $xdhost -ApplicationName $app.browsername -ErrorAction SilentlyContinue
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
                        if (-Not (check-BrokerAdminFolder $folder))
                        {
                        write-host "Creating folder" -ForegroundColor Green
                        create-adminfolders $folder
                        }
                    Write-host Moving App to correct folder -ForegroundColor Yellow
                    Move-BrokerApplication $appmatch -Destination $app.AdminFolderName
                    $appmatch = Get-BrokerApplication -AdminAddress $xdhost -ApplicationName $app.browsername -ErrorAction SilentlyContinue
                    }
                }
                clean-existingappobject $app $appmatch|Invoke-Expression

                    if((compare-icon $app $appmatch) -eq $false)
                    {
                    $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                    $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                    }
                clear-AppUserPerms $appmatch
                set-NewAppUserPerms $app $appmatch
                }
                else
                {
                write-host "Creating App" -ForegroundColor Green
                $folder = $app.AdminFolderName
                if($folder -is [object])
                {
                    if (-Not (check-BrokerAdminFolder $folder))
                    {
                    write-host "Creating folder" -ForegroundColor Green
                    create-adminfolders $folder
                    }
                }
                $makeapp = clean-newappobject $app
                $newapp = $makeapp|New-BrokerApplication -AdminAddress $xdhost
                $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                $newapp|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                set-UserPerms $makeapp
                if($app.FTA)
                {
                write-host HERE -ForegroundColor Yellow
                    foreach ($fta in $app.FTA)
                    {
                    clean-FTAobject $fta|New-BrokerConfiguredFTA -ApplicationUid $newapp.Uid
                    }
                }
                }
            }
        }

    
    
}

}