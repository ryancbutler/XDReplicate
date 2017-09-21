function Export-XDappAG
{
<#
.SYNOPSIS
    Adds Application group names to Application Object
.DESCRIPTION
    Adds Application group names to Application Object
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
    Write-Verbose "$($MyInvocation.MyCommand): Enter"}

    process{
        $found = @()
        foreach($ag in $appobject.AssociatedApplicationGroupUids)
        {
            $found += (Get-BrokerApplicationGroup -adminaddress $xdhost -Uid $ag).name
        }
        return $found
    }

    end{
        Write-Verbose "$($MyInvocation.MyCommand): Exit"
    }
    
}