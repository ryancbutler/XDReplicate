function new-xddesktopded {
<#
.SYNOPSIS
   Adds machines to Dedicated XenDesktop Machine Catalog and Delivery Group via MCS
.DESCRIPTION
    Adds machines to Dedicated XenDesktop Machine Catalog and Delivery Group via MCS
.PARAMETER machinecat
   Machine Catalog to add to
.PARAMETER dgroup
   Delivery group to add newly created machines to
.PARAMETER Howmany
   Count of machines to add to the site (ususally 1 for dedicated)
.PARAMETER User
   AD user to add to desktop
.EXAMPLE
   new-xddesktopded -machinecat "Windows 10 x64 Random" -dgroup "Windows 10 Desktop" -user "lab\joeshmith"
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
[Parameter(Mandatory=$true)][string]$machinecat,
[Parameter(Mandatory=$true)][string]$dgroup,
[Parameter(Mandatory=$true)][string]$user,
[Parameter(Mandatory=$false)][string]$xdhost="localhost")

test-xdvariable -dgroup $dgroup -machinecat $machinecat -xdhost $xdhost

if ($PSCmdlet.ShouldProcess("Adding machine to dedicated desktop group")) {
    new-xdaccount 1 $machinecat $xdhost
    $desktop = new-xddesktop 1 $machinecat $dgroup $user $xdhost
    return $desktop
}

}
