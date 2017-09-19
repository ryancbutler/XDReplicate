function Export-XDapp
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
    
    process{
        $found = @()
        foreach($ag in $appobject.AssociatedDesktopGroupUids)
        {
            $found += (get-brokerdesktopgroup -adminaddress $xdhost -Uid $ag).name
        }
        return $found
    }
    
}