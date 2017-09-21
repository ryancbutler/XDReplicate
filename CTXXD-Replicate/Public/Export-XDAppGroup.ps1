function Export-XDappgroup
{
<#
.SYNOPSIS
    Adds delivery group names to Application Group Object
.DESCRIPTION
    Adds delivery group names to Application Group Object
.PARAMETER appgroupobject
    Application Group
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$appgroupobject,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
    
    process{
        $found = @()
        foreach($ag in $appgroupobject.AssociatedDesktopGroupUids)
        {
            $found += (get-brokerdesktopgroup -adminaddress $xdhost -Uid $ag).name
        }
        $appgroupobject|Add-Member -NotePropertyName "DGNAMES" -NotePropertyValue $found
        return $appgroupobject
    }
    
}