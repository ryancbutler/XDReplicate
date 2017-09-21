function Export-XDdesktop
{
<#
.SYNOPSIS
    Adds Delivery group names to Desktop Object
.DESCRIPTION
    Adds Delivery group names to Desktop Object
.PARAMETER desktop
    desktop
.PARAMETER DG
    Delivery group where desktop resides
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$desktop,
[Parameter(Mandatory=$true)]$dg,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
begin {
    Write-Verbose "$($MyInvocation.MyCommand): Enter" 
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
    end{Write-Verbose "$($MyInvocation.MyCommand): Exit"}    
}