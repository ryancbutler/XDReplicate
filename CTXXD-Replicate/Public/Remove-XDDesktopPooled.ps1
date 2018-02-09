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
[Parameter(Mandatory=$true)][int]$howmany)

test-xdvariable -dgroup $dgroup

    #Get all machines and get the ones we want to remove
    $accts = Get-Brokermachine -DesktopGroupName $dgroup|Sort-Object hostedmachinename|Select-Object -Last $howmany

    if ($PSCmdlet.ShouldProcess("Removing accounts")) {
        #call remove desktop function and pass machine names
        remove-xddesktop $accts
        #Gets identity pool to reset start count
        $identPool = Get-AcctIdentityPool -IdentityPoolName $machinecat
        Set-AcctIdentityPool -IdentityPoolName $machinecat -StartCount ($identPool.startcount - $Howmany)
    }

    
}
