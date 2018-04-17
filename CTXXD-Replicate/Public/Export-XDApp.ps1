 function Export-XDApp
 {
<#
.SYNOPSIS
    Adds required import values to existing exported app object
.DESCRIPTION
    Adds required import values to existing exported app object
.PARAMETER app
    Application Object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
   $apps = Get-BrokerApplication -AdminAddress $xdhost|export-xdapp
   Grabs all applications and adds required values to object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$app,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
 process {
        
    if($app)
        {
         Write-Verbose "Processing $($app.ApplicationName)"
        
         #multi dg or ag flag
         $multi = $false
         #Icon data
         $BrokerEnCodedIconData = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($app.IconUid)).EncodedIconData
         $app|add-member -NotePropertyName 'EncodedIconData' -NotePropertyValue $BrokerEnCodedIconData
         #Adds delivery group name to object
         if(($app.AssociatedDesktopGroupUids).count -gt 1)
         {
             $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue ($app|export-xdappdg -xdhost $xdhost)
             $multi = $true
         }
         elseif (($app.AssociatedDesktopGroupUids).count -eq 1) {
             
            $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue (get-brokerdesktopgroup -adminaddress $xdhost -Uid $app.AssociatedDesktopGroupUids[0]).name 
         }
         else{
            $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $null
            $multi = $true  
         }
         

         if(($app.AssociatedApplicationGroupUids).count -gt 0)
         {
             $app|add-member -NotePropertyName 'AGNAME' -NotePropertyValue ($app|export-xdappag -xdhost $xdhost)
             $multi = $true
         }
         else {
            $app|add-member -NotePropertyName 'AGNAME' -NotePropertyValue $null
         }

         #adds multi flag value
         $app|add-member -NotePropertyName 'multi' -NotePropertyValue $multi

         #File type associations
         $ftatemp = @()
         Get-BrokerConfiguredFTA -AdminAddress $xdhost -ApplicationUid $app.Uid | ForEach-Object -Process {
         $ftatemp += $_
         $ftatemp|Out-Null #workaround for script analyzer
         }
     
         if($ftatemp.count -gt 0)
         {
         $app|add-member -NotePropertyName "FTA" -NotePropertyValue $ftatemp
         }

 
        return $app
        }
     }    
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}
