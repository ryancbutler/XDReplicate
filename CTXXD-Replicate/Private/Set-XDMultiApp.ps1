function Set-XDMultiApp
{
<#
.SYNOPSIS
    Sets application options for apps with multiple delivery groups and application groups
.DESCRIPTION
    Sets application options for apps with multiple delivery groups and application groups
.PARAMETER APP
    Exported application with multiple delivery groups and application groups
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to


#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$app,
[Parameter(Mandatory=$true)][string]$xdhost 
)

    process
    {
    Write-Verbose "Setting $($app.name)"
    $appmatch = Get-BrokerApplication -Name $app.name -adminaddress $xdhost
    if(($app.AssociatedDesktopGroupUids).count -gt 1)
    {
       $dgtemp = @()
        Write-Verbose "Setting Delivery Group(s) for $($app.name)"

        foreach ($dg in $appmatch.AssociatedDesktopGroupUids)
        {
            $dg = Get-BrokerDesktopGroup -uid $dg -adminaddress $xdhost
            $dgtemp += $dg.name
        }
        $present = $dgtemp|Sort-Object
        $needed = $app.dgname|Sort-Object

        $compares = Compare-Object -ReferenceObject $present -DifferenceObject $needed
        if ($PSCmdlet.ShouldProcess("Setting Delivery Groups for $($app.name)")) {
            foreach ($compare in $compares)
            {
                switch ($compare.SideIndicator)
                {
                    "<=" {
                        Remove-BrokerApplication -InputObject $appmatch -DesktopGroup $compare.InputObject
                    }
                    "=>" {
                        ADD-BrokerApplication -InputObject $appmatch -DesktopGroup $compare.InputObject
                    }
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
        if ($PSCmdlet.ShouldProcess("Setting Application Groups for $($app.name)")) {
            foreach ($compare in $compares)
            {
                switch ($compare.SideIndicator)
                {
                    "=>" {$ag = Get-BrokerApplicationGroup -name $compare.InputObject
                        Remove-BrokerApplication -InputObject $appmatch -ApplicatonGroup $ag|Out-Null
                    }
                    "<=" {$ag = Get-BrokerApplicationGroup -name $compare.InputObject
                        ADD-BrokerApplication -InputObject $appmatch -ApplicatonGroup $ag|Out-Null
                    }
                }
            }
        }

    }
}

}