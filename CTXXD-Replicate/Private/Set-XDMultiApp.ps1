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
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
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
                    "<=" {
                        write-verbose "REMOVE DG $($compare.InputObject)"
                        Remove-BrokerApplication -InputObject $appmatch -DesktopGroup $compare.InputObject
                    }
                    "=>" {
                        write-verbose "ADD DG $($compare.InputObject)"
                        ADD-BrokerApplication -InputObject $appmatch -DesktopGroup $compare.InputObject
                    }
                }
            }
        }
    }
    
    if(($app.AssociatedApplicationGroupUids).count -gt 0)
    {
        Write-Verbose "Setting Application Group(s) for $($app.PublishedName)"
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
            if ($PSCmdlet.ShouldProcess("Setting Application Groups for $($app.PublishedName)")) {
                foreach ($compare in $compares)
                {
                    switch ($compare.SideIndicator)
                    {
                        "<=" {
                            write-verbose "REMOVE AG $($compare.InputObject)"
                            Remove-BrokerApplication -InputObject $appmatch -ApplicationGroup $compare.InputObject|Out-Null
                        }
                        "=>" {
                            write-verbose "REMOVE AG $($compare.InputObject)"
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
    elseif (!($app.AssociatedApplicationGroupUids) -and ($appmatch.AssociatedApplicationGroupUids)) {
        $agtemp = @()
        foreach ($ag in $appmatch.AssociatedApplicationGroupUids)
        {
            $ag = Get-BrokerApplicationGroup -uid $ag
            Remove-BrokerApplication -InputObject $appmatch -ApplicationGroup $ag.name|Out-Null
        }
        
    }
}
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}

}