function Remove-XDMCSDesktop {
<#
.SYNOPSIS
   Removes desktop(s) from given delivery group
.DESCRIPTION
   Removes desktop(s) from given delivery group
.PARAMETER dggroup
   Delivery group to remove desktop(s) from (pooled only)
.PARAMETER mctype
   Machine catalog type (dedicated or pooled)
.PARAMETER desktop
   Dedicated desktop name to remove (domain\machinename)
.PARAMETER howmany
    How many pooled machines to remove
.EXAMPLE
   Remove-XDMCSdesktop -desktop "MYDOMAIN\MYVDI01" -mctype "Dedicated"
.EXAMPLE
   Remove-XDMCSdesktop -howmany 5 -dgroup "Windows 7 Pooled Test" -mctype "Pooled"
#> 
 [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
 Param(


  [Parameter(Position=0,Mandatory=$false,HelpMessage="Delivery Group")]

  [string]$dgroup,

  [Parameter(Mandatory=$true,Position=1,HelpMessage="Machine Catalog type (Dedicated Or Pooled)")]
  [ValidateSet("Dedicated","Pooled")]
  [string]$mctype,
  
  [Parameter(Mandatory=$false,Position=2,HelpMessage="How many dedicated machines to remove")]
  [string]$howmany,
  
  [Parameter(Mandatory=$false,Position=3,HelpMessage="Machine name to remove (domain\machine")]
  [string]$machine,

  [Parameter(Mandatory=$false,Position=4)][string]$xdhost="localhost"

 )
 Begin {
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
     #param validation
     if ($mctype -eq "dedicated")
     {
        if([string]::IsNullOrEmpty($machine))
        {
            throw "MACHINE must be populated for dedicated deployment"
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
        if ($PSCmdlet.ShouldProcess("Remove dedicated desktop")) {
            #call remove desktop function and pass machine
            $desktop = Get-Brokermachine -machinename $machine -adminaddress $xdhost -erroraction stop
            if(Test-XDBrokerCatalog -machinecat $desktop.CatalogName -xdhost $xdhost -mctype "dedicated")
            {
            remove-xddesktop $desktop $xdhost|write-verbose
            }
            else {
                throw "Machine catalog does not fit criteria"
            }
        }
     }
    else {
        test-xdvariable -dgroup $dgroup -xdhost $xdhost
        #Get all machines and get the ones we want to remove
        $accts = Get-Brokermachine -DesktopGroupName $dgroup -adminaddress $xdhost|Sort-Object hostedmachinename|Select-Object -Last $howmany   
        if ($PSCmdlet.ShouldProcess("Removing pooled desktops")) {
            if(Test-XDBrokerCatalog -machinecat $accts[0].CatalogName -xdhost $xdhost -mctype "pooled")
            {
            #call remove desktop function and pass machine names
            remove-xddesktop $accts $xdhost|write-verbose
            #Gets identity pool to reset start count
            $identPool = Get-AcctIdentityPool -IdentityPoolName ($accts[0].CatalogName) -adminaddress $xdhost
            write-verbose "Adjusting start count for identity pool"
            Set-AcctIdentityPool -IdentityPoolName ($accts[0].CatalogName) -StartCount ($identPool.startcount - $Howmany) -adminaddress $xdhost|write-verbose
            }
            else {
                throw "Machine catalog does not fit criteria"
            }
        }
    }
 }
 end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
 }