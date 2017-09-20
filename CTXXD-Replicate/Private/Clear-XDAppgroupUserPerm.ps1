function Clear-XDAppGroupUserPerm 
{
<#
.SYNOPSIS
    Clears permissions from App Group
.DESCRIPTION
    Clears permissions from App Group
.PARAMETER APP
    Application to remove permissions
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]$appgroup, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )
    
    if ($appgroup.UserFilterEnabled)
        {
             foreach($user in $appgroup.AssociatedUserNames)
             {
                write-verbose "Setting $user"
                Remove-BrokerUser -AdminAddress $xdhost -Name $user -Applicationgroup $appgroupmatch.Name|Out-Null
             }
        }
}
