Clear-Host

# We need VMware PowerCLI snapin
$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential
Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null

$ESXiKernelMonules = @()
 
Foreach ($VMHost in  Get-VMHost) {
      $ESXCli = Get-EsxCli -VMHost $VMHost
      $ESXCli.system.module.list() |
      Foreach {
            $ESXiKernelMonules += $ESXCli.system.module.get($_.Name) | Select @{N="VMHost";E={$VMHost}}, Module, License, Modulefile, Version, SignedStatus, SignatureDigest, SignatureFingerPrint
      }
}
 
$ESXiKernelMonules | Out-GridView