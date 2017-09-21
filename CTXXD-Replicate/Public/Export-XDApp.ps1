 function export-xdapp
 {
<#
.SYNOPSIS
    Adds Application settings to app object
.DESCRIPTION
    Adds Application settings to app object
.PARAMETER app
    Application Object
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$app,
[Parameter(Mandatory=$false)][string]$xdhost="localhost"
)
begin{
Write-Verbose "$($MyInvocation.MyCommand): Enter"
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
         if(($app.AssociatedDesktopGroupUids).count -gt 0)
         {
             $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue ($app|export-xdappdg -xdhost $xdhost)
             $multi = $true
         }
         else {
            $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $null 
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
         }
     
         if($ftatemp.count -gt 0)
         {
         $app|add-member -NotePropertyName "FTA" -NotePropertyValue $ftatemp
         }

 
        return $app
        }
     }    
end{Write-Verbose "$($MyInvocation.MyCommand): Exit"}
}
