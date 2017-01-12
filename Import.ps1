Add-PSSnapin citrix*
CLS
$XDEXPORT = Import-Clixml "C:\Temp\XDEXPORT.xml"
$xdhost = "localhost"

if ($XDEXPORT)
{

foreach($dg in ($XDEXPORT|select dgname -Unique))
{
write-host $dg.DGNAME

$dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.DGNAME -ErrorAction SilentlyContinue

    if($dgmatch)
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
            write-host "Proccessing App $($desktop.name)"
            $appmatch = Get-BrokerApplication -AdminAddress $xdhost -AllAssociatedDesktopGroupUid $dgmatch.Uid -ErrorAction SilentlyContinue
                if($appmatch)
                {
                write-host "App found"
                }
                else
                {
                write-host "Creating App"
                }
            }
        }

    
    }
}

}