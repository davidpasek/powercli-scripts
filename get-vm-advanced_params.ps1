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
    #Get-AdvancedSetting -Entity $vm -Name svga.vgaOnly
  } catch {
    Write-Warning -Message "VM doesn't exist";
  }

}

Disconnect-VIserver -Server $VC -Force -Confirm:$false
