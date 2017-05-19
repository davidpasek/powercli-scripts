#Enter your vCenter Host below
$vcenter = "vc01"
################################
 
#Load the VMware Powershell snapin if the script is being executed in PowerShell
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue'
 
#Connect to the vCenter server defined above. Ignore certificate errors
Write-Host "Connecting to vCenter"
$VCSESSION=Connect-VIServer $vcenter -wa 0 -ErrorAction Stop
Write-Host "Connected"
Write-Host ""

Write-Host -BackgroundColor Gray -ForegroundColor Black "The script goes through all Powered Off Virtual Machines and removes floppy drive for VMs having Guest ID configured as Windows OS."
 
#Gather all Powered On VM's from vCenter
$vms=GET-VM |  Where-Object {$_.PowerState -eq "PoweredOff" }
ForEach ($vm in $vms)
{
 $osvmtools = Get-VMguest -VM $vm | select OSFullName, GuestFamily
 $osconfig  = $vm.ExtensionData.Config | select GuestFullName, GuestID
 Write-Host "VM name: " $vm.Name
 Write-Host "VM Config OS Full Name : " $osconfig.GuestFullName
 Write-Host "VM Config Guest ID     : " $osconfig.GuestID
 Write-Host "VM Tools OS Full Name  : " $osvmtools.OSFullname
 Write-Host "VM Tools Guest Family  : " $osvmtools.GuestFamily
 if ($osconfig.GuestID.ToString() -match "windows")
 {
   $fd = Get-FloppyDrive -VM $vm
   if ($fd) {
     Write-Host -BackgroundColor Red -ForegroundColor Black "Removing floppy drive"
     $fd | Remove-FloppyDrive -Confirm:$false
   } else {
     Write-Host -BackgroundColor Green -ForegroundColor Black "No floppy drive"
   }
 } else {
   Write-Host -BackgroundColor Gray -ForegroundColor Black "No action as it is not Windows machine"
 }
 Write-Host "----"
}

Disconnect-VIserver -Server $VCSESSION -Force -Confirm:$false