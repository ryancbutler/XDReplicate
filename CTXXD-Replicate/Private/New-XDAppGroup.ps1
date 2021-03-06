function New-XDappgroup
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
[Parameter(Mandatory=$true)][string]$xdhost 
)

Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
$temp = @{}
foreach($t in $appgroup.PSObject.Properties)
    {       
        if(-not ([string]::IsNullOrWhiteSpace($t.Value)))
        {

            switch ($t.name)
            {
                "Name" {$temp.Add("name",$t.value)}
                "Description" {$temp.Add("Description",$t.value)}
                "Enabled" {$temp.Add("Enabled",$t.value)}
                "RestrictToTag" {$temp.Add("RestrictToTag",$t.value)}
                #"Scopes" {$temp.Add("Scope",$t.value)}
                "SessionSharingEnabled"{$temp.Add("SessionSharingEnabled",$t.value)}
                "UserFilterEnabled" {$temp.Add("UserFilterEnabled",$t.value)}
           
            }

         }
    }

if ($PSCmdlet.ShouldProcess("Creating Application Group")) {    
    try {
    $tempvar = New-BrokerApplicationGroup @temp -adminaddress $xdhost -Verbose:$VerbosePreference
    }
    catch {
        throw $_
    }
}
return $tempvar
Write-Verbose "END: $($MyInvocation.MyCommand)"
}