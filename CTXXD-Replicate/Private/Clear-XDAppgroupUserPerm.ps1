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
                $user = get-brokeruser $user
                Remove-BrokerUser -AdminAddress $xdhost -inputobject $user -Applicationgroup $app.Name|Out-Null
             }
        }
}
