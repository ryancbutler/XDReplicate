function Export-XDappgroup
{
<#
.SYNOPSIS
    Creates new administrative folder
.DESCRIPTION
    Checks for and creates administrative folder if not found
.PARAMETER FOLDER
    Folder to validate
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$folder,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
    
    process{

    }
}