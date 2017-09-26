function Import-XDDeliveryGroup
{
<#
.SYNOPSIS
    Creates delivery groups from exported object
.DESCRIPTION
    Creates delivery groups from exported object
.PARAMETER DG
    Delivery Group to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
    $XDEXPORT.dgs|import-xddeliverygroup
    Creates delivery groups from imported delivery group object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$dg,
[Parameter(Mandatory=$true)][string]$xdhost
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
    Process
    {
        $dgmatch = Get-BrokerDesktopGroup -AdminAddress $xdhost -Name $dg.NAME -ErrorAction SilentlyContinue
        
                    if ($dgmatch -is [object])
                    {
                    write-verbose "Setting $($dgmatch.name)"
                    Set-XDExistingDeliveryGroupObject $dg $xdhost
                    Get-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid -adminaddress $xdhost|remove-BrokerAccessPolicyRule -AdminAddress $xdhost -ErrorAction SilentlyContinue|Out-Null
                    $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -DesktopGroupUid $dgmatch.Uid -adminaddress $xdhost|Out-Null
                        
                        if($dg.powertime -is [object])
                        {
                            ($dg.PowerTime)|ForEach-Object{
                            write-verbose "Setting Power Time Scheme $($_.name)"
                            Set-BrokerPowerTimeScheme -AdminAddress $xdhost -Name $_.name -DisplayName $_.displayname -DaysOfWeek $_.daysofweek -PeakHours $_.peakhours -PoolSize $_.poolsize -PoolUsingPercentage $_.poolusingpercentage -ErrorAction SilentlyContinue|Out-Null
                            }
                        }
                    }
                    else
                    {
                    write-verbose "Creating Delivery Group"
                        try
                        {
                            write-verbose $dg.Name
                            $dgmatch = New-XDDeliveryGroupObject $dg $xdhost
                        }
                        Catch
                        {
                            throw "Delivery group failed. $($_.Exception.Message)"
                        }
                        
                        $dg.AccessPolicyRule|New-BrokerAccessPolicyRule -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null
                        
                        if($dg.powertime -is [object])
                        {        
                            ($dg.PowerTime)|ForEach-Object{
                            "Creating Power Time Scheme $($_.name)"
                            New-BrokerPowerTimeScheme -AdminAddress $xdhost -DesktopGroupUid $dgmatch.uid -Name $_.name -DaysOfWeek $_.daysofweek -PeakHours $_.peakhours -PoolSize $_.poolsize -PoolUsingPercentage $_.poolusingpercentage -DisplayName $_.displayname|Out-Null
                            }
                        }
                    
                    if($dg.prelaunch -is [object])
                    {
                    write-verbose "Setting pre-launch"
                    Remove-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupName $dg.Name -ErrorAction SilentlyContinue
                    $dg.PreLaunch|New-BrokerSessionPreLaunch -AdminAddress $xdhost -DesktopGroupUid $dgmatch.Uid|Out-Null
                    }
        
                    }
                    
        
                    if(-not([string]::IsNullOrWhiteSpace($dg.tags)))
                    {
                        foreach ($tag in $dg.tags)
                        {
                        write-verbose "Adding TAG $tag"
                        add-brokertag -Name $tag -AdminAddress $xdhost -DesktopGroup $dgmatch.name
                        }
                    }
    return $dgmatch
    }
    end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}