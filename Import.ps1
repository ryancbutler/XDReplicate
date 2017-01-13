﻿Add-PSSnapin citrix*
CLS
$XDEXPORT = Import-Clixml "C:\Temp\XDEXPORT.xml"
$xdhost = "localhost"


function check-BrokerAdminFolder ($folder)
{
    write-host "Processing $folder"
    $foldermatch = Get-BrokerAdminFolder -AdminAddress $xdhost -name $folder -ErrorAction SilentlyContinue
    if ($foldermatch)
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
            write-host HERE $paths[$d] $d               
            if($d -eq 0)
                {                  
                    if((check-BrokerAdminFolder ($paths[$d])) -eq $false)
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

function clean-appobject ($app)
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

function set-UserPerms ($app)
{
    if ($app.UserFilterEnabled)
    {
    write-host "Setting App Permissions" -ForegroundColor Green
     foreach($user in $app.AssociatedUserNames)
     {
        Add-BrokerUser -AdminAddress $xdhost -Name $user -Application $app.Name
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

if ($XDEXPORT)
{

foreach($dg in ($XDEXPORT|select dgname -Unique))
{
write-host $dg.DGNAME

$dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.DGNAME -ErrorAction SilentlyContinue

    if (-not ([string]::IsNullOrWhiteSpace($dgmatch)))
    {
    write-host "Proccessing $($dgmatch.name)"
    $desktops = $XDEXPORT|where{$_.ResourceType -eq "Desktop" -and $_.DGNAME -eq $dg.DGNAME}

        if($desktops)
        {
            foreach ($desktop in $desktops)
            {
            write-host "Proccessing Desktop $($desktop.name)"
            $desktopmatch = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid -ErrorAction SilentlyContinue
                if($desktopmatch)
                {
                write-host "Desktop Found"
                #Set-BrokerEntitlementPolicyRule -Name $desktopmatch -
                }
                else
                {
                Write-host "Creating Desktop" -ForegroundColor Green
                $desktop|New-BrokerEntitlementPolicyRule -DesktopGroupUid $dgmatch.Uid
                }

            }
        }
    $apps = $XDEXPORT|where{$_.ResourceType -eq "PublishedApp" -and $_.DGNAME -eq $dg.DGNAME}
        
        if($apps)
        {
            foreach ($app in $apps)
            {
            write-host "Proccessing App $($app.browsername)"
            $appmatch = Get-BrokerApplication -AdminAddress $xdhost -ApplicationName $app.browsername -ErrorAction SilentlyContinue
                if(-not ([string]::IsNullOrWhiteSpace($appmatch)))
                {
                write-host "App found"
                }
                else
                {
                write-host "Creating App $($app.Name)" -ForegroundColor Green
                $folder = $app.AdminFolderName
                if(-not ([string]::IsNullOrWhiteSpace($folder)))
                {
                    if (-Not (check-BrokerAdminFolder $folder))
                    {
                    write-host "Creating folder" -ForegroundColor Green
                    create-adminfolders $folder
                    }
                }
                $makeapp = clean-appobject $app
                $newapp = $makeapp|New-BrokerApplication -AdminAddress $xdhost -DesktopGroup $dgmatch.name
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

}