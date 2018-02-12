function Test-XDBrokerCatalog
{
<#
.SYNOPSIS
    Tests to see if broker group fits deployment type
.DESCRIPTION
    Tests to see if broker group fits deployment type
.PARAMETER broe
    Newly created application
.PARAMETER APPMATCH
    Existing application
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to

#>
[CmdletBinding()]
[OutputType([System.boolean])]
Param (
    [Parameter(Mandatory=$true,Position=0)]$machinecat, 
    [Parameter(Mandatory=$true,Position=1,HelpMessage="Machine Catalog type (Dedicated Or Pooled)")]
    [ValidateSet("Dedicated","Pooled")]
    [string]$mctype,
    [Parameter(Mandatory=$true,Position=2)][string]$xdhost
    )

    
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
    $machinecat = get-brokercatalog -name $machinecat -adminaddress $xdhost
    if ($machinecat.ProvisioningType -ne "MCS")
    {
        Write-Warning "Machine Catalog must be MCS"
        $test = $false
    }
    else {
        if ($mctype -eq "dedicated")
        {
            if ($machinecat.AllocationType -eq "Static")
            {
                Write-Verbose "Static catalog found"
                $test = $true
            }
            else {
                Write-warning "Static catalog NOT found"
                $test = $false
            }
   
        }
       else {

        if ($machinecat.AllocationType -eq "Random")
            {
                Write-Verbose "Random catalog found"
                $test = $true
            }
            else {
                Write-warning "Random catalog NOT found"
                $test = $false
            }
   
       }
    }

return $test
Write-Verbose "END: $($MyInvocation.MyCommand)"
}