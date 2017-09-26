function Set-XDAppUserPerm
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
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)]$appmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )
    
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
    if ($PSCmdlet.ShouldProcess("App Permissions")) {  
    
        if ($app.UserFilterEnabled)
        {
        Write-Verbose "Setting App Permissions"
             foreach($user in $app.AssociatedUserNames)
             {
                Write-Verbose $user
                Add-BrokerUser -AdminAddress $xdhost -Name $user -Application $appmatch.Name
             }
        }
    }
    Write-Verbose "END: $($MyInvocation.MyCommand)"
}
