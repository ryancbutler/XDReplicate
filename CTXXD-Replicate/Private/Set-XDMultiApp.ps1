function Set-XDMultiApp
{
<#
.SYNOPSIS
    Sets application options for apps with multiple delivery groups and application groups
.DESCRIPTION
    Sets application options for apps with multiple delivery groups and application groups
.PARAMETER APPS
    Exported applications with multiple delivery groups and application groups
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to


#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true)]$apps,
[Parameter(Mandatory=$true)][string]$xdhost 
)

foreach ($app in $apps)
{
    $appmatch = Get-BrokerApplication -Name $app.name -adminaddress $xdhost
    if(($app.AssociatedDesktopGroupUids).count -gt 1)
    {
        Write-Verbose "Setting Delivery Group(s) for $($app.name)"
        foreach ($dg in $appmatch.AssociatedDesktopGroupUids)
        {
            $dg = Get-BrokerDesktopGroup -uid $dg
            Remove-BrokerApplication -InputObject $appmatch -DesktopGroup $dg
        }
        foreach ($dg in $app.DGNAME)
        {
            $dg = Get-BrokerDesktopGroup -name $dg
            Add-BrokerApplication -InputObject $appmatch -DesktopGroup $dg
        }
    }
    
    if(($app.AssociatedApplicationGroupUids).count -gt 0)
    {
        Write-Verbose "Setting Application Group(s) for $($app.name)"
        foreach ($ag in $appmatch.AssociatedApplicationGroupUids)
        {
            $ag = Get-BrokerApplicationGroup -uid $ag
            Remove-BrokerApplication -InputObject $appmatch -ApplicationGroup $ag
        }
        foreach ($ag in $app.AGNAME)
        {
            $ag = Get-BrokerApplicationGroup -name $ag
            Add-BrokerApplication -InputObject $appmatch -ApplicationGroup $ag
        }
    }
}

}