function Send-XDslackmsg {
<#
.SYNOPSIS
   Sends message to slack URL
.DESCRIPTION
   Sends message to slack URL
.PARAMETER slackurl
   URL to send slack message
.PARAMETER msg
   Message to send to URL
.PARAMETER emoji
    Emoji to use to send message
.EXAMPLE
   send-xdslackmsg -slackurl "https://myurl.com" -msg "Send this"
#>
[cmdletbinding()]
param(
[Parameter(Mandatory=$true)][string]$slackurl, 
[Parameter(Mandatory=$true)][string]$msg, 
$emoji=":building_construction:")

    $slackmsg = @{text=$msg;icon_emoji=$emoji}|ConvertTo-Json

    Invoke-RestMethod -Uri $slackurl -Body $slackmsg -Method Post|Out-Null
}
