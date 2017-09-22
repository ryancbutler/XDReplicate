function import-xdadminrole
{
<#
.SYNOPSIS
    Creates admin role exported object
.DESCRIPTION
    Creates admin role exported object
.PARAMETER ROLE
    Role to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER DGMATCH
    Delivery group to create application
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$role,
[Parameter(Mandatory=$true)][string]$xdhost
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
process{
    $rolematch = Get-AdminRole -AdminAddress $xdhost -Name $role.name -ErrorAction SilentlyContinue
    if ($rolematch -is [object])
    {
    write-verbose "Found $($role.Name)"
    }
    else
    {
    write-verbose "Adding $($role.name)"
    $rolematch = New-AdminRole -AdminAddress $xdhost -Description $role.Description -Name $role.Name
    Add-AdminPermission -AdminAddress $xdhost -Permission $role.Permissions -Role $role.name|out-null
    }
    return $rolematch
}
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}