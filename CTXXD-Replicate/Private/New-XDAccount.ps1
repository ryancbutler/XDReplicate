function new-xdaccount
{
<#
.SYNOPSIS
   Internal function to  create AD accounts for XD
.DESCRIPTION
   Internal function to  create AD accounts for XD
.PARAMETER howmany
   How many computer accounts to create
.PARAMETER machinecat
   Machine catalog to create accounts
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
param(
[Parameter(Mandatory=$true)]$howmany,
[Parameter(Mandatory=$true)]$machinecat,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
    if ($PSCmdlet.ShouldProcess("Create new MC accounts")) 
    {
        $adaccounts = Get-AcctADAccount -IdentityPoolName $machinecat -adminaddress $xdhost|Where-Object{$_.state -like "Available"}
        if ($adaccounts -is [object])
        {
            $stillneeded = $howmany - $adaccounts.count
        }
        else
        {
            $stillneeded = $howmany
        }

            if ($stillneeded -ge 1)
            {
                Write-Verbose "Need $stillneeded accounts"
                $creates = New-AcctADAccount -Count $stillneeded -IdentityPoolName $machinecat -adminaddress $xdhost
                Write-Verbose "waiting for accounts to be created.."
                Start-Sleep -Seconds 10
                    if ($creates.FailedAccountsCount -gt 1)
                    {
                        throw "Account creation failed.  Check permissions"
                    }              
                    else
                    {
                        $stillneeded = $howmany
                    }

            return $stillneeded
            }
        
    }
}
