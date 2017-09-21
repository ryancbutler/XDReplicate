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

    begin{
    Write-Verbose "$($MyInvocation.MyCommand): Enter"
    }

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
                    "=>" {
                        Remove-BrokerApplication -InputObject $appmatch -DesktopGroup $compare.InputObject
                    }
                    "<=" {
                        ADD-BrokerApplication -InputObject $appmatch -DesktopGroup $compare.InputObject
                    }
                }
            }
        }
    }
    
    if(($app.AssociatedApplicationGroupUids).count -gt 0)
    {
        Write-Verbose "Setting Application Group(s) for $($app.name)"
        if(($appmatch.AssociatedApplicationGroupUids).count -gt 0)
        {
            $agtemp = @()
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
                        "<=" {
                            Remove-BrokerApplication -InputObject $appmatch -ApplicationGroup $compare.InputObject|Out-Null
                        }
                        "=>" {
                            ADD-BrokerApplication -InputObject $appmatch -ApplicationGroup $compare.InputObject|Out-Null
                        }
                    }
                }
            }
        }
        else {
            foreach ($ag in $app.agname)
            {
                ADD-BrokerApplication -InputObject $appmatch -ApplicationGroup $ag|Out-Null  
            }
        }

    }
}
end{Write-Verbose "$($MyInvocation.MyCommand): Exit"}

}