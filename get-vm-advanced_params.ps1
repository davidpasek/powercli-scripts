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
