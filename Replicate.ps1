
CLS
$ExportFolder = "C:\Temp"
$tag = "replicate"


$DesktopGroups = Get-BrokerDesktopGroup -AdminAddress localhost -tag $tag
$foundapps = @()

foreach ($DG in $DesktopGroups)
{
    write-host $DG.Name
  
    $apps = Get-BrokerApplication -AdminAddress localhost -AssociatedDesktopGroupUUID $dg.UUID
    
    if($apps)
    {
        foreach ($app in $apps)
        {
            Write-Host "Processing $($app.ApplicationName)"

            $app|add-member -NotePropertyName 'ResourceType' -NotePropertyValue "PublishedApp"

            $BrokerEnCodedIconData = (Get-BrokerIcon -AdminAddress localhost -Uid ($app.IconUid)).EncodedIconData
            $app|add-member -NotePropertyName 'EncodedIconData' -NotePropertyValue $BrokerEnCodedIconData
        
            $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
    
            Get-BrokerConfiguredFTA -AdminAddress localhost -ApplicationUid $app.Uid | ForEach-Object -Process {
                $FTAUid = "FTA-" + "$($_.Uid)"
                $app|add-member -NotePropertyName $FTAUid -NotePropertyValue $_
            }
        $foundapps += $app
        }
    }

    $desktops = Get-BrokerEntitlementPolicyRule -AdminAddress localhost -DesktopGroupUid $dg.Uid 

    if($desktops)
    {
        foreach ($desktop in $desktops)
        {
           Write-Host "Processing $($desktop.PublishedName)"
            
           $desktop|add-member -NotePropertyName 'ResourceType' -NotePropertyValue "Desktop"

           $desktop|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
       $foundapps += $desktop
        }
    }

}

$foundapps|Export-Clixml -Path ($ExportFolder + "\XDEXPORT.xml")