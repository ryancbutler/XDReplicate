 function export-xdapp
 {
 #Grabs APP inf
 if(-not ([string]::IsNullOrWhiteSpace($apptag)))
 {
     #App argument doesn't exist for LTSR.  Guessing 7.11 is the first to support
     if ([version]$ddcver -lt "7.11")
     {
         write-warning "Ignoring APP TAG ARGUMENTS."
         $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000
     }
     else {
         $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -Tag $apptag -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoreapptag}
     }
 
 }
 else
 {
     if ([version]$ddcver -lt "7.11")
     {
     $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000  
     
     }
     else {
     $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID -MaxRecordCount 2000|Where-Object{$_.Tags -notcontains $ignoreapptag}
     }
 }

 
 if($apps -is [object])
 {   
     foreach ($app in $apps)
     {
         Write-Verbose "Processing $($app.ApplicationName)"

         #Icon data
         $BrokerEnCodedIconData = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($app.IconUid)).EncodedIconData
         $app|add-member -NotePropertyName 'EncodedIconData' -NotePropertyValue $BrokerEnCodedIconData
         #Adds delivery group name to object
         if(($app.AssociatedDesktopGroupUids).count -gt 1)
         {
             $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue ($app|export-xdappdg -xdhost $xdhost)
         }
         else
         {
             $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
         }

         if(($app.AssociatedApplicationGroupUids).count -gt 0)
         {
             $app|add-member -NotePropertyName 'AGNAME' -NotePropertyValue ($app|export-xdappag -xdhost $xdhost)
         }

         #File type associations
         $ftatemp = @()
         Get-BrokerConfiguredFTA -AdminAddress $xdhost -ApplicationUid $app.Uid | ForEach-Object -Process {
         $ftatemp += $_
         }
     
         if($ftatemp.count -gt 0)
         {
         $app|add-member -NotePropertyName "FTA" -NotePropertyValue $ftatemp
         }
 
     $appobject += $app
     }    
 }
}