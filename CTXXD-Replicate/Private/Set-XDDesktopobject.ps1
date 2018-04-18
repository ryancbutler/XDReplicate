function Set-XDDesktopobject 
{
<#
.SYNOPSIS
    Sets existing desktop entitlement settings from desktop object
.DESCRIPTION
    Sets existing desktop entitlement settings from desktop object
.PARAMETER Desktop
    Exported Desktop
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER IGNOREENABLE
    Ignores setting the Enable flag
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param (
[Parameter(Mandatory=$true)]$desktop, 
[Parameter(Mandatory=$true)][string]$xdhost,
[Parameter(Mandatory=$false)][switch]$ignoreenable)

Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
$temp = @{}
foreach($t in $desktop.PSObject.Properties)
    {
          
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
            switch ($t.name)
            {
                "Name" {$temp.Add("name",$t.value)}
                "ColorDepth" {$temp.Add("ColorDepth",$t.value)}
                "Description" {$temp.Add("Description",$t.value)}
                "Enabled" {
                    if(!$ignoreenable)
                    {
                    $temp.Add("Enabled",$t.value)
                    }
                    else {
                        Write-Verbose "Skipping Enable"
                    }
                }
                "LeasingBehavior" {$temp.Add("LeasingBehavior",$t.value)}
                "PublishedName" {$temp.Add("PublishedName",$t.value)}
                "RestrictToTag" {$temp.Add("RestrictToTag",$t.value)}
                "SecureIcaRequired" {$temp.Add("SecureIcaRequired",$t.value)}
                "SessionReconnection" {$temp.Add("SessionReconnection",$t.value)}
               
            }
         }
    }
    if ($PSCmdlet.ShouldProcess("Setting Broker Entitlement")) {
        try {
        $tempvar = Set-BrokerEntitlementPolicyRule @temp -adminaddress $xdhost
        }
        catch {
            throw $_
        }
    }
    return $tempvar
    Write-Verbose "END: $($MyInvocation.MyCommand)"
}
