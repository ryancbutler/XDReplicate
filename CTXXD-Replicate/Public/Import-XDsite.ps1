function Import-XDsite
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
.EXAMPLE
   $exportedobject|Import-XDSite -xdhost DDC02.DOMAIN.COM
   Imports data to DDC02.DOMAIN.COM and returns as object
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xmlpath "C:\temp\mypath.xml"
   Imports data to DDC02.DOMAIN.COM from XML file C:\temp\mypath.xml
.EXAMPLE
   Import-XDSite -xdhost DDC02.DOMAIN.COM -xdexport $myexport
   Imports data to DDC02.DOMAIN.COM from variable $myexport
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='High')]
Param (
    [Parameter(Mandatory=$false)][string]$xdhost="localhost",
    [Parameter(Mandatory=$false)][String]$xmlpath,
    [Parameter(ValueFromPipeline=$true)]$xdexport)
  
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
        
        write-verbose "Proccessing Tags"
        $XDEXPORT.tags|import-xdtag -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
       
        write-verbose "Proccessing Delivery Groups"
        $XDEXPORT.dgs|import-xddeliverygroup -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null      
            
        Write-Verbose "Processing Desktops"
        $XDEXPORT.desktops|import-xddesktop -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
        
        Write-Verbose "Processing App Groups"
        $XDEXPORT.appgroups|import-xdapplicationgroup -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null

        Write-Verbose "Processing Apps"
        $XDEXPORT.apps|import-xdapp -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null
        
        write-verbose "Processing Admin Roles"
        $XDEXPORT.adminroles|import-xdadminrole -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null

        write-verbose "Processing admins"
        $XDEXPORT.admins|import-xdadmin -xdhost $xdhost -Verbose:$VerbosePreference|Out-Null

    }
}
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}