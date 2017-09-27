function Export-XDDesktop
{
<#
.SYNOPSIS
    Adds Delivery group names to Desktop Object
.DESCRIPTION
    Adds Delivery group names to Desktop Object
.PARAMETER desktop
    Exported desktop object
.PARAMETER DG
    Delivery group where desktop resides
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
    $dg = get-brokerdesktopgroup -name "My Delivery Group"
    $desktops = Get-BrokerEntitlementPolicyRule|Export-XDdesktop -xdhost $xdhost -dg $dg
    Grabs all desktops and adds required values to object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$desktop,
[Parameter(Mandatory=$true)][object]$dg,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
begin {
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)" 
}
  
    process{
        if($desktop -is [object])
        {
        Write-Verbose "Processing $($desktop.Name)"
        #Adds delivery group name to object
        $desktop|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
        return $desktop
        }
    }
    end{Write-Verbose "END: $($MyInvocation.MyCommand)"}    
}