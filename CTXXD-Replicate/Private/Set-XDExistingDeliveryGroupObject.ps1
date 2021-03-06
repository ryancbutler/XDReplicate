function Set-XDExistingDeliveryGroupObject
{
<#
.SYNOPSIS
    Creats existing delivery group from object
.DESCRIPTION
    Creats existing delivery group from object
.PARAMETER DG
    Delivery Group object to be created
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param (
[Parameter(Mandatory=$true)]$dg,
[Parameter(Mandatory=$true)][string]$xdhost
)

Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
$temp = @{}
foreach($t in $dg.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
            switch ($t.name)
            {
            "Name" {$temp.Add("Name",$t.value)}
            "AutomaticPowerOnForAssigned" {$temp.Add("AutomaticPowerOnForAssigned",$t.value)}
            "AutomaticPowerOnForAssignedDuringPeak" {$temp.Add("AutomaticPowerOnForAssignedDuringPeak",$t.value)}
            "ColorDepth" {$temp.Add("ColorDepth",$t.value)}
            "DeliveryType" {$temp.Add("DeliveryType",$t.value)}
            "Description" {$temp.Add("Description",$t.value)}
            "Enabled" {$temp.Add("Enabled",$t.value)}
            "InMaintenanceMode" {$temp.Add("InMaintenanceMode",$t.value)}
            "IsRemotePC" {$temp.Add("IsRemotePC",$t.value)}
            "MinimumFunctionalLevel" {$temp.Add("MinimumFunctionalLevel",$t.value)}
            "OffPeakBufferSizePercent" {$temp.Add("OffPeakBufferSizePercent",$t.value)}
            "OffPeakDisconnectAction" {$temp.Add("OffPeakDisconnectAction",$t.value)}
            "OffPeakDisconnectTimeout" {$temp.Add("OffPeakDisconnectTimeout",$t.value)}
            "OffPeakExtendedDisconnectAction" {$temp.Add("OffPeakExtendedDisconnectAction",$t.value)}
            "OffPeakExtendedDisconnectTimeout" {$temp.Add("OffPeakExtendedDisconnectTimeout",$t.value)}
            "OffPeakLogOffAction" {$temp.Add("OffPeakLogOffAction",$t.value)}
            "OffPeakLogOffTimeout" {$temp.Add("OffPeakLogOffTimeout",$t.value)}
            "PeakBufferSizePercent" {$temp.Add("PeakBufferSizePercent",$t.value)}
            "PeakDisconnectAction" {$temp.Add("PeakDisconnectAction",$t.value)}
            "PeakDisconnectTimeout" {$temp.Add("PeakDisconnectTimeout",$t.value)}
            "PeakExtendedDisconnectAction" {$temp.Add("PeakExtendedDisconnectAction",$t.value)}
            "PeakExtendedDisconnectTimeout" {$temp.Add("PeakExtendedDisconnectTimeout",$t.value)}
            "PeakLogOffAction" {$temp.Add("PeakLogOffAction",$t.value)}
            "ProtocolPriority" {$temp.Add("ProtocolPriority",$t.value)}
            "PublishedName" {$temp.Add("PublishedName",$t.value)}
            "SecureIcaRequired" {$temp.Add("SecureIcaRequired",$t.value)}
            "ShutdownDesktopsAfterUse" {$temp.Add("ShutdownDesktopsAfterUse",$t.value)}
            "TimeZone" {$temp.Add("TimeZone",$t.value)}
            "TurnOnAddedMachine" {$temp.Add("TurnOnAddedMachine",$t.value)}
            }
             
         }
    }
    if ($PSCmdlet.ShouldProcess("Setting Desktop Group")) {    
        try {
        $tempreturn = Set-BrokerDesktopGroup @temp -adminaddress $xdhost -Verbose:$VerbosePreference
        }
        catch {
            throw $_
        }
    }
    return $tempreturn
    Write-Verbose "END: $($MyInvocation.MyCommand)"
}
