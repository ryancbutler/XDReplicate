function Test-XDicon
{
<#
.SYNOPSIS
    Tests to see if Icon exists and matches new application
.DESCRIPTION
    Tests to see if Icon exists and matches new application
.PARAMETER APP
    Newly created application
.PARAMETER APPMATCH
    Existing application
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to

#>
[CmdletBinding()]
[OutputType([System.boolean])]
Param (
    [Parameter(Mandatory=$true)]$app, 
    [Parameter(Mandatory=$true)]$appmatch, 
    [Parameter(Mandatory=$true)][string]$xdhost
    )

    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
    $newicon = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($appmatch.IconUid)).EncodedIconData
    if($newicon -like $app.EncodedIconData)
    {
        Write-Verbose "Icons Match"
        $match = $true
    }
    else
    {
        Write-Verbose "Icons do not match"
        $match = $false
    }
return $match
Write-Verbose "END: $($MyInvocation.MyCommand)"
}
