function Set-XDNewAppGroupUserPerm
{
<#
.SYNOPSIS
    Sets user permissions on app group
.DESCRIPTION
    Sets user permissions on app group
.PARAMETER APP
    Exported application group
.PARAMETER APPMATCH
    Newly created app
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param (
    [Parameter(Mandatory=$true)]$appgroup, 
    [Parameter(Mandatory=$true)]$appgroupmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )

    if ($PSCmdlet.ShouldProcess("App Group Permissions")) {  
    
        if ($appgroup.UserFilterEnabled)
        {
        Write-Verbose "Setting App Group Permissions"
             foreach($user in $appgroup.AssociatedUserNames)
             {
                Write-Verbose $user
                Add-BrokerUser -AdminAddress $xdhost -Name $user -Applicationgroup $appgroupmatch.Name
             }
        }
    }

}
