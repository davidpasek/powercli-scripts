foreach ($esx in Get-VMhost) {
  Write-Host "Gathering info for " $esx.Name
  $esx | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreadingMitigationIntraVM"
  $esx | Get-AdvancedSetting -Name "VMkernel.Boot.hyperthreadingMitigation"
}
