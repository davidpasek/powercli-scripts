Clear-Host

$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
 
# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential
Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null

# Array of virtual machine names 
#$vm_names =  "W2K8R2-test1","W2K8R2-test2"
$vm_names =  "W2K8R2-test"

foreach ($vm_name in $vm_names) {
  Write-Host "VM: [$vm_name]"

  try {
    $vm = get-vm -Name $vm_name -ErrorAction Stop
    New-AdvancedSetting -Entity $vm -Name tools.syncTime -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.continue -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.restore -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.resume.disk -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.shrink -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.tools.startup -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.tools.enable -Value 0 -Confirm:$false -Force:$true
    New-AdvancedSetting -Entity $vm -Name time.synchronize.resume.host -Value 0 -Confirm:$false -Force:$true
  } catch {
    Write-Warning -Message "VM doesn't exist";
  }

}

Disconnect-VIserver -Server $VC -Force -Confirm:$false
