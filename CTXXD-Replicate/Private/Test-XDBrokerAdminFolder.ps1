function Test-XDBrokerAdminFolder 
{
<#
.SYNOPSIS
    Tests if administrative folder exists
.DESCRIPTION
    Checks for administrative folder and returns bool
.PARAMETER FOLDER
    Folder to validate
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[CmdletBinding()]
[OutputType([System.boolean])]
Param(
[Parameter(Mandatory=$true)][string]$folder,
[Parameter(Mandatory=$true)][string]$xdhost)

    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"   
    write-verbose "Processing Folder $folder"
    #Doesn't follow normal error handling so can't use try\catch
    Get-BrokerAdminFolder -AdminAddress $xdhost -name $folder -ErrorVariable myerror -ErrorAction SilentlyContinue
    if ($myerror -like "Object does not exist")
    {
        write-verbose "FOLDER NOT FOUND"
        $found = $false
    }
    else
    {
        write-verbose "FOLDER FOUND"
        $found = $true
    }
return $found
Write-Verbose "END: $($MyInvocation.MyCommand)"
}
