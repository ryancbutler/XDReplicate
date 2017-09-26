function Import-XDTag
{
<#
.SYNOPSIS
    Creates desktops from imported object
.DESCRIPTION
    Creates desktops from imported object
.PARAMETER TAG
    TAG to create
.PARAMETER XDHOST
    XenDesktop DDC hostname to connect to
.EXAMPLE
    $XDEXPORT.tags|import-xdtag
    Creates tags from imported tag object
#>
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)][object]$tag,
[Parameter(Mandatory=$true)][string]$xdhost
)
begin{
Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
}
    Process
    {
        #Description argument not added until 7.11
        $ddcver = (Get-BrokerController -AdminAddress $xdhost).ControllerVersion | Select-Object -first 1


        $tagmatch = Get-BrokerTag -AdminAddress $xdhost -name $tag.name -ErrorAction SilentlyContinue
            if($tagmatch -is [object])
            {
            write-verbose "Found TAG $($tag.name)"
            }
            else
            {
            write-verbose "Creating TAG $($tag.name)"
                #Description argument not added until 7.11
                if ([version]$ddcver -lt "7.11")
                {
                    $tagmatch = New-BrokerTag -AdminAddress $xdhost -Name $tag.name
                }
                else
                {
                    $tagmatch = New-BrokerTag -AdminAddress $xdhost -Name $tag.name -Description $tag.description
                }
            }
        
    return $tagmatch
   }
    end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}