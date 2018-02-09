function new-xddesktoppooled {
<#
.SYNOPSIS
   Adds machines to Random Pooled XenDesktop Machine Catalog and Delivery Group via MCS
.DESCRIPTION
    Adds machines to Random Pooled XenDesktop Machine Catalog and Delivery Group via MCS
.PARAMETER machinecat
   Machine Catalog to add to
.PARAMETER dgroup
   Delivery group to add newly created machines to
.PARAMETER Howmany
   Count of machines to add to the site
.EXAMPLE
   new-xddesktoppooled -machinecat "Windows 10 x64 Random" -dgroup "Windows 10 Desktop" -howmany 5
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
[Parameter(Mandatory=$true)][string]$machinecat,
[Parameter(Mandatory=$true)][string]$dgroup,
[Parameter(Mandatory=$true)][int]$Howmany,
[Parameter(Mandatory=$false)][string]$xdhost="localhost")

test-xdvariable -dgroup $dgroup -machinecat $machinecat -xdhost $xdhost

if ($PSCmdlet.ShouldProcess("Deploying desktop(s) to machine catalog and delivery group")) {
    new-xdaccount $Howmany $machinecat $xdhost
    new-xddesktop $Howmany $machinecat $dgroup $xdhost
}

}
