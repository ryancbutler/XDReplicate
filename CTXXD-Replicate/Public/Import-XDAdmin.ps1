function import-xdadmin
{
<#
.SYNOPSIS
    Creates admin user from imported object
.DESCRIPTION
    Creates admin user from imported object
.PARAMETER admin
    Admin user to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
    $XDEXPORT.admins|import-xdadmin
    Creates admin users from imported admin user object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$admin,
[Parameter(Mandatory=$true)][string]$xdhost
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
process{
    $adminmatch = Get-AdminAdministrator -Sid $admin.Sid -AdminAddress $xdhost -ErrorAction SilentlyContinue
    if ($adminmatch -is [object])
    {
    write-verbose "Found $($admin.Name)"
    }
    else
    {
    write-verbose "Adding $($admin.Name)"
    $rights = ($admin.Rights) -split ":"
    $adminmatch = New-AdminAdministrator -AdminAddress $xdhost -Enabled $admin.Enabled -Sid $admin.Sid|out-null
    Add-AdminRight -AdminAddress $xdhost -Administrator $admin.name -Role $rights[0] -Scope $rights[1]|Out-Null
    }
    return $adminmatch
}

end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}