function New-XDappobject 
{
<#
.SYNOPSIS
    Creates broker application from exported object
.DESCRIPTION
    Creates broker application from exported object
.PARAMETER APP
    Broker Application to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER DGMATCH
    Delivery group to create application

#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true)]$app,
[Parameter(Mandatory=$true)][string]$xdhost, 
[Parameter(Mandatory=$true)][string]$dgmatch
)

$temp = @{}
foreach($t in $app.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {

            switch ($t.name)
            {
                "AdminFolderName" {$temp.Add("AdminFolder",$t.value)}
                "ApplicationGroup" {$temp.Add("ApplicationGroup",$t.value)}
                "ApplicationType" {$temp.Add("ApplicationType",$t.value)}
                "BrowserName" {$temp.Add("BrowserName",$t.value)}
                "ClientFolder" {$temp.Add("ClientFolder",$t.value)}
                "CommandLineArguments" {$temp.Add("CommandLineArguments",$t.value) }
                "CommandLineExecutable" {$temp.Add("CommandLineExecutable",$t.value)}
                "CpuPriorityLevel" {$temp.Add("CpuPriorityLevel",$t.value)}
                "DesktopGroup" {$temp.Add("DesktopGroup",$t.value)}
                "Description" {$temp.Add("Description",$t.value)}
                "Enabled" {$temp.Add("Enabled",$t.value)}
                "MaxPerUserInstances" {$temp.Add("MaxPerUserInstances",$t.value)}
                "MaxTotalInstances" {$temp.Add("MaxTotalInstances",$t.value)}
                "Name" {$temp.Add("name",$app.applicationname)}
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

if ($PSCmdlet.ShouldProcess("Creating Published App")) {    
    try {
    $tempvarapp = New-BrokerApplication @temp -adminaddress $xdhost -DesktopGroup $dgmatch -Verbose:$VerbosePreference
    }
    catch {
        throw $_
    }
}
return $tempvarapp
}
