function Set-XDexistingappobject 
{
<#
.SYNOPSIS
    Sets an existing broker application settings
.DESCRIPTION
    Script block to set an application is returned to be piped to invoke-command
.PARAMETER APP
    Exported aplication
.PARAMETER APPMATCH
    Existing application
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]$app,
[Parameter(Mandatory=$true)]$appmatch, 
[Parameter(Mandatory=$true)][string]$xdhost)

$tempvarapp = "Set-BrokerApplication -adminaddress $($xdhost)"
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
        $tempstring = ""
            switch ($t.name)
            {
                "ClientFolder" {$tempstring = " -ClientFolder `"$($t.value)`""}
                #"CommandLineArguments" {$tempstring = " -CommandLineArguments `"$($t.value)`"" }
                "CommandLineArguments" {$tempstring = " -CommandLineArguments '{0}'" -f $t.value }
                "CommandLineExecutable" {$tempstring = " -CommandLineExecutable `"$($t.value)`""}
                "CpuPriorityLevel" {$tempstring = " -CpuPriorityLevel `"$($t.value)`""}
                "Description" {$tempstring = " -Description `"$($t.value)`""}
                "Enabled" {$tempstring = " -Enabled `$$($t.value)"}
                "MaxPerUserInstances" {$tempstring = " -MaxPerUserInstances `"$($t.value)`""}
                "MaxTotalInstances" {$tempstring = " -MaxTotalInstances `"$($t.value)`""}
                "Name" {$tempstring = " -name `"$($appmatch.Name)`""}
                "Priority" {$tempstring = " -Priority `"$($t.value)`""}
                "PublishedName" {$tempstring = " -PublishedName `"$($t.value)`""}
                "SecureCmdLineArgumentsEnabled" {$tempstring = " -SecureCmdLineArgumentsEnabled `$$($t.value)"}
                "ShortcutAddedToDesktop" {$tempstring = " -ShortcutAddedToDesktop `$$($t.value)"}
                "ShortcutAddedToStartMenu" {$tempstring = " -ShortcutAddedToStartMenu `$$($t.value)"}
                "StartMenuFolder" {$tempstring = " -StartMenuFolder `"$($t.value)`""}
                "UserFilterEnabled" {$tempstring = " -UserFilterEnabled `$$($t.value)"}
                "Visible" {$tempstring = " -Visible `$$($t.value)"}
                "WaitForPrinterCreation" {$tempstring = " -WaitForPrinterCreation `$$($t.value)"}
                "WorkingDirectory" {$tempstring = " -WorkingDirectory `"$($t.value)`""}
            }
         $tempvarapp = $tempvarapp +  $tempstring
         }
    }
return $tempvarapp
}
