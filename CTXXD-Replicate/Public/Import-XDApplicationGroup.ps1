function import-xdApplicationGroup
{
<#
.SYNOPSIS
    Creates application group from exported object
.DESCRIPTION
    Creates application group from exported object
.PARAMETER AG
    Application Group to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$ag,
[Parameter(Mandatory=$true)][string]$xdhost
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
Process
{

        $agmatch = Get-BrokerApplicationGroup -AdminAddress $xdhost -Name $ag.name -ErrorAction SilentlyContinue
        if ($agmatch -is [object])
        {
        write-verbose "Found $($ag.Name)"
        Set-XDAppGroup -xdhost $xdhost -appgroupmatch $agmatch -appgroup $ag
        Set-XDAppGroupUserPerm -xdhost $xdhost -appgroupmatch $agmatch -appgroup $ag
        Set-XDAppGroupDG -xdhost $xdhost -appgroup $ag
        }
        else
        {
        write-verbose "Adding $($ag.name)"
        $agmatch = New-XDAppGroup -xdhost $xdhost -appgroup $ag
        Set-XDAppGroupUserPerm -xdhost $xdhost -appgroupmatch $agmatch -appgroup $ag
        Set-XDAppGroupDG -xdhost $xdhost -appgroup $ag
        }
    return $agmatch
    }
    end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}