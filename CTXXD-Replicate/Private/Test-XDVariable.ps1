function test-xdvariable
{
<#
.SYNOPSIS
   Internal function to test machine catalog and delivery group
.DESCRIPTION
   Internal function to test machine catalog and delivery group
.PARAMETER dgroup
   Delivery Group to test
.PARAMETER machinecat
   Machine catalog to test
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory=$false)][string]$dgroup,
    [Parameter(Mandatory=$false)][string]$machinecat,
    [Parameter(Mandatory=$true)][string]$xdhost
    
)
    if(-not ([string]::IsNullOrWhiteSpace($dgroup)))
    {
        try{
            Write-Verbose "Checking for Desktop Group $dgroup"
            Get-BrokerDesktopGroup -name $dgroup -adminaddress $xdhost -ErrorAction stop|out-null
        }
        catch{
            throw "Problem locating delivery group $($dgroup). Please check name and try again"
        }

    }

    if(-not ([string]::IsNullOrWhiteSpace($machinecat)))
    {
        try{
            Write-Verbose "Checking for Machine Catalog $machinecat"
            Get-BrokerCatalog -name $machinecat -adminaddress $xdhost -ErrorAction stop|Out-null
        }
        Catch{
            throw "Problem locating machine catalog $machinecat. Please check name and try again"
        }
    }

#return $true
}