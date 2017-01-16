CLS
Add-PSSnapin citrix*
$ExportPath = "C:\temp\XDEXPORT.xml"
$tag = "replicate"
$source = "ctxxdc01"
$mode = "both"
$destination = "CTX-DDC-TST"


function export-xd ($xdhost)
{
    #Need path for XML while in EXPORT
    if($mode -like "export" -and ([string]::IsNullOrWhiteSpace($exportpath)))
    {
    throw "Must Set Export Path while mode is set to EXPORT"
    }

    if(-not ([string]::IsNullOrWhiteSpace($tag)))
    {
    Write-Host HERE
    $DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -Tag $tag
    }
    else
    {
    write-host THERE
    $DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -Tag
    }

    #Create Empty arrays
    $appobject = @()
    $desktopobject = @()

    #Each delivery group
    foreach ($DG in $DesktopGroups)
    {
        write-host $DG.Name
        $dg|add-member -NotePropertyName 'AccessPolicyRule' -NotePropertyValue (Get-BrokerAccessPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid)
        $dg|add-member -NotePropertyName 'PreLaunch' -NotePropertyValue (Get-BrokerSessionPreLaunch -AdminAddress $xdhost -Desktopgroupuid $dg.Uid -ErrorAction SilentlyContinue )
        
        #Grabs APP info
        $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID    
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
    $desktops = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid 
    if($desktops -is [object])
    {
    
        foreach ($desktop in $desktops)
        {
        Write-Host "Processing $($desktop.PublishedName)"
        #Adds delivery group name to object
        $desktop|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
        $desktopobject += $desktop
        }
    
    }

}

    #buid output object
    $xdout = New-Object PSCustomObject
    Write-Host "Processing Administrators"
    $xdout|Add-Member -NotePropertyName "admins" -NotePropertyValue (Get-AdminAdministrator -AdminAddress $xdhost)
    Write-Host "Processing Scopes"
    $xdout|Add-Member -NotePropertyName "adminscopes" -NotePropertyValue (Get-AdminScope -AdminAddress $xdhost|where{$_.BuiltIn -eq $false})
    Write-Host "Processing Roles"
    $xdout|Add-Member -NotePropertyName "adminroles" -NotePropertyValue (Get-AdminRole -AdminAddress $xdhost|where{$_.BuiltIn -eq $false})
    $xdout|Add-Member -NotePropertyName "dgs" -NotePropertyValue $DesktopGroups
    $xdout|Add-Member -NotePropertyName "apps" -NotePropertyValue $appobject
    $xdout|Add-Member -NotePropertyName "desktops" -NotePropertyValue $desktopobject

    #Export to either variable or XML
    if($mode -like "export")
    {
    $xdout|Export-Clixml -Path ($exportpath)
    }
    else
    {
    return $xdout
    }

}

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

function create-adminfolders ($folder, $xdhost)
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
                "Name" {$tempvar|Add-Member -MemberType NoteProperty -Name "Name" -Value $app.BrowserName}
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

function clean-existingappobject ($app, $appmatch, $xdhost)
{
$tempvarapp = "Set-BrokerApplication -adminaddress $($xdhost)"
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

function clean-Desktopobject ($desktop, $xdhost)
{
$tempvardesktop = "Set-BrokerEntitlementPolicyRule -adminaddress $($xdhost)"
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

function clean-newDeliveryGroupObject ($dg, $xdhost)
{
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

function clean-ExistingDeliveryGroupObject ($dg, $xdhost)
{
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

function set-UserPerms ($app, $xdhost)
{
    if($app.ResourceType -eq "Desktop")
    {
        if ($app.IncludedUserFilterEnabled)
        {
        Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -AddIncludedUsers $app.includedusers -Name $app.Name
        }

        if ($app.ExcludedUserFilterEnabled)
        {
        Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -AddExcludedUserss $app.excludedusers -Name $app.Name
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

function set-NewAppUserPerms ($app, $appmatch, $xdhost)
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

function clear-AppUserPerms ($app, $xdhost)
{
    if ($app.UserFilterEnabled)
        {
             foreach($user in $app.AssociatedUserFullNames)
             {
                Remove-BrokerUser -AdminAddress $xdhost -Name $user -Application $app.Name
             }
        }
}

function clear-DesktopUserPerms ($desktop, $xdhost)
{

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

function compare-icon ($app, $appmatch, $xdhost)
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

function import-xd ($xdhost, $xdexport)
{
    if (!($XDEXPORT))
    {
    throw "Nothing to import"
    }

    if($mode -like "import")
    {
    $XDEXPORT = Import-Clixml $ExportPath
    }

    foreach($dg in $XDEXPORT.dgs)
    {
    write-host "Proccessing $($dg.name)"

    $dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.NAME -ErrorAction SilentlyContinue

        if ($dgmatch -is [object])
        {
        write-host "Setting $($dgmatch.name)"
        clean-ExistingDeliveryGroupObject $dg $xdhost|Invoke-Expression
        Get-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid|remove-BrokerAccessPolicyRule
        $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid|Out-Null
        }
        else
        {
        Write-host "Creating Delivery Group" -ForegroundColor Green
            try
            {
            $dgmatch = clean-newDeliveryGroupObject $dg $xdhost|Invoke-Expression
            }
            Catch
            {
            throw "Delivery group failed. $($_.Exception.Message)"
            }
        $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null
    
        }

        if($dg.prelaunch -is [object])
        {
        write-host "Setting pre-launch" -ForegroundColor Gray
        Remove-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupName $dg.Name -ErrorAction SilentlyContinue
        $dg.PreLaunch|New-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null

        }
    
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
                    clean-Desktopobject $desktop $xdhost|invoke-expression
                    clear-DesktopUserPerms $desktopmatch $xdhost
                    set-userperms $desktop $xdhost
                    }
                    else
                    {
                    Write-host "Creating Desktop" -ForegroundColor Green
                    $newdesktop = $desktop|New-BrokerEntitlementPolicyRule -DesktopGroupUid $dgmatch.Uid
                    set-userperms $desktop $xdhost
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
                            create-adminfolders $folder $xdhost
                            }
                        Write-host Moving App to correct folder -ForegroundColor Yellow
                        Move-BrokerApplication -AdminAddress $xdhost $appmatch -Destination $app.AdminFolderName
                        $appmatch = Get-BrokerApplication -AdminAddress $xdhost -ApplicationName $app.browsername -ErrorAction SilentlyContinue
                        }
                    }
                    clean-existingappobject $app $appmatch $xdhost|Invoke-Expression

                        if((compare-icon $app $appmatch $xdhost) -eq $false)
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
                    if($folder -is [object])
                    {
                        if (-Not (check-BrokerAdminFolder $folder))
                        {
                        write-host "Creating folder" -ForegroundColor Green
                        create-adminfolders $folder
                        }
                    }
                    $makeapp = clean-newappobject $app
                    
                    $newapp = $makeapp|New-BrokerApplication -AdminAddress $xdhost -DesktopGroup $dgmatch.Name
                   
                    $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
                    $newapp|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
                    set-UserPerms $makeapp $xdhost
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

    $currentroles = Get-AdminPermission -AdminAddress $xdhost
    write-host "Checking Admin Roles"
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


    $currentadmins = Get-AdminAdministrator -AdminAddress $xdhost
    write-host "Checking admins"
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
        $rights = $admin.Rights -split ":"
        Add-AdminRight -Administrator $admin.name -scope $rights[1] -Role $rights[0]|out-null

        }

    }

}


$xdexport = export-xd $source
import-xd $destination $xdexport
