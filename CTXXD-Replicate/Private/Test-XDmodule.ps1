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
    Write-Verbose "Checing for Citrix Snapins"
    if ( (Get-PSSnapin -Name Citrix* -ErrorAction SilentlyContinue) -eq $null )
    {
        try{
        Add-PsSnapin Citrix*
        }
        catch
        {
            $_
        }
    }
}