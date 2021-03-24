#Load the VMware Powershell snapin if the script is being executed in PowerShell
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue'
 
#Connect to the vCenter server defined above. Ignore certificate errors
Write-Host "Connecting to vCenter"
Connect-VIServer -wa 0
Write-Host "Connected"
Write-Host ""
 
#Gather all VM's from vCenter
$vms = Get-VM | sort Name
 
foreach ($VM in $vms) {
Write-Host "Gathering info for " $VM.name
Write-Host "  Configured Guest OS: " $VM.ExtensionData.Config.GuestFullName
Write-Host "  VMtool reported OS:  "$VM.ExtensionData.Guest.GuestFullName
#$VM | ForEach-Object {$_.ExtensionData}
#$VM | ForEach-Object {$_.ExtensionData.Guest}
#$VM | ForEach-Object {$_.ExtensionData.Runtime}

Write-Host "====================================="
}
 
