function New-XDMCSDesktop {
<#
.SYNOPSIS
   Adds machines to XenDesktop Machine Catalog and Delivery Group via MCS
.DESCRIPTION
    Adds machines to XenDesktop Machine Catalog and Delivery Group via MCS
.PARAMETER machinecat
   Machine Catalog to add to
.PARAMETER dgroup
   Delivery group to add newly created machines to
.PARAMETER Howmany
   Count of machines to add to the site (pooled)
.PARAMETER User
   AD user to add to dedicated desktop (domain\username)
.EXAMPLE
   New-XDMCSDesktop -machinecat "Windows 10 x64 Random" -dgroup "Windows 10 Desktop" -mctype "Dedicated" -user "lab\joeshmith"
.EXAMPLE
   New-XDMCSDesktop -machinecat "Windows 10 x64 Dedicated" -dgroup "Windows 10 Desktop" -mctype "Pooled" -howmany "10"
#> 
 
 [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
 Param(

  [Parameter(Position=0,Mandatory=$True,HelpMessage="Machine Catalog")]

  [string]$machinecat,

  [Parameter(Position=1,Mandatory=$True,HelpMessage="Delivery Group")]

  [string]$dgroup,

  [Parameter(Mandatory=$true,Position=2,HelpMessage="Machine Catalog type (Dedicated Or Pooled)")]
  [ValidateSet("Dedicated","Pooled")]
  [string]$mctype,
  
  [Parameter(Mandatory=$false,Position=3,HelpMessage="How many dedicated machines to deploy")]
  [int]$howmany,
  
  [Parameter(Mandatory=$false,Position=4,HelpMessage="Username to deploy dedicated machine to (domain\username")]
  [string]$user,

  [Parameter(Mandatory=$false,Position=5)][string]$xdhost="localhost"

 )
 Begin {
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
     #param validation
     if ($mctype -eq "dedicated")
     {
        if([string]::IsNullOrEmpty($user))
        {
            throw "USERNAME must be populated for dedicated deployment"
        }

     }
     else
     {
        if(-not ($howmany -ge 1) )
        {
            throw "HOWMANY must be populated for pooled deployment"
        }
     }
 }

 Process {
    if ($mctype -eq "dedicated")
     {
    test-xdvariable -dgroup $dgroup -machinecat $machinecat -xdhost $xdhost -erroraction stop
    if ($PSCmdlet.ShouldProcess("Adding machine to dedicated desktop group")) {
            if (Test-XDBrokerCatalog -machinecat $machinecat -xdhost $xdhost -mctype "dedicated")
            {
            new-xdaccount -howmany 1 -machinecat $machinecat -xdhost $xdhost|write-verbose
            $desktop = new-xddesktop -howmany 1 -machinecat $machinecat -dgroup $dgroup -user $user -xdhost $xdhost
            return $desktop
            }       
        }
     }
    else {
    test-xdvariable -dgroup $dgroup -machinecat $machinecat -xdhost $xdhost -erroraction stop
    if ($PSCmdlet.ShouldProcess("Deploying desktop(s) to machine catalog and delivery group")) {
            if (Test-XDBrokerCatalog -machinecat $machinecat -xdhost $xdhost -mctype "pooled")
            {
            new-xdaccount -howmany $Howmany -machinecat $machinecat -xdhost $xdhost|write-verbose
            $desktop = new-xddesktop -howmany $Howmany -machinecat $machinecat -dgroup $dgroup -xdhost $xdhost
            return $desktop
            }    
        }
    }
 }
 end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
 }