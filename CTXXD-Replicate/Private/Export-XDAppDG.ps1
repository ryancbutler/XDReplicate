function Export-XDappDG
{
<#
.SYNOPSIS
    Adds delivery group names to Application Object
.DESCRIPTION
    Adds delivery group names to Application Object
.PARAMETER appgroupobject
    Application Group
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$appobject,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)

    begin{
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
    } 
    process{
        $found = @()
        foreach($dg in $appobject.AssociatedDesktopGroupUids)
        {
            $found += (get-brokerdesktopgroup -adminaddress $xdhost -Uid $dg).name
        }
        return $found
    }
    end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}