function import-xdapp
{
<#
.SYNOPSIS
    Creates broker application from exported object
.DESCRIPTION
    Creates broker application from exported object
.PARAMETER APP
    Broker Application to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.PARAMETER DGMATCH
    Delivery group to create application
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]$app,
[Parameter(Mandatory=$true)][string]$xdhost, 
[Parameter(Mandatory=$false)][string]$dgmatch,
[Parameter(Mandatory=$false)][string]$agmatch
)


    Process
    {
    write-verbose "Proccessing App $($app.browsername)"
    $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername -ErrorAction SilentlyContinue
        if($appmatch -is [Object])
        {
        write-verbose "Setting App"
        $folder = $app.AdminFolderName
        if($folder -is [object])
        {
            if ($folder -like $appmatch.AdminFolderName)
            {
            write-verbose "In correct folder"
            }
            else
            {
                if (-Not (Test-XDBrokerAdminFolder -folder $folder -xdhost $xdhost))
                {
                write-verbose "Creating folder"
                new-xdadminfolder $folder $xdhost
                }
            write-verbose "Moving App to correct folder"
            Move-BrokerApplication -AdminAddress $xdhost $appmatch -Destination $app.AdminFolderName
            $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername -ErrorAction SilentlyContinue
            }
        }
        set-xdexistingappobject $app $appmatch $xdhost

        #makes sure to rename app to match
        if($appmatch.ApplicationName -notlike $app.ApplicationName)
        {
            write-verbose "Renaming Application..."
            rename-brokerapplication -AdminAddress $xdhost -inputobject $appmatch -newname $app.ApplicationName
            $appmatch = Get-BrokerApplication -AdminAddress $xdhost -browsername $app.browsername
        }

        if((test-xdicon $app $appmatch $xdhost) -eq $false)
        {
            $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
            $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
        }
        clear-XDAppUserPerm $appmatch $xdhost
        set-XDNewAppUserPerm $app $appmatch $xdhost
        }
        else
        {
        write-verbose "Creating App"
        $folder = $app.AdminFolderName
        if(-not [string]::IsNullOrWhiteSpace($folder))
        {
            if (-Not (Test-XDBrokerAdminFolder -folder $folder -xdhost $xdhost))
            {
            write-verbose "Creating folder"
            new-xdadminfolder $folder $xdhost
            }
        }
        $appmatch = new-xdappobject -app $app -xdhost $xdhost -dgmatch $dgmatch.Name
        
        if($appmatch -is [Object])
        {

            #sets browsername to match
            set-brokerapplication -adminaddress $xdhost -inputobject $appmatch -browsername $app.browsername|out-null
        
            $icon = New-BrokerIcon -AdminAddress $xdhost -EncodedIconData $app.EncodedIconData
            $appmatch|Set-BrokerApplication -AdminAddress $xdhost -IconUid $icon.Uid
            set-XDNewAppUserPerm $app $appmatch $xdhost
            
            if($app|Select-Object -ExpandProperty FTA -ErrorAction SilentlyContinue)
            {
                foreach ($fta in $app.FTA)
                {
                New-XDFTAobject -xdhost $xdhost -fta $fta -newapp $app
                }
            }
        
        if(-not([string]::IsNullOrWhiteSpace($app.tags)))
            {
            foreach ($tag in $app.tags)
            {
            write-verbose "Adding TAG $tag"
            add-brokertag -Name $tag -AdminAddress $xdhost -Application $appmatch.name
            }
            }
        
        }
        else
        {
            Write-Warning "App Creation failed.  Check for name conflict. An ApplicationName of $($app.ApplicationName) already exists when using the browser name of $($app.BrowserName)."

        }
    
    return $appmatch
    }

}
}
