function Set-XDappgroup
{
<#
.SYNOPSIS
    Creates broker application group from exported object
.DESCRIPTION
    Creates broker application group from exported object
.PARAMETER APPGROUP
    Broker Application Group to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to


#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
Param(
[Parameter(Mandatory=$true)]$appgroup,
[Parameter(Mandatory=$true)]$appgroupmatch,
[Parameter(Mandatory=$true)][string]$xdhost 
)

$temp = @{}
foreach($t in $appgroup.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {

            switch ($t.name)
            {
                "Description" {$temp.Add("Description",$t.value)}
                "Enabled" {$temp.Add("Enabled",$t.value)}
                "RestrictToTag" {$temp.Add("RestrictToTag",$t.value)}
                "Scopes" {$temp.Add("Scope",$t.value)}
                "SessionSharingEnabled"{$temp.Add("Scope",$t.value)}
                "UserFilterEnabled" {$temp.Add("UserFilterEnabled",$t.value)}
           
            }

         }
    }

if ($PSCmdlet.ShouldProcess("Creating Application Group")) {    
    try {
    $tempvar = Set-BrokerApplicationGroup @temp -adminaddress $xdhost -Verbose:$VerbosePreference -name $appgroupmatch.name
    }
    catch {
        throw $_
    }
}
#return $tempvar
}