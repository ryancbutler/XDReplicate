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
       $dgtemp = @()
        Write-Verbose "Setting Delivery Group(s) for $($app.name)"

        foreach ($dg in $appmatch.AssociatedDesktopGroupUids)
        {
            $dg = Get-BrokerDesktopGroup -uid $dg
            $dgtemp += $dg.name
        }
        $present = $dgtemp|Sort-Object
        $needed = $app.dgname|Sort-Object

        $compares = Compare-Object -ReferenceObject $present -DifferenceObject $needed

        foreach ($compare in $compares)
        {
            switch ($compare.SideIndicator)
            {
                "=>" {$dg = Get-BrokerDesktopGroup -name $compare.InputObject
                    Remove-BrokerApplication -InputObject $appmatch -DeliveryGroup $dg
                }
                "<=" {$dg = Get-BrokerDesktopGroup -name $compare.InputObject
                    ADD-BrokerApplication -InputObject $appmatch -DeliveryGroup $dg
                }
            }
        }
    }
    
    if(($app.AssociatedApplicationGroupUids).count -gt 0)
    {
        $agtemp = @()
        Write-Verbose "Setting Application Group(s) for $($app.name)"
        foreach ($ag in $appmatch.AssociatedApplicationGroupUids)
        {
            $ag = Get-BrokerApplicationGroup -uid $ag
            $agtemp += $ag.name
        }
        $present = $agtemp|Sort-Object
        $needed = $app.agname|Sort-Object

        $compares = Compare-Object -ReferenceObject $present -DifferenceObject $needed

        foreach ($compare in $compares)
        {
            switch ($compare.SideIndicator)
            {
                "=>" {$ag = Get-BrokerApplicationGroup -name $compare.InputObject
                    Remove-BrokerApplication -InputObject $appmatch -ApplicatonGroup $ag
                }
                "<=" {$ag = Get-BrokerApplicationGroup -name $compare.InputObject
                    ADD-BrokerApplication -InputObject $appmatch -DeliveryGroup $ag
                }
            }
        }

    }
}

}