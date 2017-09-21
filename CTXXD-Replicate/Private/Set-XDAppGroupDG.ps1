function Set-XDAppGroupDG
{
<#
.SYNOPSIS
    Sets application groups delivery groups
.DESCRIPTION
    Sets application groups delivery groups
.PARAMETER APPGROUP
    Exported application groups
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to


#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$appgroup,
[Parameter(Mandatory=$true)][string]$xdhost 
)

    process
    {
    Write-Verbose "Setting $($appgroup.name)"
    $appgroupmatch = Get-BrokerApplicationGroup -Name $appgroup.name -adminaddress $xdhost

        if(($appgroup.DGNAMES).count -gt 0)
        {
            if(($appmatch.AssociatedDesktopGroupUids).count -gt 0)
            {
                $dgtemp = @()
                Write-Verbose "Setting Delivery Group(s) for Application Group $($appgroup.name)"

                foreach ($dg in $appgroupmatch.AssociatedDesktopGroupUids)
                {
                    $dg = Get-BrokerDesktopGroup -uid $dg
                    $dgtemp += $dg.name
                }
                $present = $dgtemp|Sort-Object
                $needed = $appgroup.dgnames|Sort-Object

                $compares = Compare-Object -ReferenceObject $present -DifferenceObject $needed
            if ($PSCmdlet.ShouldProcess("Setting Application Group $($appgroup.name) Permissions")) {  
                foreach ($compare in $compares)
                {
                    switch ($compare.SideIndicator)
                    {
                        "=>" {#$dg = Get-BrokerDesktopGroup -name $compare.InputObject
                            Remove-BrokerApplicationGroup -InputObject $appgroupmatch -DesktopGroup $compare.InputObject
                        }
                        "<=" {#$dg = Get-BrokerDesktopGroup -name $compare.InputObject
                            Add-BrokerApplicationGroup -InputObject $appgroupmatch -DesktopGroup $compare.InputObject
                        }
                    }
            
                }
            
                else {
                    foreach ($dg in $appgroup.DGNAMES)
                    {
                        Add-BrokerApplicationGroup -InputObject $appgroupmatch -DesktopGroup $dg
                    }
                }
            }
        }
        }
    
    }
}