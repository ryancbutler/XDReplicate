function Export-XDAppGroup
{
<#
.SYNOPSIS
    Adds delivery group names to Application Group Object required for import process
.DESCRIPTION
    Adds delivery group names to Application Group Object required for import process
.PARAMETER appgroupobject
    Application Group object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
    $appgroups = Get-BrokerApplicationGroup|export-xdappgroup -xdhost $xdhost
    Grabs all application groups and adds required values to object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$appgroupobject,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
    process{
        $found = @()
        foreach($ag in $appgroupobject.AssociatedDesktopGroupUids)
        {
            $found += (get-brokerdesktopgroup -adminaddress $xdhost -Uid $ag).name
        }
        $appgroupobject|Add-Member -NotePropertyName "DGNAMES" -NotePropertyValue $found
        return $appgroupobject
    }
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}   
}