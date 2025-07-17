# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential
#Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null
Connect-VIServer -Server $VC -Credential $CRED
