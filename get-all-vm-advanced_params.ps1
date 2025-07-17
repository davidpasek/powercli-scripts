foreach ($vm in Get-VM) {
  Write-Host "Gathering info for " $VM.name
  Get-AdvancedSetting -Entity $vm -Name VMkernel.Boot.hyperthreadingMitigationIntraVM
  Get-AdvancedSetting -Entity $vm -Name VMkernel.Boot.hyperthreadingMitigation
}
