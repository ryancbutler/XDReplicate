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
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true)]$app,
[Parameter(Mandatory=$true)]$appmatch, 
[Parameter(Mandatory=$true)][string]$xdhost)
$temp = @{}
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {
            switch ($t.name)
            {
                "ClientFolder" {$temp.Add("ClientFolder",$t.value)}
                "CommandLineArguments" {$temp.Add("CommandLineArguments",$t.value)}
                "CommandLineExecutable" {$temp.Add("CommandLineExecutable",$t.value)}
                "CpuPriorityLevel" {$temp.Add("CpuPriorityLevel",$t.value)}
                "Description" {$temp.Add("Description",$t.value)}
                "Enabled" {$temp.Add("Enabled",$t.value)}
                "MaxPerUserInstances" {$temp.Add("MaxPerUserInstances",$t.value)}
                "MaxTotalInstances" {$temp.Add("MaxTotalInstances",$t.value)}
                "Name" {$temp.Add("name",$appmatch.Name)}
                "Priority" {$temp.Add("Priority",$t.value)}
                "PublishedName" {$temp.Add("PublishedName",$t.value)}
                "SecureCmdLineArgumentsEnabled" {$temp.Add("SecureCmdLineArgumentsEnabled",$t.value)}
                "ShortcutAddedToDesktop" {$temp.Add("ShortcutAddedToDesktop",$t.value)}
                "ShortcutAddedToStartMenu" {$temp.Add("ShortcutAddedToStartMenu",$t.value)}
                "StartMenuFolder" {$temp.Add("StartMenuFolder",$t.value)}
                "UserFilterEnabled" {$temp.Add("UserFilterEnabled",$t.value)}
                "Visible" {$temp.Add("Visible",$t.value)}
                "WaitForPrinterCreation" {$temp.Add("WaitForPrinterCreation",$t.value)}
                "WorkingDirectory" {$temp.Add("WorkingDirectory",$t.value)}
            }
         }
    }
    if ($PSCmdlet.ShouldProcess("Setting Existing App")) {    
        try {
        $tempvar = Set-BrokerApplication @temp -adminaddress $xdhost -Verbose:$VerbosePreference
        }
        catch {
            throw $_
        }
    }
    return $tempvar
}
