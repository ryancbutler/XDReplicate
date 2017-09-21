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

begin{
Write-Verbose "$($MyInvocation.MyCommand): Enter"
}
process{

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
                    #"Scopes" {$temp.Add("Scope",$t.value)}
                    "SessionSharingEnabled"{$temp.Add("SessionSharingEnabled",$t.value)}
                    "UserFilterEnabled" {$temp.Add("UserFilterEnabled",$t.value)}
            
                }

            }
        }

    if ($PSCmdlet.ShouldProcess("Setting Application Group $($appgroupmatch.name)")) {    
        try {
        Set-BrokerApplicationGroup @temp -adminaddress $xdhost -Verbose:$VerbosePreference -name $appgroupmatch.name|out-null
        }
        catch {
            throw $_
        }
    }
    }
    end{Write-Verbose "$($MyInvocation.MyCommand): Exit"}
}
