function Send-XDslackmsg {
<#
.SYNOPSIS
   Sends message to Slack incoming webhook URL
.DESCRIPTION
   Sends message to Slack incoming webhook URL
.PARAMETER slackurl
   Slack web incoming hook url
.PARAMETER msg
   Message to send to URL
.PARAMETER emoji
    Emoji to use as avatar to send message
.EXAMPLE
   send-xdslackmsg -slackurl "https://myurl.com" -msg "Send this" -emoji ":joy:"
#>
[cmdletbinding()]
param(
[Parameter(Mandatory=$true)][string]$slackurl, 
[Parameter(Mandatory=$true)][string]$msg, 
$emoji=":building_construction:")
begin{
    Write-Verbose "BEGIN: $($MyInvocation.MyCommand)"
    $slackmsg = @{text=$msg;icon_emoji=$emoji}|ConvertTo-Json
}
process {
    Invoke-RestMethod -Uri $slackurl -Body $slackmsg -Method Post|Write-Verbose
}
end{Write-Verbose "END: $($MyInvocation.MyCommand)"}
}
