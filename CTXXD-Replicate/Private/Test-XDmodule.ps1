function Test-XDmodule
{
<#
.SYNOPSIS
    Tests for Citrix Snapins and imports if missing
.DESCRIPTION
    Tests for Citrix Snapins and imports if missing
#>
    [CmdletBinding()]
    Param ()
    Write-Verbose "Checking for Citrix Snapins"
     if ((Get-PSSnapin Citrix*) -eq $null)
     {
        throw "Please load Citrix Snapins Before running"
     }
     else
     {
        Write-Verbose "Found snapins"
     }
    
}