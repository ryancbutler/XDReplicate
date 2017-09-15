function Set-XDNewAppUserPerm
{
<#
.SYNOPSIS
    Sets user permissions on NEW app
.DESCRIPTION
    Sets user permissions on NEW app
.PARAMETER APP
    Exported application
.PARAMETER APPMATCH
    Newly created app
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)]$appmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )

if ($app.UserFilterEnabled)
        {
        write-host "Setting App Permissions" -ForegroundColor Green
             foreach($user in $app.AssociatedUserNames)
             {
                write-host $user
                Add-BrokerUser -AdminAddress $xdhost -Name $user -Application $appmatch.Name
             }
        }
    

}
