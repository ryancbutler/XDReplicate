CLS
$ExportFolder = "C:\Temp"
$tag = "replicate"
$xdhost = "localhost"



if($tag)
{
write-host HERE
$DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -Tag $tag
}
else
{
$DesktopGroups = Get-BrokerDesktopGroup -AdminAddress $xdhost -Tag
}

$appobject = @()
$desktopobject = @()

foreach ($DG in $DesktopGroups)
{
    write-host $DG.Name
    $dg|add-member -NotePropertyName 'AccessPolicyRule' -NotePropertyValue (Get-BrokerAccessPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid)
    $apps = Get-BrokerApplication -AdminAddress $xdhost -AssociatedDesktopGroupUUID $dg.UUID
    
    if($apps -is [object])
    {
    
        foreach ($app in $apps)
        {
            Write-Host "Processing $($app.ApplicationName)"

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
          
        $appobject += $app
        }
     
    }

    $desktops = Get-BrokerEntitlementPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dg.Uid 

    if($desktops -is [object])
    {
    
        foreach ($desktop in $desktops)
        {
           Write-Host "Processing $($desktop.PublishedName)"
            
           $desktop|add-member -NotePropertyName 'ResourceType' -NotePropertyValue "Desktop"

           $desktop|add-member -NotePropertyName 'DGNAME' -NotePropertyValue $dg.Name
        $desktopobject += $desktop
        }
    
    }

}

$xdout = New-Object PSCustomObject
$xdout|Add-Member -NotePropertyName "admins" -NotePropertyValue (Get-AdminAdministrator -AdminAddress $xdhost)
$xdout|Add-Member -NotePropertyName "dgs" -NotePropertyValue $DesktopGroups
$xdout|Add-Member -NotePropertyName "apps" -NotePropertyValue $appobject
$xdout|Add-Member -NotePropertyName "desktops" -NotePropertyValue $desktopobject
$xdout|Export-Clixml -Path ($ExportFolder + "\XDEXPORT.xml")