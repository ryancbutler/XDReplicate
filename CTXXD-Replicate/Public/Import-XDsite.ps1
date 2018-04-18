function Import-XDSite
{
<#
.SYNOPSIS
    Imports XD site information from object
.DESCRIPTION
    Imports XD site information from object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER XMLPATH
   Path used for XML file location on import and export operations
.PARAMETER XDEXPORT
    XD site object to import
.PARAMETER IGNOREENABLE
    Ignores setting the Enable flag on apps and desktops
.EXAMPLE
   $exportedobject|Import-XDSite -xdhost DDC02.DOMAIN.COM
   Imports data to DDC02.DOMAIN.COM and returns as object
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xmlpath "C:\temp\mypath.xml"
   Imports data to DDC02.DOMAIN.COM from XML file C:\temp\mypath.xml
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xdexport $myexport
   Imports data to DDC02.DOMAIN.COM from variable $myexport
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xdexport $myexport -ignoreenable
   Imports data to DDC02.DOMAIN.COM from variable $myexport and does not change any existing disable\enable settings for applications and desktops
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='High')]
Param (
    [Parameter(Mandatory=$false)][string]$xdhost="localhost",
    [Parameter(Mandatory=$false)][String]$xmlpath,
    [Parameter(ValueFromPipeline=$true)]$xdexport,
    [Parameter(Mandatory=$false)][switch]$ignoreenable)
  
begin{
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)" 
    #Checks for Snappins
    Test-XDmodule
    if(-not ([string]::IsNullOrWhiteSpace($xmlpath)))
    {
        if(Test-Path $xmlpath)
        {
            $xdexport = Import-Clixml $xmlpath
        }
        else {
            throw "XML file not found"
        }
    }
}

process 
    {

    if (!($XDEXPORT))
    {
    throw "Nothing to import"
    }
    
        if ($PSCmdlet.ShouldProcess("Import Site")) 
        { 
        
        if($XDEXPORT.tags)
        {
        write-verbose "Proccessing Tags"
        $XDEXPORT.tags|import-xdtag -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
        }
       
        if($XDEXPORT.dgs)
        {
        write-verbose "Proccessing Delivery Groups"
        $XDEXPORT.dgs|import-xddeliverygroup -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null      
        }
        
        if($XDEXPORT.desktops)
        {
        Write-Verbose "Processing Desktops"
        $XDEXPORT.desktops|import-xddesktop -xdhost $xdhost -ignoreenable:$ignoreenable -Verbose:$VerbosePreference|Out-Null
        }

        if($XDEXPORT.appgroups)
        {
        Write-Verbose "Processing App Groups"
        $XDEXPORT.appgroups|import-xdapplicationgroup -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
        }

        if($XDEXPORT.apps)
        {
        Write-Verbose "Processing Apps"
        $XDEXPORT.apps|import-xdapp -xdhost $xdhost -ignoreenable:$ignoreenable -Verbose:$VerbosePreference|Out-Null
        }
        
        if($XDEXPORT.adminroles)
        {
        write-verbose "Processing Admin Roles"
        $XDEXPORT.adminroles|import-xdadminrole -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
        }

        if($XDEXPORT.admins)
        {
        write-verbose "Processing admins"
        $XDEXPORT.admins|import-xdadmin -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
        }

    }
}
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}
