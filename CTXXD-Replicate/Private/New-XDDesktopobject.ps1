function New-XDDesktopobject 
{
<#
.SYNOPSIS
    Creates new Desktop entitlement policy from object
.DESCRIPTION
    Creates new Desktop entitlement policy from object
.PARAMETER Desktop
    New desktop object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER DGUID
    Delivery group UID to create desktop
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true)]$desktop, 
[Parameter(Mandatory=$true)][string]$xdhost, 
[Parameter(Mandatory=$true)][string]$dguid)

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
                "Enabled" {$temp.Add("Enabled",$t.value)}
                "IncludedUserFilterEnabled" {$temp.Add("IncludedUserFilterEnabled",$t.value)}
                "LeasingBehavior" {$temp.Add("-LeasingBehavior",$t.value)}
                "PublishedName" {$temp.Add("PublishedName",$t.value)}
                "RestrictToTag" {$temp.Add("RestrictToTag",$t.value)}
                "SecureIcaRequired" {$temp.Add("SecureIcaRequired",$t.value)}

                #"SessionReconnection" {$tempstring = " -SessionReconnection `"$($t.value)`""} Fails for LTSR
               
            }
           }
    }
    if ($PSCmdlet.ShouldProcess("Creating Entitlement Policy")) {    
        try {
        $tempvarapp = New-BrokerEntitlementPolicyRule @temp -adminaddress $xdhost -DesktopGroupUid $dguid -Verbose:$VerbosePreference
        }
        catch {
            throw $_
        }
    }
    return $tempvarapp
    Write-Verbose "END: $($MyInvocation.MyCommand)"
}
