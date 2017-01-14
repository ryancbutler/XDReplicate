CLS
$ExportFolder = "C:\Temp"
$tag = "replicate"
$xdhost = "localhost"


$DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -Tag $tag
$foundapps = @()

foreach ($DG in $DesktopGroups)
{
    write-host $DG.Name
  
    $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID
    
    if($apps)
    {
        foreach ($app in $apps)
        {
            Write-Host "Processing $($app.ApplicationName)"

            $app|add-member -NotePropertyName 'ResourceType' -NotePropertyValue "PublishedApp"

            $BrokerEnCodedIconData = (Get-BrokerIcon -AdminAddress $xdhost -Uid ($app.IconUid)).EncodedIconData
            $app|add-member -NotePropertyName 'EncodedIconData' -NotePropertyValue $BrokerEnCodedIconData
        
            $app|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
    
            $ftatemp = @()
            Get-BrokerConfiguredFTA -AdminAddress $xdhost -ApplicationUid $app.Uid | ForEach-Object -Process {
                

              $ftatemp += $_
            }
            
            if($ftatemp.count -gt 0)
            {
            $app|add-member -NotePropertyName "FTA" -NotePropertyValue $ftatemp
            }
            
        $foundapps += $app
        }
    }

    $desktops = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid 

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