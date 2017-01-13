Add-PSSnapin citrix*
CLS
$XDEXPORT = Import-Clixml "C:\Temp\XDEXPORT.xml"
$xdhost = "localhost"


function check-BrokerAdminFolder ($folder)
{
    write-host "Processing $folder"
    $foldermatch = Get-BrokerAdminFolder -name $folder -ErrorAction SilentlyContinue
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
                     New-BrokerAdminFolder -FolderName $paths[$d]|Out-Null
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

function clean-object ($cleanme)
{
$tempvar = @{}
    foreach($t in $cleanme.PSObject.Properties){
        if(-not ([string]::IsNullOrWhiteSpace($t.Value) -and -not ($t.name -eq "Name") ))
        {
            if ($t.name -eq "Name")
            {
            write-host FTHIS -ForegroundColor yellow
            }
            else
            {
            $t.name
            $tempvar|Add-Member -MemberType NoteProperty  -Name $t.Name -Value $t.Value
            }
        }
    }

return $tempvar
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
                Write-host "Creating Desktop"
                $desktop|New-BrokerEntitlementPolicyRule -DesktopGroupUid $dgmatch.Uid
                }

            }
        }
    $apps = $XDEXPORT|where{$_.ResourceType -eq "PublishedApp" -and $_.DGNAME -eq $dg.DGNAME}
        
        if($apps)
        {
            foreach ($app in $apps)
            {
            write-host "Proccessing App $($app.name)"
            $appmatch = Get-BrokerApplication -AdminAddress $xdhost -AllAssociatedDesktopGroupUid $dgmatch.Uid -ErrorAction SilentlyContinue
                if($appmatch)
                {
                write-host "App found"
                }
                else
                {
                write-host "Creating App" $app.Name
                $folder = $app.AdminFolderName
                if(-not ([string]::IsNullOrWhiteSpace($folder)))
                {
                    if (-Not (check-BrokerAdminFolder $folder))
                    {
                    write-host "Creating folder"
                    create-adminfolders $folder
                    }
                }
                $app = clean-object $app
                $app|New-BrokerApplication -ApplicationType HostedOnDesktop -DesktopGroup $dgmatch.name
                }
            }
        }

    
    }
}

}