function Set-XDAppEntitlement  {
<#
.SYNOPSIS
    Sets AppEntitlement if missing
.DESCRIPTION
    Sets AppEntitlement if missing
.PARAMETER DG
    Desktop Group where to create entitlement
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param (
    [Parameter(Mandatory=$true)]$dg, 
    [Parameter(Mandatory=$true)][string]$xdhost)

    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
    if ($PSCmdlet.ShouldProcess("Setting app entitlements")) {   
        if (($dg.DeliveryType -like "AppsOnly" -or $dg.DeliveryType -like "DesktopsAndApps"))
        {
            if((Get-BrokerAppEntitlementPolicyRule -name $dg.Name -AdminAddress $xdhost -ErrorAction SilentlyContinue) -is [Object])
            {
            Write-Verbose "AppEntitlement already present"
            }
            ELSE
            {
            Write-Verbose "Creating AppEntitlement"
            New-BrokerAppEntitlementPolicyRule -Name $dg.Name -DesktopGroupUid $dg.uid -AdminAddress $xdhost -IncludedUserFilterEnabled $false|Out-Null
            }
        }
        else
        {
        Write-Verbose "No AppEntitlement needed"
        }
    }
    Write-Verbose "END: $($MyInvocation.MyCommand)"
}
