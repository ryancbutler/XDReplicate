function Clear-XDDesktopUserPerm
{
<#
.SYNOPSIS
    Clears permissions from Desktop object
.DESCRIPTION
    Clears permissions from Desktop object
.PARAMETER DESKTOP
    Desktop to remove permissions
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]$desktop, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )

    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"

        if ($desktop.IncludedUserFilterEnabled)
        {
            foreach($user in $desktop.IncludedUsers)
            {
            Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -RemoveIncludedUsers $user -Name $desktop.Name
            }
        }

        if ($desktop.ExcludedUserFilterEnabled)
        {
            foreach($user in $desktop.ExcludedUsers)
            {
            Set-BrokerEntitlementPolicyRule -AdminAddress $xdhost -RemoveExcludedUsers $user -Name $desktop.Name
            }
        }
    Write-Verbose "END: $($MyInvocation.MyCommand)"
}
