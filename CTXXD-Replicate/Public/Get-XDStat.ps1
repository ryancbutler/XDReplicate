function get-xdstat {
<#
.SYNOPSIS
   Gets Desktop machine of user and returns status
.DESCRIPTION
   Gets Desktop machine of user and returns status
.PARAMETER desktop
   Desktop to query
#>
[cmdletbinding()]
[OutputType([string])]
param($desktop)

    $desktop = Get-BrokerMachine -Uid $desktop.uid

    $statusstr = "*Machine Name:* $($desktop.HostedMachineName)`n*IP:* $($desktop.IPAddress)`n*Registration State:* $($desktop.RegistrationState)`n*Host:* $($desktop.HostingServerName)`n*Power State:* $($desktop.powerstate)"

    return $statusstr
}
