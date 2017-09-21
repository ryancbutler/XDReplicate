function Set-XDAppGroupUserPerm
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
    [Parameter(Mandatory=$true)][Object[]]$appgroupmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )
    
    Write-Verbose "$($MyInvocation.MyCommand): Enter"
    if ($PSCmdlet.ShouldProcess("App Group Permissions")) {  
    
        if ($appgroup.UserFilterEnabled)
        {
        Write-Verbose "Setting App Group Permissions"
             
                if (($appgroupmatch.AssociatedUserNames).count -gt 0)
                {
                    $present = $appgroupmatch.AssociatedUserNames|Sort-Object
                    $needed = $appgroup.AssociatedUserNames|Sort-Object
                    $compares = Compare-Object -ReferenceObject $present -DifferenceObject $needed
                    
                            foreach ($compare in $compares)
                            {
                                switch ($compare.SideIndicator)
                                {
                                    "<=" {
                                        Remove-BrokerUser -AdminAddress $xdhost -applicationgroup $appgroupmatch.name -name $compare.InputObject
                                    }
                                    "=>" {
                                        Add-BrokerUser -AdminAddress $xdhost -applicationgroup $appgroupmatch.name  -name $compare.InputObject
                                    }
                                }
                            }
                }
                else {
                    foreach ($user in $appgroup.AssociatedUserNames)
                    {
                        Add-BrokerUser -AdminAddress $xdhost -applicationgroup $appgroupmatch.name -name $user
                    }
                }
                
        
                
             }
        }
    Write-Verbose "$($MyInvocation.MyCommand): Exit"
    }