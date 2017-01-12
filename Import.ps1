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
                Write-host "Creating desktop"
                $desktop|New-BrokerEntitlementPolicyRule -DesktopGroupUid $dgmatch.Uid
                }

            }
        }

    }
}

}