function get-xduser {
<#
.SYNOPSIS
   Gets user account associated to SLACK account
.DESCRIPTION
   Gets user account associated to SLACK account
.PARAMETER slackuser
   Slackuser account
#>
[cmdletbinding()]
param(
[Parameter(Mandatory=$true)][string]$slackuser
)

    $user = Get-ADUser -LDAPFilter "(description=$($slackuser))" -property description

    if ($user.count -gt 1)
    {
        throw "Multiple users found.  Check accounts"
    }
    elseif (-not ($user -is [object]))
    {
        return $false
    }
    else
    {
        $userstring = (get-addomain).name + "\" + $user.SamAccountName
        return $userstring
    }   
}
