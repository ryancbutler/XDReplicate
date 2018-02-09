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
    [Parameter(Mandatory=$false)][string]$machinecat
    
)
    if(-not ([string]::IsNullOrWhiteSpace($dgroup)))
    {
        try{
            Get-BrokerDesktopGroup -name $dgroup -ErrorAction Stop|Out-Null
        }
        catch{
            throw "Problem locating delivery group $dgroup. Please check name and try again"
        }

    }

    if(-not ([string]::IsNullOrWhiteSpace($machinecat)))
    {
        try{
            Get-BrokerCatalog -name $machinecat -ErrorAction Stop|Out-Null
        }
        Catch{
            throw "Problem locating machine catalog $machinecat. Please check name and try again"
        }
    }

return $true
}