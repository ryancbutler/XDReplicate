function Clear-XDAppUserPerm 
{
<#
.SYNOPSIS
    Clears permissions from App
.DESCRIPTION
    Clears permissions from App
.PARAMETER APP
    Application to remove permissions
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )
    
    Write-Verbose "$($MyInvocation.MyCommand): Enter"
    if ($app.UserFilterEnabled)
        {
             foreach($user in $app.AssociatedUserNames)
             {
                $user = get-brokeruser $user
                Remove-BrokerUser -AdminAddress $xdhost -inputobject $user -Application $app.Name|Out-Null
             }
        }
    Write-Verbose "$($MyInvocation.MyCommand): Exit"
}
