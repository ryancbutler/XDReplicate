function Import-XDDesktop
{
<#
.SYNOPSIS
    Creates desktops from exported object
.DESCRIPTION
    Creates desktops from exported object
.PARAMETER DESKTOP
    Desktop to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
    $XDEXPORT.desktops|import-xddesktop
    Creates desktops from imported desktop object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$desktop,
[Parameter(Mandatory=$true)][string]$xdhost
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"

}
    Process
    {
        $dgmatch = Get-BrokerDesktopGroup -name $desktop.dgname -AdminAddress $xdhost
        Write-host "Setting Entitlements"
        Set-XDAppEntitlement $dgmatch $xdhost
    
                if($desktop)
                {

                    write-verbose "Proccessing Desktop $($desktop.name)"
                    $desktopmatch = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid -Name $desktop.Name -ErrorAction SilentlyContinue
                        if($desktopmatch)
                        {
                        write-verbose "Setting desktop"
                        Set-XDDesktopobject $desktop $xdhost
                        clear-XDDesktopUserPerm $desktopmatch $xdhost
                        set-XDUserPerm $desktop $xdhost
                        }
                        else
                        {
                        write-verbose "Creating Desktop"
                        $desktopmatch = New-XDDesktopobject $desktop $xdhost $dgmatch.Uid
                        set-XDUserPerm $desktop $xdhost
                        }

                    
                }
    return $desktopmatch
    }
    end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}   