function Remove-XDDesktop
{
<#
.SYNOPSIS
   Removes Desktop(s) machine
.DESCRIPTION
   Removes Desktop(s) machine
.PARAMETER accts
   Desktop machines to remove
.EXAMPLE
   remove-xddesktop $desktop
#>
[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact='Low')]
param(
    $accts,
    [Parameter(Mandatory=$false)][string]$xdhost="localhost")

    if ($PSCmdlet.ShouldProcess("Removing desktop")) {
        if ($accts -is [object])
        {
            foreach ($acct in $accts)
            {
                Write-Verbose $acct.machinename
                #Placing machines in maintenance
                Set-BrokerMachine -MachineName $acct.machinename -InMaintenanceMode $true -adminaddress $xdhost

                #waiting for users to logoff
                if(Get-BrokerSession -MachineName $acct.machinename)
				{
				#get all sessions and logoff all users
                Get-BrokerSession -MachineName $acct.machinename -adminaddress $xdhost|Stop-BrokerSession
					do 
					{
						Write-Verbose "Waiting for users to log off"
						Start-Sleep -Seconds 5
						$sessions = Get-BrokerSession -MachineName $acct.machinename -adminaddress $xdhost
					} while ($sessions)
				}
                
				#powers down machine
                if($acct.PowerState -ne "Off")
				{
					$shutdowntask = New-BrokerHostingPowerAction -Action TurnOff -MachineName $acct.machinename -ActualPriority 0 -adminaddress $xdhost
					do 
					{
						Write-Verbose "Waiting for machine to power down"
						Start-Sleep -Seconds 5
						$temptask = Get-BrokerHostingPowerAction -Uid $shutdowntask.Uid -adminaddress $xdhost
					} until ($temptask.state -like "Completed")
				}
                #Removes from the desktop group
                remove-BrokerMachine -MachineName $acct.MachineName -DesktopGroup $acct.DesktopGroupName -adminaddress $xdhost -Force|write-verbose
            
                #Unlocks the account
                Unlock-ProvVM -VMID (get-provvm -VMname $acct.hostedmachinename -adminaddress $xdhost).VMId -ProvisioningSchemeName $acct.CatalogName -adminaddress $xdhost|write-verbose
                #Remove from machine catalog
                Write-Verbose "Removing machine from hosting"
                remove-ProvVM -VMName $acct.hostedmachinename -ProvisioningSchemeName $acct.CatalogName -adminaddress $xdhost|write-verbose
        
                #Remove accounts from MC and AD
                Remove-AcctADAccount -IdentityPoolName $acct.CatalogName -ADAccountSid $acct.SID -RemovalOption Delete -adminaddress $xdhost|write-verbose

                #remove account from machine catalog
                remove-BrokerMachine -MachineName $acct.MachineName -adminaddress $xdhost -Force|write-verbose
        
        }   

        }
        else
        {
            Write-Warning "No accounts found to remove.."
        }
    }
}
