function remove-xddesktopded {
<#
.SYNOPSIS
   Removes user dedciated desktop from given delivery group
.DESCRIPTION
   Removes user dedciated desktop from given delivery group
.PARAMETER desktop
   Delivery group to query from
.EXAMPLE
   remove-xddesktopded -desktop "MYDOMAIN\MYVDI01"
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param($desktop)
    
    if ($PSCmdlet.ShouldProcess("Remove static desktop")) {
        #call remove desktop function and pass machine
        $desktop = Get-Brokermachine -machinename $desktop -erroraction stop
		remove-xddesktop $desktop
    }
}
