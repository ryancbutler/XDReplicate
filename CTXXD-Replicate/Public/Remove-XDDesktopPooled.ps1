function remove-xddesktoppooled  {
<#
.SYNOPSIS
   Removes desktop from given delivery group
.DESCRIPTION
   Removes desktop from given delivery group
.PARAMETER dgroup
   Delivery group to query from
.PARAMETER howmany
   How many desktops to remove
.EXAMPLE
   remove-xddesktoppooled -dgroup "Windows 10 Desktop" -howmany 10
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
param(
[Parameter(Mandatory=$true)][string]$dgroup,
[Parameter(Mandatory=$true)][int]$howmany,
[Parameter(Mandatory=$false)][string]$xdhost="localhost")

test-xdvariable -dgroup $dgroup -xdhost $xdhost

    #Get all machines and get the ones we want to remove
    $accts = Get-Brokermachine -DesktopGroupName $dgroup -adminaddress $xdhost|Sort-Object hostedmachinename|Select-Object -Last $howmany

    if ($PSCmdlet.ShouldProcess("Removing accounts")) {
        #call remove desktop function and pass machine names
        remove-xddesktop $accts $xdhost
        #Gets identity pool to reset start count
        $machinecat = $accts
        $identPool = Get-AcctIdentityPool -IdentityPoolName ($accts[0].CatalogName) -adminaddress $xdhost
        Set-AcctIdentityPool -IdentityPoolName ($accts[0].CatalogName) -StartCount ($identPool.startcount - $Howmany) -adminaddress $xdhost
    }

    
}
